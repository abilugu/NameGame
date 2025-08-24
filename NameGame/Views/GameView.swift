import SwiftUI

struct GameView: View {
    @ObservedObject var gameViewModel: GameViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // White background
                Color.white
                    .ignoresSafeArea()
                
                Group {
                    if geometry.size.width > geometry.size.height {
                        // Landscape layout
                        VStack(spacing: 20) {
                            // Header with game mode and back button
                            HStack {
                                Button(action: {
                                    gameViewModel.resetGame()
                                }) {
                                    Image(systemName: "arrow.left")
                                        .font(.title2)
                                        .foregroundColor(Color(red: 21/255, green: 101/255, blue: 157/255))
                                }
                                
                                Spacer()
                                
                                Text(gameViewModel.gameMode == .practice ? "Practice Mode" : "Timed Mode")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                // Circular progress bar
                                ZStack {
                                    Circle()
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 4)
                                        .frame(width: 40, height: 40)
                                    
                                    Circle()
                                        .trim(from: 0, to: gameViewModel.gameMode == .practice ? CGFloat(gameViewModel.score) / 5.0 : CGFloat(gameViewModel.timeRemaining) / 60.0)
                                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                        .frame(width: 40, height: 40)
                                        .rotationEffect(.degrees(-90))
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top)
                            
                            // Main content area
                            HStack(spacing: 40) {
                                // Left side - Name
                                VStack {
                                    Spacer()
                                    
                                    if let correctProfile = gameViewModel.correctProfile {
                                        Text(correctProfile.fullName)
                                            .font(.system(size: 36, weight: .bold, design: .rounded))
                                            .foregroundColor(.black)
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal)
                                    }
                                    
                                    Spacer()
                                }
                                .frame(width: geometry.size.width * 0.4)
                                
                                // Right side - Headshots grid
                                if !gameViewModel.currentProfiles.isEmpty {
                                    LazyVGrid(
                                        columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3),
                                        spacing: 12
                                    ) {
                                        ForEach(gameViewModel.currentProfiles) { profile in
                                            ProfileHeadshotView(
                                                profile: profile,
                                                isSelected: gameViewModel.selectedProfile?.id == profile.id,
                                                isCorrect: gameViewModel.showResult && gameViewModel.selectedProfile?.id == profile.id && profile.id == gameViewModel.correctProfile?.id,
                                                isWrong: gameViewModel.wrongGuesses.contains(profile.id) || (gameViewModel.showResult && gameViewModel.selectedProfile?.id == profile.id && profile.id != gameViewModel.correctProfile?.id),
                                                showResult: gameViewModel.showResult,
                                                gameMode: gameViewModel.gameMode
                                            ) {
                                                if !gameViewModel.showResult {
                                                    gameViewModel.selectProfile(profile)
                                                }
                                            }
                                        }
                                    }
                                    .frame(width: geometry.size.width * 0.6)
                                }
                            }
                            .padding(.horizontal)
                        }
                    } else {
                        // Portrait layout
                        VStack(spacing: 20) {
                            // Header with game mode and back button
                            HStack {
                                Button(action: {
                                    gameViewModel.resetGame()
                                }) {
                                    Image(systemName: "arrow.left")
                                        .font(.title2)
                                        .foregroundColor(Color(red: 21/255, green: 101/255, blue: 157/255))
                                }
                                
                                Spacer()
                                
                                Text(gameViewModel.gameMode == .practice ? "Practice Mode" : "Timed Mode")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                // Circular progress bar
                                ZStack {
                                    Circle()
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 4)
                                        .frame(width: 40, height: 40)
                                    
                                    Circle()
                                        .trim(from: 0, to: gameViewModel.gameMode == .practice ? CGFloat(gameViewModel.score) / 5.0 : CGFloat(gameViewModel.timeRemaining) / 60.0)
                                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                        .frame(width: 40, height: 40)
                                        .rotationEffect(.degrees(-90))
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top)
                            
                            // Name to match
                            VStack(spacing: 8) {
                                if let correctProfile = gameViewModel.correctProfile {
                                    Text(correctProfile.fullName)
                                        .font(.system(size: 32, weight: .bold, design: .rounded))
                                        .foregroundColor(.black)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                }
                            }
                            .padding(.vertical)
                            
                            // Headshots grid
                            if !gameViewModel.currentProfiles.isEmpty {
                                LazyVGrid(
                                    columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2),
                                    spacing: 12
                                ) {
                                    ForEach(gameViewModel.currentProfiles) { profile in
                                        ProfileHeadshotView(
                                            profile: profile,
                                            isSelected: gameViewModel.selectedProfile?.id == profile.id,
                                            isCorrect: gameViewModel.showResult && gameViewModel.selectedProfile?.id == profile.id && profile.id == gameViewModel.correctProfile?.id,
                                            isWrong: gameViewModel.wrongGuesses.contains(profile.id) || (gameViewModel.showResult && gameViewModel.selectedProfile?.id == profile.id && profile.id != gameViewModel.correctProfile?.id),
                                            showResult: gameViewModel.showResult,
                                            gameMode: gameViewModel.gameMode
                                        ) {
                                            if !gameViewModel.showResult {
                                                gameViewModel.selectProfile(profile)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            Spacer()
                        }
                    }
                }
            }
        }
        .alert("Game Over!", isPresented: $gameViewModel.showGameOverAlert) {
            Button("OK") {
                gameViewModel.resetGame()
            }
        } message: {
            Text("Score: \(gameViewModel.score)/5")
        }
    }
}

struct ProfileHeadshotView: View {
    let profile: Profile
    let isSelected: Bool
    let isCorrect: Bool
    let isWrong: Bool
    let showResult: Bool
    let gameMode: GameMode
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    AsyncImage(url: URL(string: profile.headshot.displayURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.title)
                                    .foregroundColor(.gray)
                            )
                    }
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(borderColor, lineWidth: 3)
                    )
                    .scaleEffect(isSelected ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isSelected)
                    
                    // Correct/Incorrect overlay
                    if showResult {
                        if (isCorrect) {
                            Image("Correct")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                                .background(Color.white.opacity(0.9))
                                .clipShape(Circle())
                        } else if (isWrong) {
                            Image("Incorrect")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                                .background(Color.white.opacity(0.9))
                                .clipShape(Circle())
                        }
                    }
                }
                

            }
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isSelected)
    }
    
    private var borderColor: Color {
        if isCorrect {
            return .green
        } else if isWrong {
            return .red
        } else if isSelected {
            return .blue
        } else {
            return .clear
        }
    }
}

#Preview {
    GameView(gameViewModel: GameViewModel())
}
