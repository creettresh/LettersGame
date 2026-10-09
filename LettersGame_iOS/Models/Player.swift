//
//  Player.swift
//  LettersGame_iOS
//
//  Created by Volodymyr Yehorov on 19.04.2024.
//

import Foundation

struct Player: Equatable {
    var name: String
    /// Words this player collected, in the order they were won.
    var collectedWords: [String] = []

    var score: Int { collectedWords.count }
}
