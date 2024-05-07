//
//  ResultsView.swift
//  LettersGame_iOS
//
//  Created by Volodymyr Yehorov on 19.04.2024.
//

import SwiftUI

struct ResultsView: View {
    @Environment(GameData.self) var gameData

//    @State var isFirstPlayerWin = gameData.player_1.score > gameData.player_2.score

    var body: some View {

        var isFirstPlayerWin = gameData.player_1.score > gameData.player_2.score

        HStack {
            Text(gameData.player_1.name)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(isFirstPlayerWin ? .title : .title2)
                .foregroundStyle(isFirstPlayerWin ? .purple : .gray)
            Spacer()
            Text(gameData.player_2.name)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .font(!isFirstPlayerWin ? .title : .title2)
                .foregroundStyle(!isFirstPlayerWin ? .orange : .gray)
        }
        .padding()

        HStack {
            Text("Cards: \(gameData.player_1.score)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(isFirstPlayerWin ? .purple : .gray)
            Spacer()
            Text("Cards: \(gameData.player_2.score)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(!isFirstPlayerWin ? .orange : .gray)
        }
        .padding()

    }
}

#Preview {
    ResultsView()
        .environment(GameData())
}
