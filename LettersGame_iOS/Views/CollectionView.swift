//
//  CollectionView.swift
//  LettersGame_iOS
//
//  Created by Volodymyr Yehorov on 09.12.2023.
//

import SwiftUI

/// The table of cards. Picks the column count that gives the biggest cards
/// that still fit the available space, so the grid never needs scrolling.
struct CollectionView: View {
    let items: [String]
    let openIndexes: Set<Int>
    /// Called only for closed cards; open cards ignore taps.
    let onTap: (Int) -> Void

    private let spacing: CGFloat = 8
    private let aspectRatio: CGFloat = 4 / 3
    private let maxCardWidth: CGFloat = 160

    var body: some View {
        GeometryReader { geometry in
            let layout = bestLayout(for: geometry.size)
            let columns = Array(repeating: GridItem(.fixed(layout.width), spacing: spacing),
                                count: layout.columns)

            LazyVGrid(columns: columns, spacing: spacing) {
                ForEach(items.indices, id: \.self) { index in
                    LetterView(isOpen: openIndexes.contains(index), letter: items[index])
                        .frame(width: layout.width, height: layout.width * aspectRatio)
                        .onTapGesture {
                            if !openIndexes.contains(index) {
                                onTap(index)
                            }
                        }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }

    private func bestLayout(for size: CGSize) -> (columns: Int, width: CGFloat) {
        guard !items.isEmpty, size.width > 0, size.height > 0 else { return (1, 44) }

        var best: (columns: Int, width: CGFloat) = (1, 0)
        for columns in 1...items.count {
            let rows = (items.count + columns - 1) / columns
            let byWidth = (size.width - spacing * CGFloat(columns - 1)) / CGFloat(columns)
            let byHeight = (size.height - spacing * CGFloat(rows - 1)) / CGFloat(rows) / aspectRatio
            let width = min(byWidth, byHeight, maxCardWidth)
            if width > best.width {
                best = (columns, width)
            }
        }
        return (best.columns, max(best.width.rounded(.down), 20))
    }
}

#Preview {
    CollectionView(items: Deck.orange.letters, openIndexes: [0, 3]) { _ in }
        .padding()
}
