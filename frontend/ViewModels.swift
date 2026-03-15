import Foundation
import Combine

// MARK: - Campaign List View Model

@MainActor
class CampaignListViewModel: NSObject, ObservableObject {
    
    // MARK: - Published Properties (UI State)
    
    @Published var campaigns: [Campaign] = []
    @Published var isLoading = false
    @Published var error: NetworkError?
    @Published var hasError = false
    
    // Search & Filter Properties
    @Published var selectedNiche: NicheType?
    @Published var selectedLocation: String = ""
    @Published var minBudget: Double?
    @Published var maxBudget: Double?
    @Published var selectedStatus: CampaignStatus = .open
    
    // Pagination
    @Published var currentPage = 0
    private let pageSize = 20
    private var totalCount = 0
    var hasMorePages: Bool {
        (currentPage + 1) * pageSize < totalCount
    }
    
    // MARK: - Private Properties
    
    private let apiService: APIService
    private var cancellables = Set<AnyCancellable>()
    private var searchDebounceTimer: Timer?
    private var currentTask: Task<Void, Never>?
    
    // MARK: - Initialization
    
    init(apiService: APIService = APIService()) {
        self.apiService = apiService
        super.init()
        setupSearchDebouncing()
    }
    
    // MARK: - Public Methods
    
    /// Load campaigns with current filters
    func loadCampaigns() {
        currentTask?.cancel()
        
        currentTask = Task {
            do {
                isLoading = true
                error = nil
                hasError = false
                
                let skip = currentPage * pageSize
                
                let response = try await apiService.searchCampaigns(
                    niche: selectedNiche,
                    location: selectedLocation.isEmpty ? nil : selectedLocation,
                    minBudget: minBudget,
                    maxBudget: maxBudget,
                    status: selectedStatus,
                    skip: skip,
                    limit: pageSize
                )
                
                if currentPage == 0 {
                    campaigns = response.campaigns
                } else {
                    campaigns.append(contentsOf: response.campaigns)
                }
                
                totalCount = response.total
                isLoading = false
                
            } catch let networkError as NetworkError {
                handleError(networkError)
            } catch {
                handleError(.networkError(error))
            }
        }
    }
    
    /// Load campaigns for first page
    func loadInitialCampaigns() {
        currentPage = 0
        campaigns = []
        totalCount = 0
        loadCampaigns()
    }
    
    /// Load next page of campaigns
    func loadMoreCampaigns() {
        guard hasMorePages && !isLoading else { return }
        currentPage += 1
        loadCampaigns()
    }
    
    /// Reload campaigns with current filters
    func refreshCampaigns() {
        loadInitialCampaigns()
    }
    
    /// Filter by niche
    func filterByNiche(_ niche: NicheType?) {
        selectedNiche = niche
        triggerSearch()
    }
    
    /// Filter by location
    func filterByLocation(_ location: String) {
        selectedLocation = location
        triggerSearch()
    }
    
    /// Filter by budget range
    func filterByBudget(min: Double?, max: Double?) {
        minBudget = min
        maxBudget = max
        triggerSearch()
    }
    
    /// Clear all filters
    func clearFilters() {
        selectedNiche = nil
        selectedLocation = ""
        minBudget = nil
        maxBudget = nil
        selectedStatus = .open
        loadInitialCampaigns()
    }
    
    /// Dismiss error
    func dismissError() {
        error = nil
        hasError = false
    }
    
    // MARK: - Private Methods
    
    private func setupSearchDebouncing() {
        // This helps prevent excessive API calls while filtering
        // Can be extended to observe filter changes
    }
    
    private func triggerSearch() {
        // Debounce search to prevent excessive API calls
        searchDebounceTimer?.invalidate()
        
        searchDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            self?.loadInitialCampaigns()
        }
    }
    
    private func handleError(_ error: NetworkError) {
        self.error = error
        self.hasError = true
        self.isLoading = false
        
        // Log error for debugging
        print("❌ Campaign List Error: \(error.errorDescription ?? "Unknown error")")
    }
    
    deinit {
        currentTask?.cancel()
        searchDebounceTimer?.invalidate()
    }
}

// MARK: - Creator Search View Model

@MainActor
class CreatorSearchViewModel: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var creators: [CreatorProfile] = []
    @Published var isLoading = false
    @Published var error: NetworkError?
    @Published var hasError = false
    
    // Search & Filter Properties
    @Published var selectedNiche: NicheType?
    @Published var searchLocation: String = ""
    @Published var minFollowers: Int?
    @Published var maxFollowers: Int?
    @Published var subscriptionTier: String?
    @Published var minRating: Double?
    @Published var platform: String?
    
    // Pagination
    @Published var currentPage = 0
    private let pageSize = 20
    private var totalCount = 0
    var hasMorePages: Bool {
        (currentPage + 1) * pageSize < totalCount
    }
    
    // MARK: - Private Properties
    
    private let apiService: APIService
    private var cancellables = Set<AnyCancellable>()
    private var searchDebounceTimer: Timer?
    private var currentTask: Task<Void, Never>?
    
    // MARK: - Initialization
    
    init(apiService: APIService = APIService()) {
        self.apiService = apiService
        super.init()
    }
    
    // MARK: - Public Methods
    
    /// Search creators with current filters
    func searchCreators() {
        currentTask?.cancel()
        
        currentTask = Task {
            do {
                isLoading = true
                error = nil
                hasError = false
                
                let skip = currentPage * pageSize
                
                let response = try await apiService.searchCreators(
                    niche: selectedNiche,
                    location: searchLocation.isEmpty ? nil : searchLocation,
                    platform: platform,
                    minFollowers: minFollowers,
                    maxFollowers: maxFollowers,
                    subscriptionTier: subscriptionTier,
                    minRating: minRating,
                    skip: skip,
                    limit: pageSize
                )
                
                if currentPage == 0 {
                    creators = response.creators
                } else {
                    creators.append(contentsOf: response.creators)
                }
                
                totalCount = response.total
                isLoading = false
                
            } catch let networkError as NetworkError {
                handleError(networkError)
            } catch {
                handleError(.networkError(error))
            }
        }
    }
    
    /// Search creators by location (competitive advantage)
    func searchCreatorsByLocation(_ location: String, niche: NicheType? = nil) {
        currentTask?.cancel()
        searchLocation = location
        selectedNiche = niche
        currentPage = 0
        
        currentTask = Task {
            do {
                isLoading = true
                error = nil
                hasError = false
                
                let response = try await apiService.getCreatorsByLocation(
                    location: location,
                    niche: niche,
                    skip: 0,
                    limit: pageSize
                )
                
                creators = response.creators
                totalCount = response.total
                isLoading = false
                
            } catch let networkError as NetworkError {
                handleError(networkError)
            } catch {
                handleError(.networkError(error))
            }
        }
    }
    
    func loadInitialSearch() {
        currentPage = 0
        creators = []
        totalCount = 0
        searchCreators()
    }
    
    func loadMoreCreators() {
        guard hasMorePages && !isLoading else { return }
        currentPage += 1
        searchCreators()
    }
    
    func refreshSearch() {
        loadInitialSearch()
    }
    
    func clearFilters() {
        selectedNiche = nil
        searchLocation = ""
        minFollowers = nil
        maxFollowers = nil
        subscriptionTier = nil
        minRating = nil
        platform = nil
        creators = []
        totalCount = 0
    }
    
    func dismissError() {
        error = nil
        hasError = false
    }
    
    // MARK: - Private Methods
    
    private func handleError(_ error: NetworkError) {
        self.error = error
        self.hasError = true
        self.isLoading = false
        print("❌ Creator Search Error: \(error.errorDescription ?? "Unknown error")")
    }
    
    deinit {
        currentTask?.cancel()
        searchDebounceTimer?.invalidate()
    }
}

// MARK: - Analytics View Models

@MainActor
class CreatorAnalyticsViewModel: ObservableObject {
    @Published var analytics: CreatorAnalytics?
    @Published var isLoading = false
    @Published var error: NetworkError?

    private let apiService: APIService

    init(apiService: APIService = APIService()) {
        self.apiService = apiService
    }

    func load() {
        Task {
            do {
                isLoading = true
                analytics = try await apiService.getCreatorAnalytics()
            } catch let networkError as NetworkError {
                error = networkError
            } catch {
                error = .networkError(error)
            }
            isLoading = false
        }
    }
}

@MainActor
class BrandAnalyticsViewModel: ObservableObject {
    @Published var analytics: BrandAnalytics?
    @Published var isLoading = false
    @Published var error: NetworkError?

    private let apiService: APIService

    init(apiService: APIService = APIService()) {
        self.apiService = apiService
    }

    func load() {
        Task {
            do {
                isLoading = true
                analytics = try await apiService.getBrandAnalytics()
            } catch let networkError as NetworkError {
                error = networkError
            } catch {
                error = .networkError(error)
            }
            isLoading = false
        }
    }
}

// MARK: - Applications View Model

@MainActor
class ApplicationsViewModel: ObservableObject {
    @Published var applications: [Application] = []
    @Published var isLoading = false
    @Published var error: NetworkError?

    private let apiService: APIService

    init(apiService: APIService = APIService()) {
        self.apiService = apiService
    }

    func loadApplications(campaignId: String? = nil) {
        Task {
            do {
                isLoading = true
                let response = try await apiService.listApplications(campaignId: campaignId)
                applications = response.applications
            } catch let networkError as NetworkError {
                error = networkError
            } catch {
                error = .networkError(error)
            }
            isLoading = false
        }
    }

    func updateStatus(applicationId: String, status: ApplicationStatus) {
        Task {
            do {
                _ = try await apiService.updateApplication(id: applicationId, status: status)
                loadApplications()
            } catch let networkError as NetworkError {
                error = networkError
            } catch {
                error = .networkError(error)
            }
        }
    }
}

// MARK: - Agreements View Model

@MainActor
class AgreementsViewModel: ObservableObject {
    @Published var agreements: [Agreement] = []
    @Published var isLoading = false
    @Published var error: NetworkError?

    private let apiService: APIService

    init(apiService: APIService = APIService()) {
        self.apiService = apiService
    }

    func loadAgreements() {
        Task {
            do {
                isLoading = true
                let response = try await apiService.listAgreements()
                agreements = response.agreements
            } catch let networkError as NetworkError {
                error = networkError
            } catch {
                error = .networkError(error)
            }
            isLoading = false
        }
    }

    func updateAgreement(id: String, update: AgreementUpdateRequest) {
        Task {
            do {
                _ = try await apiService.updateAgreement(id: id, update: update)
                loadAgreements()
            } catch let networkError as NetworkError {
                error = networkError
            } catch {
                error = .networkError(error)
            }
        }
    }
}

// MARK: - Messages View Model

@MainActor
class MessagesViewModel: ObservableObject {
    @Published var threads: [MessageThread] = []
    @Published var messages: [Message] = []
    @Published var isLoading = false
    @Published var error: NetworkError?

    private let apiService: APIService

    init(apiService: APIService = APIService()) {
        self.apiService = apiService
    }

    func loadThreads() {
        Task {
            do {
                isLoading = true
                let response = try await apiService.listThreads()
                threads = response.threads
            } catch let networkError as NetworkError {
                error = networkError
            } catch {
                error = .networkError(error)
            }
            isLoading = false
        }
    }

    func loadMessages(threadId: String) {
        Task {
            do {
                isLoading = true
                let response = try await apiService.listMessages(threadId: threadId)
                messages = response.messages
            } catch let networkError as NetworkError {
                error = networkError
            } catch {
                error = .networkError(error)
            }
            isLoading = false
        }
    }

    func sendMessage(_ payload: MessageCreateRequest) {
        Task {
            do {
                _ = try await apiService.sendMessage(payload)
            } catch let networkError as NetworkError {
                error = networkError
            } catch {
                error = .networkError(error)
            }
        }
    }
}
