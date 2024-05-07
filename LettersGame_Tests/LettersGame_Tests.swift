//
//  LettersGame_Tests.swift
//  LettersGame_Tests
//
//  Created by Volodymyr Yehorov on 10.01.2024.
//

import XCTest

final class LettersGame_Tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testGameDataAnswerMatch() {
        let gameData = GameData()

        // true
        gameData.secretWord = "Алое"
        gameData.answers =  "алое"
        XCTAssertTrue(gameData.isAllCharsFound())

        // true
        gameData.secretWord = "Сова"
        gameData.answers =  "ОВСА"
        XCTAssertTrue(gameData.isAllCharsFound())

        // false
        gameData.secretWord = "Алое"
        gameData.answers =  "а"
        XCTAssertFalse(gameData.isAllCharsFound())

        // true
        gameData.secretWord = "Хомʼяк"
        gameData.answers =  "Хомяк"
        XCTAssertTrue(gameData.isAllCharsFound())
    }

    func testAutoMovesAI() {
        let model = ModelData()
        let game = GameData()

        // Set orange letters and words
        game.playingLetters = model.letters_orange
        game.playingWords = model.words_orange

        // Set first word to find
        game.secretWord = model.words_orange.first!

        // Make AI class
        let CPU = AutoMovesAI()
        CPU.prepareToGameWithLetters(count: game.playingWords.count, secretWord: game.secretWord)

        while !game.isAllCharsFound() {
            var letterIndex = CPU.makeMove()
            var letter = game.nextMoveLetterFor(index: letterIndex)
            CPU.letterWasOpened(letter: letter, by: letterIndex)
            print("new letter : \(letter)")

            if game.isSecretWordContains(letter) {
                game.answers.append(letter)
                print("new correct letter : \(letter)")
            }
        }
        print("first word answer : \(game.answers)")

        // Set next word to find
        game.playingWords.remove(at: 0)
        game.answers = ""
        game.secretWord = game.playingWords.first!

        CPU.setupNew(secretWord: game.secretWord)

        while !game.isAllCharsFound() {
            var letterIndex = CPU.makeMove()
            var letter = game.nextMoveLetterFor(index: letterIndex)
            CPU.letterWasOpened(letter: letter, by: letterIndex)
            print("new letter : \(letter)")

            if game.isSecretWordContains(letter) {
                game.answers.append(letter)
                print("new correct letter : \(letter)")
            }
        }
        print("next word answer : \(game.answers)")

    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
