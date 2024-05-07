//
//  CollectionView.swift
//  LettersGame_iOS
//
//  Created by Volodymyr Yehorov on 09.12.2023.
//

import SwiftUI
import Combine

struct CollectionView: View {

    @Binding var selectionIndexes: IndexSet

    public var items: [String]
    private var itemNumber: Int {
        items.count
    }

    let letterPublisher = PassthroughSubject<LetterView, Never>()

    // Grid settings
    private let gridItemSpacing = 4.0
    private let minGridItemWidth = 64.0
    private let scale: CGFloat = 4 / 3
    
    private var minGridItemHeight: CGFloat {
        minGridItemWidth * scale
    }
    private var maxGridItemWidth: CGFloat {
        minGridItemWidth * 2
    }

    private func columnsGridItemWithCount(count: Int) -> [GridItem] {
        var gridItems: [GridItem] = []
        for _ in 0..<count {
            var gridItem = GridItem(.flexible())
            gridItem.spacing = gridItemSpacing
            gridItems.append(gridItem)
        }
        return gridItems
    }

    private func availableColumnCountFrom(geometry: GeometryProxy) -> (column: Int, itemWidth: CGFloat) {
        let width = geometry.size.width
        let height = geometry.size.height
        let availableSpace = width * height

        var gridItemWidth = minGridItemWidth
        var gridItemHeight = gridItemWidth * scale
        var itemsRequiredSpace = 0.0
        let delta = 2.0

        while itemsRequiredSpace < availableSpace && gridItemWidth < width {
            gridItemWidth += delta
            gridItemHeight = gridItemWidth * scale
            itemsRequiredSpace = CGFloat(itemNumber) * 2 * (gridItemWidth * gridItemHeight + gridItemSpacing)
        }

        let columns = Int(width / gridItemWidth)

        return (columns, gridItemWidth)
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                let columnsAndWidth = availableColumnCountFrom(geometry: geometry)
                let itemWidth = columnsAndWidth.itemWidth
                let gridItems = columnsGridItemWithCount(count: columnsAndWidth.column)

                LazyVGrid(columns: gridItems, alignment: .center, content: {
                    ForEach(0..<itemNumber, id: \.self) { index in
                        let selected = selectionIndexes.contains(index)
                        let cellView = LetterView(isSelected: selected, letter: items[index], index: index)
                        cellView
                            .frame(width: itemWidth, height: itemWidth * scale)
                            .onReceive(cellView.indexPublisher, perform: { index in
                                didSelectCellBy(index)
                                letterPublisher.send(cellView)
                            })
                     }
                })
            }
        }
    }

    private func didSelectCellBy(_ index: Int) {
        if selectionIndexes.contains(index) {
            selectionIndexes.remove(index)
        } else {
            selectionIndexes.insert(index)
        }
    }
}

#Preview {
    CollectionView(selectionIndexes: .constant(IndexSet()), items: ModelData().letters_orange)
}
