import Foundation
import Combine

// MARK: - Network Error Types

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case invalidData
    case decodingError(Error)
    case serverError(Int, String)
    case networkError(Error)
    case unauthorized
    case notFound
    case badRequest(String)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .invalidData:
            return "Invalid data received"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .serverError(let statusCode, let message):
            return "Server error (\(statusCode)): \(message)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .unauthorized:
            return "Unauthorized - Please login again"
        case .notFound:
            return "Resource not found"
        case .badRequest(let message):
            return "Bad request: \(message)"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}

// MARK: - HTTP Methods

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

// MARK: - API Service

class APIService {
    
    // MARK: - Properties
    
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    // Token storage for authentication
    var authToken: String?
    
    // MARK: - Initialization
    
    init(
        baseURL: String = ProcessInfo.processInfo.environment["API_BASE_URL"] ?? "http://localhost:8000",
        session: URLSession = .shared
    ) {
        guard let url = URL(string: baseURL) else {
            fatalError("Invalid base URL")
        }
        self.baseURL = url
        self.session = session
        
        // Configure decoder with custom date strategy
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
        
        // Configure encoder
        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
    }
    
    // MARK: - Generic Request Method
    
    /// Generic method to perform HTTP requests
    /// - Parameters:
    ///   - path: API endpoint path
    ///   - method: HTTP method
    ///   - body: Optional request body (Codable)
    ///   - headers: Optional custom headers
    /// - Returns: Decoded response of type T
    func request<T: Decodable>(
        path: String,
        method: HTTPMethod = .get,
        body: Encodable? = nil,
        headers: [String: String]? = nil
    ) async throws -> T {
        
        // Build URL
        let url = buildURL(path: path)
        
        // Create URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // Set default headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add authentication token if available
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Add custom headers
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        // Encode body if provided
        if let body = body {
            request.httpBody = try encoder.encode(body)
        }
        
        // Perform request
        let (data, response) = try await session.data(for: request)
        
        // Validate response
        try validateResponse(response)
        
        // Decode response
        do {
            let decodedResponse = try decoder.decode(T.self, from: data)
            return decodedResponse
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
    
    /// Perform request without response body (for delete, etc.)
    func request(
        path: String,
        method: HTTPMethod = .delete,
        headers: [String: String]? = nil
    ) async throws {
        
        let url = buildURL(path: path)
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        let (_, response) = try await session.data(for: request)
        try validateResponse(response)
    }
    
    // MARK: - Campaign Endpoints
    
    func createCampaign(_ campaign: CampaignCreateRequest) async throws -> GenericResponse {
        try await request(
            path: "/api/v1/campaigns",
            method: .post,
            body: campaign
        )
    }
    
    func searchCampaigns(
        niche: NicheType? = nil,
        location: String? = nil,
        minBudget: Double? = nil,
        maxBudget: Double? = nil,
        status: CampaignStatus = .open,
        skip: Int = 0,
        limit: Int = 20
    ) async throws -> CampaignSearchResponse {
        
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "skip", value: String(skip)),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "status", value: status.rawValue)
        ]
        
        if let niche = niche {
            queryItems.append(URLQueryItem(name: "niche", value: niche.rawValue))
        }
        
        if let location = location {
            queryItems.append(URLQueryItem(name: "location", value: location))
        }
        
        if let minBudget = minBudget {
            queryItems.append(URLQueryItem(name: "min_budget", value: String(minBudget)))
        }
        
        if let maxBudget = maxBudget {
            queryItems.append(URLQueryItem(name: "max_budget", value: String(maxBudget)))
        }
        
        let path = buildQueryPath("/api/v1/campaigns/search", queryItems: queryItems)
        
        let response: CampaignSearchResponse = try await request(path: path)
        return response
    }
    
    func getCampaignDetail(id: String) async throws -> Campaign {
        try await request(path: "/api/v1/campaigns/\(id)")
    }

    func updateCampaign(id: String, update: CampaignUpdateRequest) async throws -> GenericResponse {
        try await request(path: "/api/v1/campaigns/\(id)", method: .put, body: update)
    }
    
    // MARK: - Creator Endpoints
    
    func searchCreators(
        niche: NicheType? = nil,
        location: String? = nil,
        platform: String? = nil,
        minFollowers: Int? = nil,
        maxFollowers: Int? = nil,
        subscriptionTier: String? = nil,
        minRating: Double? = nil,
        skip: Int = 0,
        limit: Int = 20
    ) async throws -> CreatorSearchResponse {
        
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "skip", value: String(skip)),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        
        if let niche = niche {
            queryItems.append(URLQueryItem(name: "niche", value: niche.rawValue))
        }
        
        if let location = location {
            queryItems.append(URLQueryItem(name: "location", value: location))
        }

        if let platform = platform {
            queryItems.append(URLQueryItem(name: "platform", value: platform))
        }
        
        if let minFollowers = minFollowers {
            queryItems.append(URLQueryItem(name: "min_followers", value: String(minFollowers)))
        }
        
        if let maxFollowers = maxFollowers {
            queryItems.append(URLQueryItem(name: "max_followers", value: String(maxFollowers)))
        }
        
        if let subscriptionTier = subscriptionTier {
            queryItems.append(URLQueryItem(name: "subscription_tier", value: subscriptionTier))
        }
        
        if let minRating = minRating {
            queryItems.append(URLQueryItem(name: "min_rating", value: String(minRating)))
        }
        
        let path = buildQueryPath("/api/v1/creators/search", queryItems: queryItems)
        
        let response: CreatorSearchResponse = try await request(path: path)
        return response
    }
    
    func getCreatorsByLocation(
        location: String,
        niche: NicheType? = nil,
        skip: Int = 0,
        limit: Int = 20
    ) async throws -> CreatorSearchResponse {
        
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "skip", value: String(skip)),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        
        if let niche = niche {
            queryItems.append(URLQueryItem(name: "niche", value: niche.rawValue))
        }
        
        let path = buildQueryPath("/api/v1/creators/by-location/\(location)", queryItems: queryItems)
        
        let response: CreatorSearchResponse = try await request(path: path)
        return response
    }

    func createCreatorProfile(_ profile: CreatorProfileCreateRequest) async throws -> GenericResponse {
        try await request(path: "/api/v1/creators", method: .post, body: profile)
    }

    func updateCreatorProfile(id: String, update: CreatorProfileUpdateRequest) async throws -> GenericResponse {
        try await request(path: "/api/v1/creators/\(id)", method: .put, body: update)
    }

    func getCreatorProfileByUser(id: String) async throws -> CreatorProfile {
        try await request(path: "/api/v1/creators/user/\(id)")
    }

    // MARK: - Brand Endpoints

    func createBrandProfile(_ profile: BrandProfileCreateRequest) async throws -> GenericResponse {
        try await request(path: "/api/v1/brands", method: .post, body: profile)
    }

    func updateBrandProfile(id: String, update: BrandProfileUpdateRequest) async throws -> GenericResponse {
        try await request(path: "/api/v1/brands/\(id)", method: .put, body: update)
    }

    func getBrandProfile(id: String) async throws -> BrandProfile {
        try await request(path: "/api/v1/brands/\(id)")
    }

    func getBrandProfileByUser(id: String) async throws -> BrandProfile {
        try await request(path: "/api/v1/brands/user/\(id)")
    }

    // MARK: - Auth Endpoints

    func signup(_ payload: SignupRequest) async throws -> AuthResponse {
        try await request(path: "/api/v1/auth/signup", method: .post, body: payload)
    }

    func login(_ payload: LoginRequest) async throws -> AuthResponse {
        try await request(path: "/api/v1/auth/login", method: .post, body: payload)
    }

    func demoLogin(role: String) async throws -> AuthResponse {
        let path = buildQueryPath("/api/v1/auth/demo", queryItems: [
            URLQueryItem(name: "role", value: role)
        ])
        return try await request(path: path, method: .post)
    }

    func getMe() async throws -> User {
        try await request(path: "/api/v1/auth/me")
    }

    func deleteAccount() async throws -> GenericResponse {
        try await request(path: "/api/v1/auth/account", method: .delete)
    }

    // MARK: - Applications

    func createApplication(_ payload: ApplicationCreateRequest) async throws -> GenericResponse {
        try await request(path: "/api/v1/applications", method: .post, body: payload)
    }

    func listApplications(
        campaignId: String? = nil,
        creatorId: String? = nil,
        brandId: String? = nil,
        status: ApplicationStatus? = nil,
        skip: Int = 0,
        limit: Int = 20
    ) async throws -> ApplicationsResponse {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "skip", value: String(skip)),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        if let campaignId = campaignId {
            queryItems.append(URLQueryItem(name: "campaign_id", value: campaignId))
        }
        if let creatorId = creatorId {
            queryItems.append(URLQueryItem(name: "creator_id", value: creatorId))
        }
        if let brandId = brandId {
            queryItems.append(URLQueryItem(name: "brand_id", value: brandId))
        }
        if let status = status {
            queryItems.append(URLQueryItem(name: "status", value: status.rawValue))
        }
        let path = buildQueryPath("/api/v1/applications", queryItems: queryItems)
        return try await request(path: path)
    }

    func updateApplication(id: String, status: ApplicationStatus) async throws -> GenericResponse {
        let payload = ApplicationUpdateRequest(status: status)
        return try await request(path: "/api/v1/applications/\(id)", method: .put, body: payload)
    }

    // MARK: - Agreements

    func createAgreement(_ payload: AgreementCreateRequest) async throws -> GenericResponse {
        try await request(path: "/api/v1/agreements", method: .post, body: payload)
    }

    func listAgreements(
        campaignId: String? = nil,
        creatorId: String? = nil,
        brandId: String? = nil,
        status: AgreementStatus? = nil,
        skip: Int = 0,
        limit: Int = 20
    ) async throws -> AgreementsResponse {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "skip", value: String(skip)),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        if let campaignId = campaignId {
            queryItems.append(URLQueryItem(name: "campaign_id", value: campaignId))
        }
        if let creatorId = creatorId {
            queryItems.append(URLQueryItem(name: "creator_id", value: creatorId))
        }
        if let brandId = brandId {
            queryItems.append(URLQueryItem(name: "brand_id", value: brandId))
        }
        if let status = status {
            queryItems.append(URLQueryItem(name: "status", value: status.rawValue))
        }
        let path = buildQueryPath("/api/v1/agreements", queryItems: queryItems)
        return try await request(path: path)
    }

    func updateAgreement(id: String, update: AgreementUpdateRequest) async throws -> GenericResponse {
        return try await request(path: "/api/v1/agreements/\(id)", method: .put, body: update)
    }

    // MARK: - Messages

    func listThreads(skip: Int = 0, limit: Int = 20) async throws -> ThreadsResponse {
        let path = buildQueryPath("/api/v1/messages/threads", queryItems: [
            URLQueryItem(name: "skip", value: String(skip)),
            URLQueryItem(name: "limit", value: String(limit))
        ])
        return try await request(path: path)
    }

    func listMessages(threadId: String, skip: Int = 0, limit: Int = 50) async throws -> MessagesResponse {
        let path = buildQueryPath("/api/v1/messages", queryItems: [
            URLQueryItem(name: "thread_id", value: threadId),
            URLQueryItem(name: "skip", value: String(skip)),
            URLQueryItem(name: "limit", value: String(limit))
        ])
        return try await request(path: path)
    }

    func sendMessage(_ payload: MessageCreateRequest) async throws -> GenericResponse {
        return try await request(path: "/api/v1/messages", method: .post, body: payload)
    }

    func markMessageRead(id: String) async throws -> GenericResponse {
        return try await request(path: "/api/v1/messages/\(id)/read", method: .put)
    }

    // MARK: - Reviews

    func createReview(_ payload: ReviewCreateRequest) async throws -> GenericResponse {
        return try await request(path: "/api/v1/reviews", method: .post, body: payload)
    }

    func listReviews(revieweeId: String? = nil, revieweeRole: String? = nil, skip: Int = 0, limit: Int = 20) async throws -> ReviewsResponse {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "skip", value: String(skip)),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        if let revieweeId = revieweeId {
            queryItems.append(URLQueryItem(name: "reviewee_id", value: revieweeId))
        }
        if let revieweeRole = revieweeRole {
            queryItems.append(URLQueryItem(name: "reviewee_role", value: revieweeRole))
        }
        let path = buildQueryPath("/api/v1/reviews", queryItems: queryItems)
        return try await request(path: path)
    }

    // MARK: - Analytics

    func getCreatorAnalytics() async throws -> CreatorAnalytics {
        try await request(path: "/api/v1/analytics/creator/me")
    }

    func getBrandAnalytics() async throws -> BrandAnalytics {
        try await request(path: "/api/v1/analytics/brand/me")
    }

    // MARK: - Plans & Subscriptions

    func getPlans() async throws -> PlansResponse {
        try await request(path: "/api/v1/plans")
    }

    func getSubscription() async throws -> SubscriptionResponse {
        try await request(path: "/api/v1/subscriptions/me")
    }

    func updateSubscription(_ payload: SubscriptionUpdateRequest) async throws -> GenericResponse {
        try await request(path: "/api/v1/subscriptions/ios", method: .post, body: payload)
    }

    // MARK: - Moderation

    func report(_ payload: ReportCreateRequest) async throws -> GenericResponse {
        try await request(path: "/api/v1/reports", method: .post, body: payload)
    }

    func blockUser(blockedId: String) async throws -> GenericResponse {
        return try await request(path: "/api/v1/blocks", method: .post, body: BlockCreateRequest(blockedId: blockedId))
    }

    func listBlocks() async throws -> BlocksResponse {
        try await request(path: "/api/v1/blocks")
    }

    func unblock(blockId: String) async throws -> GenericResponse {
        try await request(path: "/api/v1/blocks/\(blockId)", method: .delete)
    }
    
    // MARK: - Helper Methods
    
    private func buildURL(path: String) -> URL {
        baseURL.appendingPathComponent(path)
    }
    
    private func buildQueryPath(_ path: String, queryItems: [URLQueryItem]) -> String {
        var components = URLComponents(string: path) ?? URLComponents()
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        return components.string ?? path
    }
    
    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return
        case 400:
            throw NetworkError.badRequest("Bad request")
        case 401:
            throw NetworkError.unauthorized
        case 404:
            throw NetworkError.notFound
        case 500...599:
            throw NetworkError.serverError(
                httpResponse.statusCode,
                HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
            )
        default:
            throw NetworkError.serverError(
                httpResponse.statusCode,
                HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
            )
        }
    }
}
