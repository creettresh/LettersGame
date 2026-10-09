//
//  GameField.swift
//  LettersGame_iOS
//
//  Created by Volodymyr Yehorov on 17.12.2023.
//

import SwiftUI

/// The game screen. Rules live in `GameData`; this view only adds timing:
/// how long a card stays visible and how long the computer "thinks".
struct GameField: View {
    @Environment(GameData.self) private var game
    @Environment(AutoMovesAI.self) private var cpu
    @Environment(\.dismiss) private var dismiss

    let vsCPU: Bool
    /// Starts a new game with the same players and decks.
    let restart: () -> Void

    @State private var isBusy = false
    @State private var isSparkling = false
    @State private var showResults = false
    @State private var goToMenu = false
    /// The running move. Cancelled when the screen closes, so no timer fires afterwards.
    @State private var moveTask: Task<Void, Never>?

    private let playerOpenDelay: Duration = .milliseconds(900)
    private let cpuThinkDelay: Duration = .milliseconds(1000)
    private let cpuOpenDelay: Duration = .milliseconds(1500)
    private let nextWordDelay: Duration = .milliseconds(1400)

    private var isCPUTurn: Bool { vsCPU && game.currentPlayerIndex == 1 }

    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                header
                secretWordView
                CollectionView(items: game.letters, openIndexes: game.openIndexes, onTap: playerTapped)
            }
            .padding()
            .allowsHitTesting(!isBusy && !isCPUTurn)

            if isSparkling {
                SparkleView(isAnimating: $isSparkling, birthRate: Float(game.neededLetters.count) + 1)
                    .allowsHitTesting(false)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            moveTask?.cancel()
        }
        .fullScreenCover(isPresented: $showResults, onDismiss: {
            if goToMenu { dismiss() }
        }) {
            ResultsView(players: game.players,
                        winnerIndex: game.winnerIndex,
                        onPlayAgain: {
                            goToMenu = false
                            showResults = false
                            restart()
                        },
                        onMenu: {
                            goToMenu = true
                            showResults = false
                        })
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top) {
            playerBadge(0)
            VStack(spacing: 0) {
                Text(verbatim: "\(game.remainingWords.count)")
                    .font(.title2.bold())
                    .monospacedDigit()
                Text("Words left")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .fixedSize()
            playerBadge(1)
        }
    }

    private func playerBadge(_ index: Int) -> some View {
        let isActive = game.currentPlayerIndex == index && !game.isGameOver
        let color: Color = index == 0 ? .purple : .orange
        let alignment: HorizontalAlignment = index == 0 ? .leading : .trailing

        return VStack(alignment: alignment, spacing: 2) {
            Text(verbatim: game.players[index].name)
                .font(isActive ? .title : .title2)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text("Cards: \(game.players[index].score)")
                .font(.headline)
                .monospacedDigit()
            Group {
                if isActive {
                    Text(vsCPU && index == 1 ? "Thinking…" as LocalizedStringKey : "Your turn")
                } else {
                    Text(verbatim: " ")
                }
            }
            .font(.caption)
        }
        .foregroundStyle(isActive ? color : .gray)
        .frame(maxWidth: .infinity, alignment: index == 0 ? .leading : .trailing)
        .animation(.easeInOut, value: isActive)
    }

    // MARK: - Secret word

    /// The word with every found letter turned green, so children see what's still missing.
    private var secretWordView: some View {
        HStack(spacing: 6) {
            ForEach(Array(game.secretWord.enumerated()), id: \.offset) { _, character in
                let letter = String(character)
                let isLetter = !letter.gameLetters.isEmpty
                let isFound = game.foundLetters.contains(letter.lowercased())

                Text(verbatim: letter)
                    .font(.system(.largeTitle, design: .rounded).bold())
                    .foregroundStyle(isFound ? Color.green : Color.primary)
                    .padding(.bottom, 4)
                    .overlay(alignment: .bottom) {
                        if isLetter {
                            Capsule()
                                .fill(isFound ? Color.green : Color.secondary.opacity(0.35))
                                .frame(height: 4)
                        }
                    }
                    .animation(.spring, value: isFound)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: game.secretWord))
    }

    // MARK: - Moves

    private func playerTapped(_ index: Int) {
        guard !isBusy, !isCPUTurn, game.open(index) else { return }
        isBusy = true
        startMove {
            try await Task.sleep(for: playerOpenDelay)
            try await resolve(index)
        }
    }

    private func startMove(_ operation: @escaping @MainActor () async throws -> Void) {
        moveTask?.cancel()
        moveTask = Task { @MainActor in
            do {
                try await operation()
            } catch {
                // Cancelled: the screen was closed mid-move.
                isBusy = false
            }
        }
    }

    @MainActor
    private func resolve(_ index: Int) async throws {
        isSparkling = false
        if vsCPU {
            cpu.remember(letter: game.letters[index], at: index)
        }

        if game.resolve(index) == .wordCompleted {
            isSparkling = true
            try await Task.sleep(for: nextWordDelay)
            game.nextWord()

            if game.isGameOver {
                isBusy = false
                showResults = true
                return
            }
            if vsCPU {
                cpu.newWordStarted()
            }
        }

        isBusy = false
        if isCPUTurn {
            try await cpuMove()
        }
    }

    @MainActor
    private func cpuMove() async throws {
        isBusy = true
        try await Task.sleep(for: cpuThinkDelay)
        guard let index = cpu.chooseCard(in: game), game.open(index) else {
            isBusy = false
            return
        }
        try await Task.sleep(for: cpuOpenDelay)
        try await resolve(index)
    }
}

#Preview {
    let game = GameData()
    game.start(decks: [.orange], playerNames: ["Оля", "Тато"])
    return NavigationStack {
        GameField(vsCPU: false, restart: {})
            .environment(game)
            .environment(AutoMovesAI())
    }
}
