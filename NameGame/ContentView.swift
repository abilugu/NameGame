//
//  ContentView.swift
//  NameGame
//
//  Created by Aravind Bilugu on 8/24/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var profileViewModel = ProfileViewModel()
    @StateObject private var gameViewModel = GameViewModel()
    
    var body: some View {
        Group {
            switch gameViewModel.currentScreen {
            case .menu:
                MenuView(profileViewModel: profileViewModel, gameViewModel: gameViewModel)
            case .game:
                GameView(gameViewModel: gameViewModel)
            case .gameOver:
                EmptyView() // No longer needed since we use alert
            }
        }
    }
}

#Preview {
    ContentView()
}
