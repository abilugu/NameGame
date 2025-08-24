import SwiftUI

struct MenuView: View {
    @ObservedObject var profileViewModel: ProfileViewModel
    @ObservedObject var gameViewModel: GameViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background image based on orientation
                if geometry.size.width > geometry.size.height {
                    // Landscape background
                    Image("Splash2")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                        .ignoresSafeArea()
                } else {
                    // Portrait background
                    Image("Splash")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                        .ignoresSafeArea()
                }
                
                Group {
                    if geometry.size.width > geometry.size.height {
                        // Landscape layout
                        HStack {
                            Spacer()
                            
                            VStack(spacing: 30) {
                                Spacer()
                                
                                // Title container
                                VStack(spacing: 16) {
                                    Text("Try matching the WillowTree employee to their photo")
                                        .font(.title2)
                                        .foregroundColor(.white.opacity(0.9))
                                        .multilineTextAlignment(.center)
                                }
                                .frame(width: 281, height: 83)
                                
                                // Game mode buttons
                                VStack(spacing: 20) {
                                    Button(action: {
                                        startGame(.practice)
                                    }) {
                                        Text("Practice Mode")
                                            .font(.title2)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                            .frame(width: 200, height: 56)
                                            .background(Color(red: 21/255, green: 101/255, blue: 157/255))
                                            .cornerRadius(12)
                                    }
                                    .disabled(profileViewModel.profiles.isEmpty)
                                    
                                    Button(action: {
                                        startGame(.timed)
                                    }) {
                                        Text("Timed Mode")
                                            .font(.title2)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                            .frame(width: 200, height: 56)
                                            .background(Color(red: 21/255, green: 101/255, blue: 157/255))
                                            .cornerRadius(12)
                                    }
                                    .disabled(profileViewModel.profiles.isEmpty)
                                }
                                
                                Spacer()
                            }
                            .frame(width: geometry.size.width * 0.4)
                            .padding(.trailing, 20)
                            .padding(.bottom, max(geometry.safeAreaInsets.bottom, 34) + 20)
                        }
                    } else {
                        // Portrait layout
                        VStack {
                            Spacer()
                            
                            // Bottom section with text and buttons
                            VStack(spacing: 30) {
                                // Title container
                                VStack(spacing: 16) {
                                    Text("Try matching the WillowTree employee to their photo")
                                        .font(.title2)
                                        .foregroundColor(.white.opacity(0.9))
                                        .multilineTextAlignment(.center)
                                }
                                .frame(width: 281, height: 83)
                                
                                // Game mode buttons
                                VStack(spacing: 20) {
                                    Button(action: {
                                        startGame(.practice)
                                    }) {
                                        Text("Practice Mode")
                                            .font(.title2)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 56)
                                            .background(Color(red: 21/255, green: 101/255, blue: 157/255))
                                            .cornerRadius(12)
                                    }
                                    .disabled(profileViewModel.profiles.isEmpty)
                                    
                                    Button(action: {
                                        startGame(.timed)
                                    }) {
                                        Text("Timed Mode")
                                            .font(.title2)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 56)
                                            .background(Color(red: 21/255, green: 101/255, blue: 157/255))
                                            .cornerRadius(12)
                                    }
                                    .disabled(profileViewModel.profiles.isEmpty)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, max(geometry.safeAreaInsets.bottom, 50) + 30)
                        }
                    }
                }
                
                // Loading indicator - overlay
                if profileViewModel.isLoading {
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.2)
                            .tint(.white)
                        Text("Loading profiles...")
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                // Error message - overlay
                if let error = profileViewModel.errorMessage {
                    VStack(spacing: 12) {
                        Text("Error: \(error)")
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(8)
                            .padding(.horizontal)
                        
                        Button("Retry") {
                            profileViewModel.retryFetch()
                        }
                        .foregroundColor(.blue)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(8)
                    }
                }
            }
        }
    }
    
    private func startGame(_ mode: GameMode) {
        guard !profileViewModel.profiles.isEmpty else { return }
        gameViewModel.startGame(mode: mode, profiles: profileViewModel.profiles)
    }
}

#Preview {
    MenuView(
        profileViewModel: ProfileViewModel(),
        gameViewModel: GameViewModel()
    )
}
