//
//  LetterView.swift
//  LettersGame_iOS
//
//  Created by Volodymyr Yehorov on 09.12.2023.
//

import SwiftUI
import Combine

struct LetterView: View {
    var isSelected: Bool
    var letter: String
    var index: Int

    let scaleForTap = 1.1

    let indexPublisher = PassthroughSubject<Int, Never>()

    var body: some View {
        GeometryReader { geometry in

            let width: CGFloat = min(geometry.size.width, geometry.size.height)
            let height = width
            let xScale: CGFloat = 3 / 4
            let tapScale = isSelected ? scaleForTap : 1
            let xOffset = (width * (1.0 - xScale * tapScale)) / 2.0
            let yOffset = (height * (isSelected ? 1 / tapScale : 1) / 2.0)

            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .frame(width: width * xScale * tapScale, height: height * tapScale)
                    .shadow(radius: 8)
                    .foregroundStyle(.linearGradient(Self.gradient,
                        startPoint: isSelected ? Self.startPointUp : Self.startPointDown,
                        endPoint: isSelected ? Self.endPointUp : Self.endPointDown))
                    .animation(.easeInOut, value: isSelected)
                    .contentShape(Rectangle())

                Text(letter)
                    .frame(width: width * xScale, height: height)
                    .foregroundStyle(isSelected ? .blue : .clear)
                    .font(.system(size: 220))
                    .minimumScaleFactor(0.2)
                    .animation(.easeOut, value: isSelected)
            }
            .padding(.horizontal, xOffset)
            .padding(.vertical, yOffset)
            .onTapGesture {
                indexPublisher.send(index)
            }
        }
    }

    static let gradient: Gradient = Gradient(colors:  [.yellow, .blue])
    static let startPointDown = UnitPoint(x: 0, y: 1)
    static let endPointDown = UnitPoint(x: 1, y: 0)

    static let startPointUp = UnitPoint(x: 0.3, y: 0.7)
    static let endPointUp = UnitPoint(x: 1, y: 0)
}

#Preview {
    LetterView(isSelected: false, letter: "A", index: 0)
}
