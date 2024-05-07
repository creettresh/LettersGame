//
//  StartScreen.swift
//  LettersGame_iOS
//
//  Created by Volodymyr Yehorov on 31.12.2023.
//

import SwiftUI

struct StartScreen: View {
    @Environment(\.horizontalSizeClass) private var hSizeClass
    @Environment(\.verticalSizeClass) private var vSizeClass

    @State private var isOrangeCardStackChosen = false
    @State private var isGreenCardStackChosen = false
    @State private var isBlueCardStackChosen = false
    @State private var isPurpletCardStackChosen = false

    @State private var letterCount = 0
    @State private var wordCount = 0

    @State private var isCPUOn: Bool = false

    private var isNewGameAvailable: Bool  {
        isOrangeCardStackChosen || isGreenCardStackChosen || isBlueCardStackChosen || isPurpletCardStackChosen
    }

    @State private var gameData = GameData()
    @State private var CPU = AutoMovesAI()

    private let iconWidth = 32.0

    var body: some View {
        NavigationView {
            VStack(alignment: .center) {

                HStack(alignment: .center) {
                    Image(systemName: "person.fill")
                        .resizable()
                        .frame(width: iconWidth, height: iconWidth)
                        .foregroundStyle(.purple)

                    TextField("Player_1", text: $gameData.player_1.name)
                        .font(.title)
                        .padding()
                }
                .padding(.horizontal)

                HStack(alignment: .center) {
                    Image(systemName: "person.fill")
                        .resizable()
                        .frame(width: iconWidth, height: iconWidth)
                        .foregroundStyle(.orange)

                    TextField("Player_2", text: isCPUOn ? $CPU.name : $gameData.player_2.name)
                        .font(.title)
                        .padding()

                    Toggle(isOn: $isCPUOn) {
                        Text("CPU is \(isCPUOn ? "On" : "Off") ")
                            .font(.title2)
                            .foregroundStyle(isCPUOn ? .blue : .gray)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }

                }
                .padding(.horizontal)

                HStack(alignment: .bottom) {
                    Button {
                        CPU.difficulty = .easy
                    } label: {
                        Text(AutoMovesAI.DifficultyLevel.easy.rawValue)
                            .font(CPU.difficulty == .easy ? .title : .title2)
                            .foregroundStyle(CPU.difficulty == .easy ? .green : .gray)
                            .opacity(isCPUOn ? 1 : 0)
                    }

                    Button {
                        CPU.difficulty = .normal
                    } label: {
                        Text(AutoMovesAI.DifficultyLevel.normal.rawValue)
                            .font(CPU.difficulty == .normal ? .title : .title2)
                            .foregroundStyle(CPU.difficulty == .normal ? .yellow : .gray)
                            .opacity(isCPUOn ? 1 : 0)
                    }

                    Button {
                        CPU.difficulty = .hard
                    } label: {
                        Text(AutoMovesAI.DifficultyLevel.hard.rawValue)
                            .font(CPU.difficulty == .hard ? .title : .title2)
                            .foregroundStyle(CPU.difficulty == .hard ? .red : .gray)
                            .opacity(isCPUOn ? 1 : 0)
                    }
                }
                .animation(.easeIn, value: isCPUOn)

                HStack(alignment: .center) {
                    makeButton(isCardStackChosen: $isOrangeCardStackChosen, color: .orange)
                    makeButton(isCardStackChosen: $isGreenCardStackChosen, color: .green)
                    makeButton(isCardStackChosen: $isBlueCardStackChosen, color: .blue)
                    makeButton(isCardStackChosen: $isPurpletCardStackChosen, color: .purple)
                }

                NavigationLink {
                    GameField(vsCPU: isCPUOn)
                        .environment(gameData)
                        .environment(CPU)

                } label: {
                    Text("New Game")
                        .font(isNewGameAvailable ? .title : .title2)
                        .foregroundStyle(isNewGameAvailable ? .green : .gray)
                }
                    .padding(.vertical)
                    .disabled(!isNewGameAvailable)
                    .animation(.easeOut(duration: 0.5), value: isNewGameAvailable)

                Spacer()

                HStack(alignment: .top) {
                    Text((hSizeClass == .compact && vSizeClass == .regular ? "Letters:" : "Letters in Game:") + "\(letterCount)")
                        .font(.title2)
                        .padding(.horizontal)

                    Spacer()

                    Text((hSizeClass == .compact && vSizeClass == .regular ? "Words:" : "Words in Game:") + "\(wordCount)")
                        .font(.title2)
                        .padding(.horizontal)
                }

                Spacer()
            }
        }
        .navigationTitle("Start screen")
        .navigationViewStyle(.stack)
    }

    @ViewBuilder
    func makeButton(isCardStackChosen :Binding<Bool>, color :Color) -> some View {
        Button(action: {
            isCardStackChosen.wrappedValue.toggle()
            prepareTheGame()
        }, label: {
           Label("", systemImage: isCardStackChosen.wrappedValue ? "heart.fill" : "suit.heart")
            .foregroundStyle(color)
            .scaleEffect(isCardStackChosen.wrappedValue ? 2 : 1.5)
            .padding()
            .animation(.easeOut, value: isCardStackChosen.wrappedValue)
        })
    }

// TODO: - move to GameData ..
    private func prepareTheGame() {
        let modelData = ModelData()

        var gameLetters: Set<String> = []
        var gameWords: Set<String> = []

        if isOrangeCardStackChosen {
            gameLetters.formUnion(modelData.letters_orange)
            gameWords.formUnion(modelData.words_orange)
        }

        if isGreenCardStackChosen {
            gameLetters.formUnion(modelData.letters_green)
            gameWords.formUnion(modelData.words_green)
        }

        if isBlueCardStackChosen {
            gameLetters.formUnion(modelData.letters_blue)
            gameWords.formUnion(modelData.words_blue)
        }

        if isPurpletCardStackChosen {
            gameLetters.formUnion(modelData.letters_purple)
            gameWords.formUnion(modelData.words_purple)
        }

        var letters = Array(gameLetters)
        var words = Array(gameWords)
        letters.shuffle()
        words.shuffle()
        gameData.playingLetters = letters
        gameData.playingWords = words
        gameData.answers = ""

        if gameData.playingWords.count > 0 {
            gameData.secretWord = gameData.playingWords.first!
        }

        letterCount = gameLetters.count
        wordCount = gameWords.count
    }
}


#Preview {
    StartScreen()
}
