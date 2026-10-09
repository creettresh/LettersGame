//
//  LettersGame_Tests.swift
//  LettersGame_Tests
//
//  Created by Volodymyr Yehorov on 10.01.2024.
//

import XCTest

final class LettersGame_Tests: XCTestCase {

    private let names = ["Оля", "Тато"]

    /// A small fixed table: "Сова" can be built, the rest are distractors.
    private func makeGame(words: [String] = ["Сова", "Оса"]) -> GameData {
        let game = GameData()
        game.start(letters: ["С", "О", "В", "А", "Л", "Н"], words: words, playerNames: names)
        return game
    }

    private func index(of letter: String, in game: GameData) -> Int {
        game.letters.firstIndex(of: letter)!
    }

    /// Opens and resolves a card in one step, as the view does after its delay.
    @discardableResult
    private func play(_ letter: String, in game: GameData) -> GameData.MoveResult {
        let i = index(of: letter, in: game)
        XCTAssertTrue(game.open(i))
        return game.resolve(i)
    }

    // MARK: - Words

    func testGameLettersIgnoreCaseAndApostrophe() {
        XCTAssertEqual("Хомʼяк".gameLetters, ["х", "о", "м", "я", "к"])
        XCTAssertEqual("АЛОЕ".gameLetters, "алое".gameLetters)
    }

    func testEveryDeckWordCanBeBuiltFromItsLetters() {
        for deck in Deck.allCases {
            let pool = GameData.pool(for: [deck])
            XCTAssertEqual(pool.words.count, Set(deck.words).count, "\(deck) has a word that can't be collected")
        }
    }

    func testPoolMergesDecksWithoutDuplicates() {
        let pool = GameData.pool(for: [.orange, .blue])
        XCTAssertEqual(pool.letters.count, Set(pool.letters).count)
        XCTAssertEqual(pool.words.filter { $0 == "Лев" }.count, 1)
    }

    // MARK: - Rules

    func testHitKeepsTurnAndCardOpen() {
        let game = makeGame()
        XCTAssertEqual(play("С", in: game), .hit)
        XCTAssertEqual(game.currentPlayerIndex, 0)
        XCTAssertTrue(game.openIndexes.contains(index(of: "С", in: game)))
    }

    func testMissClosesCardAndPassesTurn() {
        let game = makeGame()
        XCTAssertEqual(play("Л", in: game), .miss)
        XCTAssertEqual(game.currentPlayerIndex, 1)
        XCTAssertTrue(game.openIndexes.isEmpty)
    }

    func testOpenCardCannotBeOpenedAgain() {
        let game = makeGame()
        play("С", in: game)
        XCTAssertFalse(game.open(index(of: "С", in: game)))
    }

    func testCompletingWordScoresAndNextWordPassesTurn() {
        let game = makeGame()
        play("С", in: game)
        play("О", in: game)
        play("В", in: game)
        XCTAssertEqual(play("А", in: game), .wordCompleted)
        XCTAssertEqual(game.players[0].collectedWords, ["Сова"])

        // No more cards can be opened until the next word starts.
        XCTAssertFalse(game.open(index(of: "Л", in: game)))

        game.nextWord()
        XCTAssertEqual(game.secretWord, "Оса")
        XCTAssertEqual(game.currentPlayerIndex, 1)
        XCTAssertTrue(game.openIndexes.isEmpty)
        XCTAssertTrue(game.foundLetters.isEmpty)
    }

    func testGameEndsAfterLastWord() {
        let game = makeGame(words: ["Оса"])
        play("О", in: game)
        play("С", in: game)
        play("А", in: game)
        game.nextWord()
        XCTAssertTrue(game.isGameOver)
        XCTAssertEqual(game.winnerIndex, 0)
        XCTAssertFalse(game.open(0))
    }

    func testDrawHasNoWinner() {
        let game = makeGame()
        XCTAssertNil(game.winnerIndex)
    }

    // MARK: - Computer player

    func testCPURecallsRememberedLetter() {
        let game = makeGame()
        let cpu = AutoMovesAI(chance: { 0 }, pick: { _ in 0 })
        cpu.difficulty = .hard
        let a = index(of: "А", in: game)
        cpu.remember(letter: "А", at: a)
        XCTAssertEqual(cpu.chooseCard(in: game), a)
    }

    func testCPUAvoidsCardsItKnowsAreUseless() {
        let game = makeGame()
        let cpu = AutoMovesAI(chance: { 0 }, pick: { _ in 0 })
        // "Л" is not in "Сова", so a card known to hold it is never worth opening.
        let l = index(of: "Л", in: game)
        cpu.remember(letter: "Л", at: l)
        let choice = cpu.chooseCard(in: game)
        XCTAssertNotEqual(choice, l)
    }

    func testCPUNeverChoosesOpenCard() {
        let game = makeGame()
        let cpu = AutoMovesAI()
        play("С", in: game)
        play("О", in: game)
        for _ in 0..<200 {
            let choice = cpu.chooseCard(in: game)!
            XCTAssertFalse(game.openIndexes.contains(choice))
        }
    }

    func testCPUSometimesFailsToRecallOnEasy() {
        let game = makeGame()
        // chance() = 0.8: above easy recall (0.72), below hard recall (0.86).
        let easy = AutoMovesAI(chance: { 0.8 }, pick: { _ in 0 })
        easy.difficulty = .easy
        let hard = AutoMovesAI(chance: { 0.8 }, pick: { _ in 0 })
        hard.difficulty = .hard
        let a = index(of: "А", in: game)
        easy.remember(letter: "А", at: a)
        hard.remember(letter: "А", at: a)

        XCTAssertNotEqual(easy.chooseCard(in: game), a)
        XCTAssertEqual(hard.chooseCard(in: game), a)
    }

    func testEasyForgetsMoreBetweenWords() {
        // chance() = 0.7: above easy keep (0.65), below hard keep (0.8).
        let easy = AutoMovesAI(chance: { 0.7 })
        easy.difficulty = .easy
        let hard = AutoMovesAI(chance: { 0.7 })
        hard.difficulty = .hard
        for (i, letter) in ["с", "о", "в"].enumerated() {
            easy.remember(letter: letter, at: i)
            hard.remember(letter: letter, at: i)
        }
        easy.newWordStarted()
        hard.newWordStarted()
        XCTAssertTrue(easy.memory.isEmpty)
        XCTAssertEqual(hard.memory.count, 3)
    }

    /// Two computers play a whole game on every difficulty; it must always finish.
    func testFullGameAlwaysFinishes() {
        for level in AutoMovesAI.DifficultyLevel.allCases {
            let game = GameData()
            game.start(decks: Set(Deck.allCases), playerNames: names)
            let cpu = AutoMovesAI()
            cpu.difficulty = level

            var moves = 0
            while !game.isGameOver && moves < 10_000 {
                let i = cpu.chooseCard(in: game)!
                XCTAssertTrue(game.open(i))
                cpu.remember(letter: game.letters[i], at: i)
                if game.resolve(i) == .wordCompleted {
                    game.nextWord()
                    cpu.newWordStarted()
                }
                moves += 1
            }
            XCTAssertTrue(game.isGameOver, "Game on \(level) did not finish")
            XCTAssertEqual(game.players[0].score + game.players[1].score,
                           GameData.pool(for: Set(Deck.allCases)).words.count)
        }
    }
}
