import Foundation
import Combine

class ProfileViewModel: ObservableObject {
    @Published var profiles: [Profile] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiURL = "https://namegame.willowtreeapps.com/api/v1.0/profiles"
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        fetchProfiles()
    }
    
    func fetchProfiles() {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: apiURL) else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Profile].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Failed to load profiles: \(error.localizedDescription)"
                        print("API Error: \(error)")
                    }
                },
                receiveValue: { [weak self] profiles in
                    print("Raw API response: \(profiles.count) profiles received")
                    
                    // Filter out profiles without essential fields
                    let validProfiles = profiles.filter { profile in
                        // Must have firstName and lastName
                        !profile.firstName.isEmpty && !profile.lastName.isEmpty &&
                        // Must have a valid headshot URL
                        profile.headshot.url != nil && !profile.headshot.url!.isEmpty
                    }
                    self?.profiles = validProfiles
                    print("Successfully loaded \(validProfiles.count) valid profiles out of \(profiles.count) total")
                    
                    // Log some sample profiles for debugging
                    if !validProfiles.isEmpty {
                        print("Sample profile: \(validProfiles[0].firstName) \(validProfiles[0].lastName)")
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func retryFetch() {
        fetchProfiles()
    }
}
