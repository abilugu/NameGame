import Foundation
import Combine

enum GameMode {
    case practice
    case timed
}

enum GameScreen {
    case menu
    case game
    case gameOver
}

class GameViewModel: ObservableObject {
    @Published var currentScreen: GameScreen = .menu
    @Published var gameMode: GameMode = .practice
    @Published var score = 0
    @Published var timeRemaining: Int = 60
    @Published var isGameActive = false
    @Published var showGameOverAlert = false
    
    // Game round data
    @Published var currentProfiles: [Profile] = []
    @Published var correctProfile: Profile?
    @Published var selectedProfile: Profile?
    @Published var isCorrect = false
    @Published var showResult = false
    @Published var wrongGuesses: Set<String> = [] // Track wrong guesses for timed mode
    
    // Performance tracking
    @Published var totalGuesses = 0
    @Published var correctGuesses = 0
    
    private var allProfiles: [Profile] = []
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Game Management
    
    func startGame(mode: GameMode, profiles: [Profile]) {
        gameMode = mode
        score = 0
        totalGuesses = 0
        correctGuesses = 0
        currentScreen = .game
        isGameActive = true
        allProfiles = profiles
        
        if mode == .timed {
            timeRemaining = 60
            startTimer()
        }
        
        generateNewRound()
    }
    
    func endGame() {
        isGameActive = false
        timer?.invalidate()
        timer = nil
        showGameOverAlert = true
    }
    
    func resetGame() {
        currentScreen = .menu
        score = 0
        timeRemaining = 60
        isGameActive = false
        totalGuesses = 0
        correctGuesses = 0
        timer?.invalidate()
        timer = nil
        currentProfiles = []
        correctProfile = nil
        selectedProfile = nil
        isCorrect = false
        showResult = false
        showGameOverAlert = false
        wrongGuesses.removeAll()
    }
    
    // MARK: - Game Logic
    
    func generateNewRound() {
        guard allProfiles.count >= 6 else { return }
        
        // Select 6 random profiles from the full list
        let shuffledProfiles = allProfiles.shuffled()
        currentProfiles = Array(shuffledProfiles.prefix(6))
        
        // Select one as the correct answer
        correctProfile = currentProfiles.randomElement()
        
        // Reset selection state
        selectedProfile = nil
        isCorrect = false
        showResult = false
        wrongGuesses.removeAll() // Clear wrong guesses for new round
    }
    
    func selectProfile(_ profile: Profile) {
        selectedProfile = profile
        totalGuesses += 1
        isCorrect = profile.id == correctProfile?.id
        
        if isCorrect {
            score += 1
            correctGuesses += 1
            showResult = true
            
            // In practice mode, check if game should end (reached 5 correct answers)
            if gameMode == .practice && score >= 5 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.endGame()
                }
            } else {
                // Continue to next round after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.generateNewRound()
                }
            }
        } else {
            // Add to wrong guesses for timed mode
            if gameMode == .timed {
                wrongGuesses.insert(profile.id)
            }
            
            // In practice mode, game over after wrong guess
            if gameMode == .practice {
                showResult = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.endGame()
                }
            } else {
                // In timed mode, show wrong overlay and allow continued guessing
                showResult = true
                // Reset selection after a short delay to allow continued guessing
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.selectedProfile = nil
                    self.showResult = false
                }
            }
        }
    }
    
    // MARK: - Timer Management
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.endGame()
                }
            }
        }
    }
    
    // MARK: - Performance Metrics
    
    var accuracyPercentage: Double {
        guard totalGuesses > 0 else { return 0 }
        return Double(correctGuesses) / Double(totalGuesses) * 100
    }
    
    var averageTimePerGuess: Double {
        guard totalGuesses > 0 else { return 0 }
        return Double(60 - timeRemaining) / Double(totalGuesses)
    }
}
