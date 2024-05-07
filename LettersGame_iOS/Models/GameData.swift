//
//  GameData.swift
//  LettersGame_iOS
//
//  Created by Volodymyr Yehorov on 25.12.2023.
//

import Foundation

@Observable
class GameData {
    var player_1 = Player()
    var player_2 = Player()

    var answers: String = ""
    var secretWord: String = "A"
    var playingWords: [String] = ["A"]
    var playingLetters: [String] = ["A"]

    init() {
        player_1.name = "Player1"
        player_2.name = "Player2"
    }

/// Find char in secretWord, caseinsensetive search
    func isSecretWordContains(_ char: String) -> Bool {
        return secretWord.isWordContains(char)
    }

/// Match answers with secretWord, except ' (apostrophe)
    func isAllCharsFound() -> Bool {
        secretWord.hasAllChars(answers)
    }

/// Setup new secretWord and return false if not
    func setupNewSecretWord() -> Bool {
        playingWords.remove(at: 0)

        if playingWords.count > 0 {
            playingWords.shuffle()
            secretWord = playingWords.first!
        }
        else {
            secretWord = ""
        }
        
        return secretWord.count > 0
    }

    /// For test for now
    func nextMoveLetterFor(index: Int) -> String {
        return playingLetters[index]
    }
}

// MARK: String extension
/// Math as caseinsensetive, ' (apostrophe) excluded.
extension String {

    func isWordContains(_ char: String) -> Bool {
        let lowercased = self.lowercased()
        let lowerChar = char.lowercased()
        return lowercased.contains(lowerChar)
    }

    func hasAllChars(_ other: String) -> Bool {
        let lString = self.lowercased()
        let rString = other.lowercased()

        let lStr = lString.filter{ $0 != "ʼ" }
        let rStr = rString.filter{ $0 != "ʼ" }

        let ls = lStr.sorted()
        let rs = rStr.sorted()

        return ls.elementsEqual(rs)
    }
}
