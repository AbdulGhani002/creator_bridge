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
        baseURL: String = "https://creator-bridge.apex-logic.net",
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
    
    func createCampaign(_ campaign: CampaignCreateRequest) async throws -> Campaign {
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
    
    // MARK: - Creator Endpoints
    
    func searchCreators(
        niche: NicheType? = nil,
        location: String? = nil,
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
