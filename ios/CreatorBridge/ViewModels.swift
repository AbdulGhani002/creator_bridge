import Foundation
import Combine

// MARK: - API Service

class APIService {
    static let shared = APIService()
    
    private let baseURL = "http://localhost:8000"
    private let decoder = JSONDecoder()
    
    init() {
        decoder.dateDecodingStrategy = .iso8601
    }
    
    func get<T: Decodable>(endpoint: String) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        return try decoder.decode(T.self, from: data)
    }
    
    func post<T: Decodable, Body: Encodable>(
        endpoint: String,
        body: Body
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        return try decoder.decode(T.self, from: data)
    }
}

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .invalidResponse: return "Invalid response from server"
        case .decodingError: return "Failed to decode response"
        }
    }
}

// MARK: - API Models

struct CreatorResponse: Codable {
    let id: String
    let name: String
    let specialization: String
    let location: String
    let bio: String
    let avatar: String?
    let verified: Bool
    let followers: Int
    let engagement_rate: Double
    let monthly_reach: Int
    let niches: [String]
    let average_post_price: Int
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, specialization, location, bio, avatar, verified
        case followers, engagement_rate, monthly_reach, niches
        case average_post_price, status
    }
}

struct CampaignResponse: Codable {
    let id: String
    let brand_id: String
    let title: String
    let description: String
    let niche: String
    let budget: Int
    let status: String
    let applications: Int
    let deadline: Date?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case brand_id, title, description, niche, budget, status, applications, deadline
    }
}

struct BrandResponse: Codable {
    let id: String
    let name: String
    let category: String
    let location: String
    let description: String
    let avatar: String?
    let verified: Bool
    let followers: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, category, location, description, avatar, verified, followers
    }
}

struct CreatorStatsResponse: Codable {
    let total_views: Int
    let total_engagements: Int
    let campaigns_completed: Int
    let average_engagement_rate: Double
    
    enum CodingKeys: String, CodingKey {
        case total_views, total_engagements, campaigns_completed
        case average_engagement_rate = "avg_engagement_rate"
    }
}

// MARK: - ViewModels

@MainActor
class CreatorSearchViewModel: ObservableObject {
    @Published var creators: [CreatorResponse] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func searchCreators(query: String = "", niche: String? = nil) async {
        isLoading = true
        errorMessage = nil
        
        var endpoint = "/api/v1/creators"
        if !query.isEmpty || niche != nil {
            var params: [String] = []
            if !query.isEmpty {
                params.append("q=\(query.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")")
            }
            if let niche = niche {
                params.append("niche=\(niche)")
            }
            endpoint += "?" + params.joined(separator: "&")
        }
        
        do {
            let response: [CreatorResponse] = try await APIService.shared.get(endpoint: endpoint)
            self.creators = response
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

@MainActor
class CreatorProfileViewModel: ObservableObject {
    @Published var creator: CreatorResponse?
    @Published var stats: CreatorStatsResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadCreator(id: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let creator: CreatorResponse = try await APIService.shared.get(endpoint: "/api/v1/creators/\(id)")
            let stats: CreatorStatsResponse = try await APIService.shared.get(endpoint: "/api/v1/creators/\(id)/stats")
            
            self.creator = creator
            self.stats = stats
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

@MainActor
class CampaignsViewModel: ObservableObject {
    @Published var campaigns: [CampaignResponse] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadCampaigns(niche: String? = nil, status: String? = nil) async {
        isLoading = true
        errorMessage = nil
        
        var endpoint = "/api/v1/campaigns"
        var params: [String] = []
        
        if let niche = niche {
            params.append("niche=\(niche)")
        }
        if let status = status {
            params.append("status=\(status)")
        }
        
        if !params.isEmpty {
            endpoint += "?" + params.joined(separator: "&")
        }
        
        do {
            let response: [CampaignResponse] = try await APIService.shared.get(endpoint: endpoint)
            self.campaigns = response
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

@MainActor
class BrandViewModel: ObservableObject {
    @Published var brand: BrandResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadBrand(id: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let brand: BrandResponse = try await APIService.shared.get(endpoint: "/api/v1/brands/\(id)")
            self.brand = brand
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
