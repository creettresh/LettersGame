//
//  StartScreen.swift
//  LettersGame_iOS
//
//  Created by Volodymyr Yehorov on 31.12.2023.
//

import SwiftUI

struct StartScreen: View {
    @State private var game = GameData()
    @State private var cpu = AutoMovesAI()

    @State private var player1Name = ""
    @State private var player2Name = ""
    @State private var isCPUOn = false
    @State private var selectedDecks: Set<Deck> = []
    @State private var isPlaying = false

    private let iconWidth = 32.0

    private var pool: (letters: [String], words: [String]) {
        GameData.pool(for: selectedDecks)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    playersSection
                    decksSection
                    startButton
                }
                .padding()
            }
            .navigationTitle("Letters")
            .navigationDestination(isPresented: $isPlaying) {
                GameField(vsCPU: isCPUOn, restart: startGame)
                    .environment(game)
                    .environment(cpu)
            }
        }
    }

    // MARK: - Sections

    private var playersSection: some View {
        VStack(spacing: 12) {
            HStack {
                playerIcon(.purple)
                TextField("Player 1", text: $player1Name)
                    .font(.title)
            }

            HStack {
                playerIcon(.orange)
                if isCPUOn {
                    Text("Computer")
                        .font(.title)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    TextField("Player 2", text: $player2Name)
                        .font(.title)
                }
                Toggle("Computer", isOn: $isCPUOn.animation())
                    .labelsHidden()
            }

            if isCPUOn {
                Picker("Difficulty", selection: $cpu.difficulty) {
                    ForEach(AutoMovesAI.DifficultyLevel.allCases) { level in
                        Text(level.title).tag(level)
                    }
                }
                .pickerStyle(.segmented)
                .transition(.opacity)
            }
        }
    }

    private var decksSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 20) {
                ForEach(Deck.allCases) { deck in
                    deckButton(deck)
                }
            }

            HStack {
                Text("Letters in Game: \(pool.letters.count)")
                Spacer()
                Text("Words in Game: \(pool.words.count)")
            }
            .font(.title3)
            .monospacedDigit()
        }
    }

    private var startButton: some View {
        VStack(spacing: 8) {
            Button {
                startGame()
                isPlaying = true
            } label: {
                Text("New Game")
                    .font(.title.bold())
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .controlSize(.large)
            .disabled(pool.words.isEmpty)

            if pool.words.isEmpty {
                Text("Choose at least one deck")
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Parts

    private func playerIcon(_ color: Color) -> some View {
        Image(systemName: "person.fill")
            .resizable()
            .frame(width: iconWidth, height: iconWidth)
            .foregroundStyle(color)
    }

    private func deckButton(_ deck: Deck) -> some View {
        let isChosen = selectedDecks.contains(deck)
        return Button {
            if isChosen {
                selectedDecks.remove(deck)
            } else {
                selectedDecks.insert(deck)
            }
        } label: {
            Image(systemName: isChosen ? "heart.fill" : "suit.heart")
                .font(.title)
                .foregroundStyle(deck.color)
                .scaleEffect(isChosen ? 1.4 : 1)
                .animation(.easeOut, value: isChosen)
                .padding(8)
        }
        .accessibilityLabel(Text(deck.title))
        .accessibilityAddTraits(isChosen ? .isSelected : [])
    }

    // MARK: - Game

    private func startGame() {
        let first = player1Name.trimmingCharacters(in: .whitespaces)
        let second = player2Name.trimmingCharacters(in: .whitespaces)
        let names = [
            first.isEmpty ? String(localized: "Player 1") : first,
            isCPUOn ? String(localized: "Computer") : (second.isEmpty ? String(localized: "Player 2") : second)
        ]
        cpu.reset()
        game.start(decks: selectedDecks, playerNames: names)
    }
}

// MARK: - UI texts and colors for models

extension Deck {
    var color: Color {
        switch self {
        case .orange: .orange
        case .green: .green
        case .blue: .blue
        case .purple: .purple
        }
    }

    var title: LocalizedStringKey {
        switch self {
        case .orange: "Orange deck"
        case .green: "Green deck"
        case .blue: "Blue deck"
        case .purple: "Purple deck"
        }
    }
}

extension AutoMovesAI.DifficultyLevel {
    var title: LocalizedStringKey {
        switch self {
        case .easy: "Easy"
        case .normal: "Normal"
        case .hard: "Hard"
        }
    }
}

#Preview {
    StartScreen()
}
