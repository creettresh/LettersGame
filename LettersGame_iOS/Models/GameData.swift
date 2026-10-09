//
//  GameData.swift
//  LettersGame_iOS
//
//  Created by Volodymyr Yehorov on 25.12.2023.
//

import Foundation

/// Rules of the game. Pure logic with no UI and no timers, so it can be unit tested.
///
/// A turn is two steps: `open(_:)` turns a card face up, then after the view has
/// shown it for a moment, `resolve(_:)` decides what the card means.
@Observable
final class GameData {

    enum MoveResult: Equatable {
        /// The card was not open, or the word is already collected.
        case notAllowed
        /// The letter is in the word: the card stays open and the same player moves again.
        case hit
        /// The letter is not in the word: the card closes and the turn passes.
        case miss
        /// The last missing letter was found: the current player takes the word.
        case wordCompleted
    }

    private(set) var players: [Player] = [Player(name: "Player 1"), Player(name: "Player 2")]
    private(set) var currentPlayerIndex = 0
    private(set) var letters: [String] = []
    /// Words still to play; the first one is the current secret word.
    private(set) var remainingWords: [String] = []
    private(set) var secretWord = ""
    /// Lowercased letters of the secret word found so far.
    private(set) var foundLetters: Set<String> = []
    private(set) var openIndexes: Set<Int> = []
    private(set) var isGameOver = false

    var neededLetters: Set<String> { secretWord.gameLetters }

    var isWordCompleted: Bool {
        !secretWord.isEmpty && neededLetters.isSubset(of: foundLetters)
    }

    /// Index of the winning player, or nil for a draw.
    var winnerIndex: Int? {
        let first = players[0].score, second = players[1].score
        if first == second { return nil }
        return first > second ? 0 : 1
    }

    // MARK: - Setup

    /// Letters and words for the chosen decks. Words that can't be built
    /// from the letters on the table are left out, so a game can never get stuck.
    static func pool(for decks: Set<Deck>) -> (letters: [String], words: [String]) {
        var letters: Set<String> = []
        var words: Set<String> = []
        for deck in decks {
            letters.formUnion(deck.letters)
            words.formUnion(deck.words)
        }
        let available = Set(letters.map { $0.lowercased() })
        let playable = words.filter { $0.gameLetters.isSubset(of: available) }
        return (letters.sorted(), playable.sorted())
    }

    func start(decks: Set<Deck>, playerNames: [String]) {
        let pool = Self.pool(for: decks)
        start(letters: pool.letters.shuffled(), words: pool.words.shuffled(), playerNames: playerNames)
    }

    /// Starts with letters and words in the given order. Used directly by tests.
    func start(letters: [String], words: [String], playerNames: [String]) {
        precondition(playerNames.count == 2, "The game is for two players")
        self.letters = letters
        remainingWords = words
        players = playerNames.map { Player(name: $0) }
        currentPlayerIndex = 0
        openIndexes = []
        foundLetters = []
        secretWord = words.first ?? ""
        isGameOver = words.isEmpty
    }

    // MARK: - Moves

    func canOpen(_ index: Int) -> Bool {
        !isGameOver && !isWordCompleted && letters.indices.contains(index) && !openIndexes.contains(index)
    }

    /// Turns a closed card face up. Returns false if that card can't be opened now.
    @discardableResult
    func open(_ index: Int) -> Bool {
        guard canOpen(index) else { return false }
        openIndexes.insert(index)
        return true
    }

    /// Decides what an opened card means and updates turn and score.
    func resolve(_ index: Int) -> MoveResult {
        guard openIndexes.contains(index), !isWordCompleted, !isGameOver else { return .notAllowed }

        let letter = letters[index].lowercased()
        guard neededLetters.contains(letter) else {
            openIndexes.remove(index)
            switchPlayer()
            return .miss
        }

        foundLetters.insert(letter)
        guard isWordCompleted else { return .hit }

        players[currentPlayerIndex].collectedWords.append(secretWord)
        return .wordCompleted
    }

    /// After a word is collected: closes all cards, picks the next word and passes
    /// the turn. Ends the game when no words are left.
    func nextWord() {
        guard isWordCompleted else { return }
        remainingWords.removeFirst()
        openIndexes = []
        foundLetters = []

        guard let next = remainingWords.first else {
            secretWord = ""
            isGameOver = true
            return
        }
        secretWord = next
        switchPlayer()
    }

    private func switchPlayer() {
        currentPlayerIndex = 1 - currentPlayerIndex
    }
}

// MARK: - String extension

extension String {
    /// Unique lowercased letters of a word; the apostrophe is not a letter.
    var gameLetters: Set<String> {
        Set(lowercased().filter { !"ʼ'’".contains($0) }.map(String.init))
    }
}
