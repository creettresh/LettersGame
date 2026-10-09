//
//  LetterView.swift
//  LettersGame_iOS
//
//  Created by Volodymyr Yehorov on 09.12.2023.
//

import SwiftUI

/// One card on the table. Taps are handled by the parent.
struct LetterView: View {
    let isOpen: Bool
    let letter: String

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.linearGradient(Self.gradient,
                                          startPoint: isOpen ? Self.startPointUp : Self.startPointDown,
                                          endPoint: isOpen ? Self.endPointUp : Self.endPointDown))
                    .shadow(radius: 8)

                Text(verbatim: letter)
                    .font(.system(size: geometry.size.height * 0.6, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.2)
                    .foregroundStyle(isOpen ? .blue : .clear)
            }
            .scaleEffect(isOpen ? 1.08 : 1)
            .animation(.easeInOut, value: isOpen)
            .contentShape(Rectangle())
        }
        .accessibilityElement()
        .accessibilityLabel(isOpen ? Text(verbatim: letter) : Text("Closed card"))
        .accessibilityAddTraits(.isButton)
    }

    static let gradient = Gradient(colors: [.yellow, .blue])
    static let startPointDown = UnitPoint(x: 0, y: 1)
    static let endPointDown = UnitPoint(x: 1, y: 0)
    static let startPointUp = UnitPoint(x: 0.3, y: 0.7)
    static let endPointUp = UnitPoint(x: 1, y: 0)
}

#Preview {
    HStack {
        LetterView(isOpen: false, letter: "А")
        LetterView(isOpen: true, letter: "Ї")
    }
    .frame(height: 120)
    .padding()
}
