import Foundation

@MainActor
class ProfileStore: ObservableObject {
    @Published var creatorProfile: CreatorProfile?
    @Published var brandProfile: BrandProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadProfile(session: SessionManager) async {
        guard let user = session.user else { return }
        isLoading = true
        errorMessage = nil
        do {
            if user.role == .creator {
                let profile = try await session.apiService.getCreatorProfileByUser(id: user.id)
                creatorProfile = profile
            } else {
                let profile = try await session.apiService.getBrandProfileByUser(id: user.id)
                brandProfile = profile
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
