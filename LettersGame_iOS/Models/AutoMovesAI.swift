//
//  AutoMovesAI.swift
//  LettersGame_iOS
//
//  Created by Volodymyr Yehorov on 03.01.2024.
//

import Foundation

@Observable
class AutoMovesAI {
    /// CPU name to display
    var name = "CPU"

    var difficulty: DifficultyLevel = .normal

    /// All current geme letters count
    private var gameLettersCount: Int = 0

    /// Current word to discover
    private var _secretWord: String = ""
    var secretWord: String {
        get {
            _secretWord.lowercased()
        }
        set {
            _secretWord = newValue
        }
    }

    /// Current found letters for secretWord
    private var answerLetters: String = ""

    /// opened letters Indexes                          // letter key     // letter index value
    private var knownLetterIndexes: [String : Int] = [ : ]

    /// Should be invoked before start playing and  makeMove()
    func prepareToGameWithLetters(count: Int, secretWord: String) {
        gameLettersCount = count
        self.secretWord = secretWord
    }

    func letterWasOpened(letter: String, by index: Int)  {
        assert(letter.count == 1)
        assert(index >= 0)
        assert(index < gameLettersCount)

        let lowLetter = letter.lowercased()

        // store to memory
        self.knownLetterIndexes.updateValue(index, forKey: lowLetter)

        if self.secretWord.isWordContains(lowLetter) {
            answerLetters.append(lowLetter)
        }
    }

    /// Find next letter index for secretWord
    func makeMove() -> Int {
        var result: Int?

        result = findNextLetterIndexInMemory()

        if result == nil {
            result = randomLetterIndex()
        }

        return result!
    }

    func setupNew(secretWord: String) {
        prepareForNextSecretWord()
        self.secretWord = secretWord

        difficultyImitation()
    }

    /// Imitate forgetting some letters
    private func difficultyImitation() {

        var letterCount = 0
        switch difficulty {
            case .easy:
                letterCount = 5
            case .normal:
                letterCount = 3
            case .hard:
                letterCount = 1
        }

        // try to remove letters
        while letterCount != 0 && knownLetterIndexes.count > letterCount {
            knownLetterIndexes.removeValue(forKey: knownLetterIndexes.first!.key)
            letterCount -= 1
        }

    }

    private func prepareForNextSecretWord() {
        secretWord = ""
        answerLetters = ""
    }

    /// Get random letter Index, except already opened
    private func randomLetterIndex() -> Int {
        var randomIndex = 0

        var keepSearching = true
        while keepSearching {
            randomIndex = Int.random(in: 0..<gameLettersCount)
            keepSearching = knownLetterIndexes.contains { (key: String, value: Int) in
                value == randomIndex
            }

            if knownLetterIndexes.count == gameLettersCount {
                keepSearching = false
//                assert(false)
            }
        }

        return randomIndex
    }

    /// Get letter index from memory or nil if not found
    private func findNextLetterIndexInMemory() -> Int? {
        var result: Int?

        for letter in secretWord {
            if !answerLetters.isWordContains(String(letter)) {
                result = knownLetterIndexes[String(letter).lowercased()]
                if result != nil {
                    break
                }
            }
        }

        return result
    }


    enum DifficultyLevel: String {
        case easy = "Easy"
        case normal = "Normal"
        case hard = "Hard"
    }
}
