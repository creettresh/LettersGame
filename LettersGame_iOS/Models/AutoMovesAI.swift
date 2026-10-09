//
//  AutoMovesAI.swift
//  LettersGame_iOS
//
//  Created by Volodymyr Yehorov on 03.01.2024.
//

import Foundation

/// Computer player. It remembers which letter lies under every card it has seen
/// opened (by anyone), but like a child it can fail to recall a card during a move
/// and forgets part of what it saw when a new word starts. Difficulty sets how often.
@Observable
final class AutoMovesAI {

    enum DifficultyLevel: String, CaseIterable, Identifiable {
        case easy, normal, hard

        var id: String { rawValue }

        /// Chance to recall a remembered card that has a needed letter, checked on every move.
        var recallChance: Double {
            switch self {
            case .easy: 0.72
            case .normal: 0.78
            case .hard: 0.86
            }
        }

        /// Chance to keep each remembered card when a new word starts.
        var keepChance: Double {
            switch self {
            case .easy: 0.65
            case .normal: 0.72
            case .hard: 0.8
            }
        }
    }

    var difficulty: DifficultyLevel = .normal

    /// Card index -> lowercased letter under it.
    private(set) var memory: [Int: String] = [:]

    /// Random sources, replaceable in tests. `chance` returns 0..<1, `pick(n)` returns 0..<n.
    @ObservationIgnored private let chance: () -> Double
    @ObservationIgnored private let pick: (Int) -> Int

    init(chance: @escaping () -> Double = { Double.random(in: 0..<1) },
         pick: @escaping (Int) -> Int = { Int.random(in: 0..<$0) }) {
        self.chance = chance
        self.pick = pick
    }

    /// Call before every new game.
    func reset() {
        memory.removeAll()
    }

    /// Call for every card opened, by either player.
    func remember(letter: String, at index: Int) {
        memory[index] = letter.lowercased()
    }

    /// Call when a new secret word starts: part of the memory fades.
    func newWordStarted() {
        memory = memory.filter { _ in chance() < difficulty.keepChance }
    }

    /// Picks a closed card to open, or nil when every card is open.
    func chooseCard(in game: GameData) -> Int? {
        let closed = game.letters.indices.filter { !game.openIndexes.contains($0) }
        guard !closed.isEmpty else { return nil }

        // 1. A card it remembers with a letter the word still needs.
        let missing = game.neededLetters.subtracting(game.foundLetters)
        for index in closed {
            if let letter = memory[index], missing.contains(letter), chance() < difficulty.recallChance {
                return index
            }
        }

        // 2. A card it hasn't seen yet. Cards it knows are useless are avoided.
        let unseen = closed.filter { memory[$0] == nil }
        let candidates = unseen.isEmpty ? closed : unseen
        return candidates[pick(candidates.count)]
    }
}
