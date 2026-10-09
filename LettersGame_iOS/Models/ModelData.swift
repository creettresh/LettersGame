//
//  ModelData.swift
//  LettersGame_iOS
//
//  Created by Volodymyr Yehorov on 10.12.2023.
//

import Foundation

/// A deck of cards: the letters laid out on the table and the words
/// that can be collected from them. Letters inside a word never repeat.
enum Deck: String, CaseIterable, Identifiable {
    case orange, green, blue, purple

    var id: String { rawValue }

    var letters: [String] {
        switch self {
        case .orange: ["А", "В", "Е", "І", "Л", "Н", "О", "П", "С"]
        case .green:  ["А", "В", "Д", "Е", "Є", "И", "І", "К", "Л", "М", "Н", "О", "П", "Т", "Ш", "Ь", "Ю", "Я"]
        case .blue:   ["А", "Б", "В", "Е", "Є", "З", "Й", "К", "Л", "М", "Н", "О", "С", "У", "Х", "Ц", "Ь", "Я"]
        case .purple: ["А", "Б", "Г", "Ґ", "Д", "Е", "И", "Ї", "Ф", "Ж", "З", "К", "П", "Р", "У", "Ч", "Щ", "Ь"]
        }
    }

    var words: [String] {
        switch self {
        case .orange: ["Поні", "Алое", "Лев", "Ліс", "Сіно", "Оса", "Слон", "Сова"]
        case .green:  ["Поні", "Алое", "Лев", "Єнот", "Індик", "Конвалія", "Пітон", "Миша", "Півень", "Тюлень", "Пелікан"]
        case .blue:   ["Буйвол", "Алое", "Лев", "Заєць", "Козел", "Оса", "Слон", "Сова", "Сойка", "Хомʼяк", "Ему"]
        case .purple: ["Курча", "Грак", "Гриф", "Їжак", "Жираф", "Зебра", "Ґедзь", "Гепард", "Чиж", "Карп", "Щука"]
        }
    }
}
