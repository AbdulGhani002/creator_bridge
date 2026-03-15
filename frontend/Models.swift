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
    case withdrawn
    
    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .accepted: return "Accepted"
        case .rejected: return "Rejected"
        case .completed: return "Completed"
        }
    }
}

enum AgreementStatus: String, Codable {
    case draft
    case sent
    case accepted
    case declined
    case completed
    case canceled
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
    let name: String?
    let niche: NicheType?
    let bio: String
    let location: String?
    let pricingPerPost: Double?
    let portfolioUrl: String?
    let socialPlatforms: [SocialPlatform]?
    let subscriptionTier: String?
    let totalEarnings: Double?
    let rating: Double?
    let createdAt: Date
    let followersCount: Int?
    let engagementRate: Double?
    let monthlyReach: Int?
    let platforms: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId = "user_id"
        case name
        case niche
        case bio
        case location
        case pricingPerPost = "pricing_per_post"
        case portfolioUrl = "portfolio_url"
        case socialPlatforms = "social_platforms"
        case subscriptionTier = "subscription_tier"
        case totalEarnings = "total_earnings"
        case rating
        case createdAt = "created_at"
        case followersCount = "followers_count"
        case engagementRate = "engagement_rate"
        case monthlyReach = "monthly_reach"
        case platforms
    }
    
    // Computed property for total followers
    var totalFollowers: Int {
        socialPlatforms?.reduce(0) { $0 + $1.followers } ?? (followersCount ?? 0)
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
    let location: String?
    let rating: Double?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId = "user_id"
        case companyName = "company_name"
        case industry
        case companyWebsite = "company_website"
        case companyDescription = "company_description"
        case verified
        case location
        case rating
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

// MARK: - Generic Response
struct GenericResponse: Codable {
    let status: String
    let message: String?
}

// MARK: - Auth Models

struct AuthResponse: Codable {
    let token: String
    let user: User
}

// MARK: - Applications

struct Application: Codable, Identifiable {
    let id: String
    let campaignId: String
    let creatorId: String
    let brandId: String
    let proposal: String
    let status: ApplicationStatus
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case campaignId = "campaign_id"
        case creatorId = "creator_id"
        case brandId = "brand_id"
        case proposal
        case status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct ApplicationCreateRequest: Codable {
    let campaignId: String
    let proposal: String

    enum CodingKeys: String, CodingKey {
        case campaignId = "campaign_id"
        case proposal
    }
}

struct ApplicationUpdateRequest: Codable {
    let status: ApplicationStatus
}

struct ApplicationsResponse: Codable {
    let applications: [Application]
    let total: Int
    let skip: Int
    let limit: Int
}

// MARK: - Agreements

struct Agreement: Codable, Identifiable {
    let id: String
    let campaignId: String
    let creatorId: String
    let brandId: String
    let deliverables: String
    let deadline: Date?
    let paymentAmount: Double
    let status: AgreementStatus
    let terms: String?
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case campaignId = "campaign_id"
        case creatorId = "creator_id"
        case brandId = "brand_id"
        case deliverables
        case deadline
        case paymentAmount = "payment_amount"
        case status
        case terms
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct AgreementCreateRequest: Codable {
    let campaignId: String
    let creatorId: String
    let deliverables: String
    let deadline: Date?
    let paymentAmount: Double
    let terms: String?

    enum CodingKeys: String, CodingKey {
        case campaignId = "campaign_id"
        case creatorId = "creator_id"
        case deliverables
        case deadline
        case paymentAmount = "payment_amount"
        case terms
    }
}

struct AgreementUpdateRequest: Codable {
    let deliverables: String?
    let deadline: Date?
    let paymentAmount: Double?
    let terms: String?
    let status: AgreementStatus?

    enum CodingKeys: String, CodingKey {
        case deliverables
        case deadline
        case paymentAmount = "payment_amount"
        case terms
        case status
    }
}

struct AgreementsResponse: Codable {
    let agreements: [Agreement]
    let total: Int
    let skip: Int
    let limit: Int
}

// MARK: - Messages

struct Message: Codable, Identifiable {
    let id: String
    let threadId: String
    let fromId: String
    let toId: String
    let content: String
    let timestamp: Date?
    let read: Bool?
    let readBy: [String]?
    let campaignId: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case threadId = "thread_id"
        case fromId = "from_id"
        case toId = "to_id"
        case content
        case timestamp
        case read
        case readBy = "read_by"
        case campaignId = "campaign_id"
    }
}

struct MessageThread: Codable, Identifiable {
    var id: String { threadId }
    let threadId: String
    let lastMessage: Message

    enum CodingKeys: String, CodingKey {
        case threadId = "thread_id"
        case lastMessage = "last_message"
    }
}

struct MessageCreateRequest: Codable {
    let toId: String
    let campaignId: String?
    let content: String

    enum CodingKeys: String, CodingKey {
        case toId = "to_id"
        case campaignId = "campaign_id"
        case content
    }
}

struct ThreadsResponse: Codable {
    let threads: [MessageThread]
    let count: Int
}

struct MessagesResponse: Codable {
    let messages: [Message]
    let count: Int
}

// MARK: - Reviews

struct Review: Codable, Identifiable {
    let id: String
    let revieweeId: String
    let revieweeRole: String
    let reviewerId: String
    let rating: Double
    let comment: String?
    let campaignId: String?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case revieweeId = "reviewee_id"
        case revieweeRole = "reviewee_role"
        case reviewerId = "reviewer_id"
        case rating
        case comment
        case campaignId = "campaign_id"
        case createdAt = "created_at"
    }
}

struct ReviewCreateRequest: Codable {
    let revieweeId: String
    let revieweeRole: String
    let rating: Double
    let comment: String?
    let campaignId: String?

    enum CodingKeys: String, CodingKey {
        case revieweeId = "reviewee_id"
        case revieweeRole = "reviewee_role"
        case rating
        case comment
        case campaignId = "campaign_id"
    }
}

struct ReviewsResponse: Codable {
    let reviews: [Review]
    let total: Int
    let skip: Int
    let limit: Int
}

// MARK: - Subscriptions & Plans

struct Plan: Codable, Identifiable {
    let id: String?
    let name: String
    let price: Double
    let period: String
    let description: String
    let features: [String]
    let highlighted: Bool

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case price
        case period
        case description
        case features
        case highlighted
    }
}

struct PlansResponse: Codable {
    let plans: [Plan]
    let count: Int
}

struct Subscription: Codable, Identifiable {
    let id: String?
    let userId: String?
    let productId: String?
    let transactionId: String?
    let expiresAt: Date?
    let plan: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId = "user_id"
        case productId = "product_id"
        case transactionId = "transaction_id"
        case expiresAt = "expires_at"
        case plan
    }
}

struct SubscriptionResponse: Codable {
    let subscription: Subscription?
}

struct SubscriptionUpdateRequest: Codable {
    let productId: String
    let transactionId: String
    let expiresAt: Date?
    let plan: String

    enum CodingKeys: String, CodingKey {
        case productId = "product_id"
        case transactionId = "transaction_id"
        case expiresAt = "expires_at"
        case plan
    }
}

// MARK: - Analytics

struct CreatorAnalytics: Codable {
    let creatorId: String
    let applications: Int
    let acceptedApplications: Int
    let agreements: Int
    let completedAgreements: Int
    let totalEarnings: Double
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case creatorId = "creator_id"
        case applications
        case acceptedApplications = "accepted_applications"
        case agreements
        case completedAgreements = "completed_agreements"
        case totalEarnings = "total_earnings"
        case updatedAt = "updated_at"
    }
}

struct BrandAnalytics: Codable {
    let brandId: String
    let campaigns: Int
    let openCampaigns: Int
    let applications: Int
    let acceptedApplications: Int
    let agreements: Int
    let completedAgreements: Int
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case brandId = "brand_id"
        case campaigns
        case openCampaigns = "open_campaigns"
        case applications
        case acceptedApplications = "accepted_applications"
        case agreements
        case completedAgreements = "completed_agreements"
        case updatedAt = "updated_at"
    }
}

// MARK: - Moderation

struct ReportCreateRequest: Codable {
    let targetType: String
    let targetId: String
    let reason: String
    let details: String?

    enum CodingKeys: String, CodingKey {
        case targetType = "target_type"
        case targetId = "target_id"
        case reason
        case details
    }
}

struct BlockCreateRequest: Codable {
    let blockedId: String

    enum CodingKeys: String, CodingKey {
        case blockedId = "blocked_id"
    }
}

struct Block: Codable, Identifiable {
    let id: String
    let blockerId: String
    let blockedId: String
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case blockerId = "blocker_id"
        case blockedId = "blocked_id"
        case createdAt = "created_at"
    }
}

struct BlocksResponse: Codable {
    let blocks: [Block]
    let count: Int
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

struct CampaignUpdateRequest: Codable {
    let title: String?
    let description: String?
    let budget: Double?
    let location: String?
    let requiredFollowers: Int?
    let deliverables: String?
    let deadline: Date?
    let status: CampaignStatus?

    enum CodingKeys: String, CodingKey {
        case title
        case description
        case budget
        case location
        case requiredFollowers = "required_followers"
        case deliverables
        case deadline
        case status
    }
}

// MARK: - Creator & Brand Profile Requests

struct CreatorProfileCreateRequest: Codable {
    let name: String
    let bio: String
    let niche: NicheType?
    let location: String
    let followersCount: Int?
    let socialLinks: [String: String]?
    let portfolioUrl: String?
    let pricingPerPost: Double?
    let platforms: [String]?

    enum CodingKeys: String, CodingKey {
        case name
        case bio
        case niche
        case location
        case followersCount = "followers_count"
        case socialLinks = "social_links"
        case portfolioUrl = "portfolio_url"
        case pricingPerPost = "pricing_per_post"
        case platforms
    }
}

struct CreatorProfileUpdateRequest: Codable {
    let bio: String?
    let niche: NicheType?
    let location: String?
    let followersCount: Int?
    let socialLinks: [String: String]?
    let subscriptionTier: String?
    let pricingPerPost: Double?
    let rating: Double?
    let platforms: [String]?

    enum CodingKeys: String, CodingKey {
        case bio
        case niche
        case location
        case followersCount = "followers_count"
        case socialLinks = "social_links"
        case subscriptionTier = "subscription_tier"
        case pricingPerPost = "pricing_per_post"
        case rating
        case platforms
    }
}

struct BrandProfileCreateRequest: Codable {
    let companyName: String
    let industry: String?
    let companyWebsite: String?
    let companyDescription: String?
    let location: String?

    enum CodingKeys: String, CodingKey {
        case companyName = "company_name"
        case industry
        case companyWebsite = "company_website"
        case companyDescription = "company_description"
        case location
    }
}

struct BrandProfileUpdateRequest: Codable {
    let companyName: String?
    let industry: String?
    let companyWebsite: String?
    let companyDescription: String?
    let verified: Bool?
    let location: String?

    enum CodingKeys: String, CodingKey {
        case companyName = "company_name"
        case industry
        case companyWebsite = "company_website"
        case companyDescription = "company_description"
        case verified
        case location
    }
}

// MARK: - Auth Requests

struct SignupRequest: Codable {
    let name: String
    let email: String
    let password: String
    let role: String
    let location: String
    let creatorProfile: CreatorProfileCreateRequest?
    let brandProfile: BrandProfileCreateRequest?

    enum CodingKeys: String, CodingKey {
        case name
        case email
        case password
        case role
        case location
        case creatorProfile = "creator_profile"
        case brandProfile = "brand_profile"
    }
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

// MARK: - Generic Response

struct GenericResponse: Codable {
    let status: String?
    let message: String?
    let id: String?
}

// MARK: - Application Update Request

struct ApplicationUpdateRequest: Codable {
    let status: ApplicationStatus
}

// MARK: - Block Request

struct BlockCreateRequest: Codable {
    let blockedId: String

    enum CodingKeys: String, CodingKey {
        case blockedId = "blocked_id"
    }
}
