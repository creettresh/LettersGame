//
//  GameField.swift
//  LettersGame_iOS
//
//  Created by Volodymyr Yehorov on 17.12.2023.
//

import SwiftUI
import Combine

struct GameField: View {
    @Environment(GameData.self) var gameData
    @Environment(AutoMovesAI.self) var CPU

    @State private var selectionIndexes = IndexSet()
    @State private var isHitTestingEnabled = true

    @State private var isPlayer_1_turn = true
    @State private var isPlayer_2_turn = false

    private let timeDelayCPU = DispatchTimeInterval.milliseconds(1500)
    private let timeDelayPlayer = DispatchTimeInterval.milliseconds(900)

    @State var isSparkling = false

    let vsCPU: Bool

    func prepareNextPlayerMove() {
        isPlayer_1_turn = !isPlayer_1_turn
        isPlayer_2_turn = !isPlayer_1_turn
    }

    private func makeCPUMoveIfNeededWith(delay: Int) {
        if vsCPU && isPlayer_2_turn  {
            let delayTime = DispatchTimeInterval.seconds(delay)
            DispatchQueue.main.asyncAfter(deadline: .now() + delayTime) {
                makeCPUMove()
            }
        }
    }

    private func makeCPUMove() {
        // Get index on field to open
        let index = CPU.makeMove()
        selectionIndexes.insert(index)

        let letter = gameData.playingLetters[index]

        // Deley how long card is open
        DispatchQueue.main.asyncAfter(deadline: .now() + timeDelayCPU) {
            chosenLetter(letter, by: index)
        }
    }

    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text(gameData.player_1.name)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(isPlayer_1_turn ? .title : .title2)
                        .foregroundStyle(isPlayer_1_turn ? .purple : .gray)
                    Spacer()
                    Text("\(gameData.playingWords.count)")
                        .frame(width: 40)
                        .font(.title2)
                    Spacer()
                    Text(vsCPU ? CPU.name : gameData.player_2.name)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .font(isPlayer_2_turn ? .title : .title2)
                        .foregroundStyle(isPlayer_2_turn ? .orange : .gray)
                }

                HStack {
                    Text("Cards: \(gameData.player_1.score)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(isPlayer_1_turn ? .purple : .gray)
                    Spacer()
                    Text(gameData.secretWord)
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                    Text("Cards: \(gameData.player_2.score)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(isPlayer_2_turn ? .orange : .gray)
                }

                let cards = CollectionView(selectionIndexes: $selectionIndexes, items: gameData.playingLetters)
                cards
                    .onReceive(cards.letterPublisher, perform: { letterView in
                        isHitTestingEnabled = false

                        DispatchQueue.main.asyncAfter(deadline: .now() + timeDelayPlayer) {
                            userChoseLetter(letterView.letter, by: letterView.index)
                            isHitTestingEnabled = true // enable hit testing
                        }
                    })
                    .onAppear {
                        resetGame()
                    }
            }
            .padding()
            .allowsHitTesting(isHitTestingEnabled)

            if isSparkling {
                let sparkleView = SparkleView(isAnimating: $isSparkling,
                    birthRate: Float(gameData.answers.count) + 1)
                sparkleView
                    .allowsHitTesting(false)
            }
        }
        .onAppear {
            if vsCPU {
                CPU.prepareToGameWithLetters(count: gameData.playingLetters.count, secretWord: gameData.secretWord)
            }
        }
        .disabled(vsCPU && isPlayer_2_turn)
    }

    private func userChoseLetter(_ letter: String, by index : Int) {
        chosenLetter(letter, by: index)
    }

    private func chosenLetter(_ letter: String, by index : Int) {
        isSparkling = false

        if vsCPU {
            CPU.letterWasOpened(letter: letter, by: index)
        }

        // Check if right char was opened
        if gameData.isSecretWordContains(letter) {
            if !gameData.answers.contains(letter) {
                gameData.answers.append(letter)
            }
        }
        else {
            selectionIndexes.remove(index)

            prepareNextPlayerMove()
        }

        // Check if all chars for secret word were found
        if  gameData.isAllCharsFound() {
            if isPlayer_1_turn {
                gameData.player_1.score += 1
            }
            else {
                gameData.player_2.score += 1
            }

            isSparkling.toggle()
            DispatchQueue.main.asyncAfter(deadline: .now() + timeDelayPlayer) {
                nextRound()
                resetGame()
            }
        }
        else {
            // CPU move
            makeCPUMoveIfNeededWith(delay: 1)
        }
    }

// MARK: -

    private func nextRound() {
        // Get new word or game is over
        if gameData.setupNewSecretWord() {
            prepareNextPlayerMove()
            if vsCPU {
                CPU.setupNew(secretWord: gameData.secretWord)
                makeCPUMoveIfNeededWith(delay: 3)
            }
        }
        else {
            // TODO: - make show detail

//            NavigationLink {
//                ResultsView()
//                    .environment(gameData)
//            } label: {
//                Text("New Game")
//                    .font(isNewGameAvailable ? .title : .title2)
//                    .foregroundStyle(isNewGameAvailable ? .green : .gray)
//            }

        }
    }

    private func resetGame() {
        selectionIndexes.removeAll()
        gameData.answers.removeAll()
    }
}

#Preview {
    GameField(vsCPU: false)
        .environment(GameData())
        .environment(AutoMovesAI())
}
