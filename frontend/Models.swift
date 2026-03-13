import Foundation

// MARK: - Enums

enum UserRole: String, Codable {
    case creator
    case brand
}

enum PlatformType: String, Codable, CaseIterable {
    case instagram
    case youtube
    case tiktok
    case twitter
    case linkedin
    case blog
    case podcast
    
    var displayName: String {
        switch self {
        case .instagram: return "Instagram"
        case .youtube: return "YouTube"
        case .tiktok: return "TikTok"
        case .twitter: return "Twitter"
        case .linkedin: return "LinkedIn"
        case .blog: return "Blog"
        case .podcast: return "Podcast"
        }
    }
}

enum NicheType: String, Codable, CaseIterable {
    case realEstate = "real_estate"
    case tech
    case fitness
    case beauty
    case finance
    case travel
    case education
    case food
    case lifestyle
    case gaming
    case fashion
    
    var displayName: String {
        switch self {
        case .realEstate: return "Real Estate"
        case .tech: return "Tech"
        case .fitness: return "Fitness"
        case .beauty: return "Beauty"
        case .finance: return "Finance"
        case .travel: return "Travel"
        case .education: return "Education"
        case .food: return "Food"
        case .lifestyle: return "Lifestyle"
        case .gaming: return "Gaming"
        case .fashion: return "Fashion"
        }
    }
}

enum CampaignStatus: String, Codable {
    case open
    case inProgress = "in_progress"
    case closed
    
    var displayName: String {
        switch self {
        case .open: return "Open"
        case .inProgress: return "In Progress"
        case .closed: return "Closed"
        }
    }
}

enum ApplicationStatus: String, Codable {
    case pending
    case accepted
    case rejected
    case completed
    
    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .accepted: return "Accepted"
        case .rejected: return "Rejected"
        case .completed: return "Completed"
        }
    }
}

// MARK: - User Models

struct User: Codable, Identifiable {
    let id: String
    let name: String
    let email: String
    let role: UserRole
    let location: String
    let createdAt: Date?
    let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case email
        case role
        case location
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Creator Models

struct SocialPlatform: Codable, Identifiable {
    let id = UUID()
    let platform: PlatformType
    let handle: String
    let followers: Int
    let engagementRate: Double?
    
    enum CodingKeys: String, CodingKey {
        case platform
        case handle
        case followers
        case engagementRate = "engagement_rate"
    }
}

struct CreatorProfile: Codable, Identifiable {
    let id: String
    let userId: String
    let niche: NicheType
    let bio: String
    let pricingPerPost: Double
    let portfolioUrl: String?
    let socialPlatforms: [SocialPlatform]
    let subscriptionTier: String
    let totalEarnings: Double
    let rating: Double?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId = "user_id"
        case niche
        case bio
        case pricingPerPost = "pricing_per_post"
        case portfolioUrl = "portfolio_url"
        case socialPlatforms = "social_platforms"
        case subscriptionTier = "subscription_tier"
        case totalEarnings = "total_earnings"
        case rating
        case createdAt = "created_at"
    }
    
    // Computed property for total followers
    var totalFollowers: Int {
        socialPlatforms.reduce(0) { $0 + $1.followers }
    }
}

// MARK: - Brand Models

struct BrandProfile: Codable, Identifiable {
    let id: String
    let userId: String
    let companyName: String
    let industry: String
    let companyWebsite: String?
    let companyDescription: String
    let verified: Bool
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId = "user_id"
        case companyName = "company_name"
        case industry
        case companyWebsite = "company_website"
        case companyDescription = "company_description"
        case verified
        case createdAt = "created_at"
    }
}

// MARK: - Campaign Models

struct Campaign: Codable, Identifiable {
    let id: String
    let brandId: String
    let title: String
    let description: String
    let niche: NicheType
    let budget: Double
    let location: String
    let requiredFollowers: Int
    let deliverables: String
    let deadline: Date
    let status: CampaignStatus
    let applicationsCount: Int
    let createdAt: Date
    let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case brandId = "brand_id"
        case title
        case description
        case niche
        case budget
        case location
        case requiredFollowers = "required_followers"
        case deliverables
        case deadline
        case status
        case applicationsCount = "applications_count"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // Computed property for days remaining
    var daysRemaining: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: deadline)
        return components.day ?? 0
    }
    
    // Computed property for is deadline passed
    var isDeadlinePassed: Bool {
        Date() > deadline
    }
}

// MARK: - Search Response Models

struct CampaignSearchResponse: Codable {
    let campaigns: [Campaign]
    let total: Int
    let skip: Int
    let limit: Int
    
    var hasMore: Bool {
        skip + limit < total
    }
}

struct CreatorSearchResponse: Codable {
    let creators: [CreatorProfile]
    let total: Int
    let skip: Int
    let limit: Int
    
    var hasMore: Bool {
        skip + limit < total
    }
}

// MARK: - Request Models

struct CampaignCreateRequest: Codable {
    let title: String
    let description: String
    let niche: NicheType
    let budget: Double
    let location: String
    let requiredFollowers: Int
    let deliverables: String
    let deadline: Date
    
    enum CodingKeys: String, CodingKey {
        case title
        case description
        case niche
        case budget
        case location
        case requiredFollowers = "required_followers"
        case deliverables
        case deadline
    }
}
