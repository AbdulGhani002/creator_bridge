import Foundation

@MainActor
public class SessionManager: ObservableObject {
    @Published var user: User?
    @Published var authToken: String?
    @Published var isLoading = false
    @Published var errorMessage: String?

    let apiService: APIService

    private let tokenKey = "creatorbridge.auth.token"
    private let userKey = "creatorbridge.auth.user"

    public init(apiService: APIService = APIService()) {
        self.apiService = apiService
        loadSession()
    }

    var isAuthenticated: Bool {
        return authToken != nil && user != nil
    }

    func loadSession() {
        if let token = UserDefaults.standard.string(forKey: tokenKey) {
            authToken = token
            apiService.authToken = token
        }
        if let data = UserDefaults.standard.data(forKey: userKey),
           let storedUser = try? JSONDecoder().decode(User.self, from: data) {
            user = storedUser
        }
    }

    private func persistSession(token: String, user: User) {
        authToken = token
        self.user = user
        apiService.authToken = token
        UserDefaults.standard.set(token, forKey: tokenKey)
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: userKey)
        }
    }

    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let response = try await apiService.login(LoginRequest(email: email, password: password))
            persistSession(token: response.token, user: response.user)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func signup(_ request: SignupRequest) async {
        isLoading = true
        errorMessage = nil
        do {
            let response = try await apiService.signup(request)
            persistSession(token: response.token, user: response.user)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func demoLogin(role: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let response = try await apiService.demoLogin(role: role)
            persistSession(token: response.token, user: response.user)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func logout() {
        authToken = nil
        user = nil
        apiService.authToken = nil
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: userKey)
    }

    func deleteAccount() async -> Bool {
        isLoading = true
        errorMessage = nil
        do {
            _ = try await apiService.deleteAccount()
            logout()
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
}

