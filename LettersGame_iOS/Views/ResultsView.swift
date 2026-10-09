//
//  ResultsView.swift
//  LettersGame_iOS
//
//  Created by Volodymyr Yehorov on 19.04.2024.
//

import SwiftUI

/// Shown when the last word is collected: who won, the score,
/// and which words each player took.
struct ResultsView: View {
    let players: [Player]
    let winnerIndex: Int?
    let onPlayAgain: () -> Void
    let onMenu: () -> Void

    @State private var appeared = false

    private let colors: [Color] = [.purple, .orange]

    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 0)

            Image(systemName: winnerIndex == nil ? "hands.clap.fill" : "trophy.fill")
                .font(.system(size: 72))
                .foregroundStyle(winnerIndex.map { colors[$0] } ?? .yellow)
                .scaleEffect(appeared ? 1 : 0.3)
                .animation(.spring(response: 0.5, dampingFraction: 0.5), value: appeared)

            title
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)

            Text(verbatim: "\(players[0].score) : \(players[1].score)")
                .font(.system(size: 44, weight: .heavy, design: .rounded))
                .monospacedDigit()

            HStack(alignment: .top, spacing: 12) {
                ForEach(players.indices, id: \.self) { index in
                    playerCard(index)
                }
            }

            Spacer(minLength: 0)

            HStack(spacing: 12) {
                Button(action: onMenu) {
                    Text("Menu").frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button(action: onPlayAgain) {
                    Text("Play Again").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
            .controlSize(.large)
            .font(.title3.bold())
        }
        .padding()
        .onAppear { appeared = true }
    }

    @ViewBuilder
    private var title: some View {
        if let winnerIndex {
            Text("\(players[winnerIndex].name) wins!")
                .foregroundStyle(colors[winnerIndex])
        } else {
            Text("Draw!")
        }
    }

    private func playerCard(_ index: Int) -> some View {
        let player = players[index]
        let isWinner = winnerIndex == index

        return VStack(spacing: 8) {
            Text(verbatim: player.name)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text("Cards: \(player.score)")
                .font(.subheadline.bold())
                .monospacedDigit()

            if player.collectedWords.isEmpty {
                Text("No words")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 64), spacing: 4)], spacing: 4) {
                    ForEach(player.collectedWords, id: \.self) { word in
                        Text(verbatim: word)
                            .font(.footnote.bold())
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(colors[index].opacity(0.15), in: Capsule())
                    }
                }
            }
        }
        .foregroundStyle(colors[index])
        .padding()
        .frame(maxWidth: .infinity)
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 16))
        .overlay {
            if isWinner {
                RoundedRectangle(cornerRadius: 16).stroke(colors[index], lineWidth: 3)
            }
        }
    }
}

#Preview {
    ResultsView(players: [Player(name: "Оля", collectedWords: ["Лев", "Сова", "Оса"]),
                          Player(name: "Тато", collectedWords: ["Поні"])],
                winnerIndex: 0,
                onPlayAgain: {},
                onMenu: {})
}
