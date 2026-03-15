import SwiftUI

// MARK: - Creator Search View

struct CreatorSearchView: View {
    @StateObject private var viewModel: CreatorSearchViewModel
    @State private var showFilterSheet = false
    @State private var searchText = ""

    init(session: SessionManager) {
        _viewModel = StateObject(wrappedValue: CreatorSearchViewModel(apiService: session.apiService))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.creators.isEmpty && !viewModel.isLoading && !searchText.isEmpty {
                    emptyStateView
                } else {
                    creatorListContent
                }
                
                if viewModel.hasError {
                    errorOverlay
                }
            }
            .navigationTitle("Find Creators")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        Button(action: { showFilterSheet = true }) {
                            Image(systemName: "funnel.fill")
                                .foregroundStyle(.blue)
                        }
                        
                        Button(action: { viewModel.refreshSearch() }) {
                            Image(systemName: "arrow.clockwise")
                                .foregroundStyle(.blue)
                        }
                    }
                }
            }
            .sheet(isPresented: $showFilterSheet) {
                CreatorFilterView(viewModel: viewModel)
            }
        }
        .searchable(
            text: $searchText,
            prompt: "Search by location"
        )
        .onChange(of: searchText) { oldValue, newValue in
            viewModel.searchWithDebounce(location: newValue)
        }
    }
    
    // MARK: - Subviews
    
    private var creatorListContent: some View {
        List {
            if viewModel.isLoading && viewModel.creators.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                ForEach(viewModel.creators) { creator in
                    NavigationLink(destination: CreatorDetailView(creator: creator)) {
                        CreatorRowView(creator: creator)
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowSeparator(.hidden)
                    
                    if creator.id == viewModel.creators.last?.id && viewModel.hasMorePages {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .onAppear {
                                viewModel.loadMoreCreators()
                            }
                    }
                }
            }
        }
        .listStyle(.plain)
        .refreshable {
            viewModel.refreshSearch()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.system(size: 48))
                .foregroundStyle(.gray)
            
            Text("No Creators Found")
                .font(.headline)
                .foregroundStyle(.primary)
            
            Text("Try searching by location or adjusting your filters")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
    }
    
    private var errorOverlay: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.orange)
                
                Text("Error Loading Creators")
                    .font(.headline)
                
                Text(viewModel.error?.errorDescription ?? "Unknown error")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 12) {
                    Button(action: { viewModel.dismissError() }) {
                        Text("Dismiss")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    
                    Button(action: { viewModel.refreshSearch() }) {
                        Text("Retry")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(20)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .padding(16)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.3))
    }
}

// MARK: - Creator Row View

struct CreatorRowView: View {
    let creator: CreatorProfile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    // Creator info would go here (name from user)
                    Text(creator.niche?.displayName ?? "Creator")
                        .font(.headline)
                        .lineLimit(1)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                            .font(.caption)
                        
                        if let rating = creator.rating {
                            Text(String(format: "%.1f", rating))
                                .font(.caption)
                                .fontWeight(.medium)
                        } else {
                            Text("No ratings")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                // Subscription Badge
                subscriptionBadge
            }
            
            // Bio
            Text(creator.bio)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            
            // Followers and Pricing
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                        .font(.caption)
                        .foregroundStyle(.blue)
                    
                    Text("\(creator.totalFollowers) followers")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                Divider()
                
                HStack(spacing: 4) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                    
                    Text(String(format: "$%.0f/post", creator.pricingPerPost ?? 0))
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                Spacer()
            }
            
            // Platforms
            platformsStack
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
    
    private var subscriptionBadge: some View {
        Text((creator.subscriptionTier ?? "free").uppercased())
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(subscriptionColor)
            .cornerRadius(6)
    }
    
    private var subscriptionColor: Color {
        switch creator.subscriptionTier ?? "free" {
        case "pro":
            return .blue
        case "premium":
            return .purple
        default:
            return .gray
        }
    }
    
    private var platformsStack: some View {
        HStack(spacing: 8) {
            ForEach((creator.socialPlatforms ?? []).prefix(3)) { platform in
                platformBadge(platform)
            }
            
            if (creator.socialPlatforms ?? []).count > 3 {
                Text("+\((creator.socialPlatforms ?? []).count - 3) more")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
    
    private func platformBadge(_ platform: SocialPlatform) -> some View {
        Text(platform.platform.displayName)
            .font(.caption2)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Color.blue.opacity(0.1))
            .foregroundStyle(.blue)
            .cornerRadius(4)
    }
}

// MARK: - Creator Filter View

struct CreatorFilterView: View {
    @ObservedObject var viewModel: CreatorSearchViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Location") {
                    TextField("City or region", text: $viewModel.searchLocation)
                        .autocorrectionDisabled()
                }
                
                Section("Niche") {
                    Picker("Select Niche", selection: $viewModel.selectedNiche) {
                        Text("All Niches").tag(nil as NicheType?)
                        
                        ForEach(NicheType.allCases, id: \.self) { niche in
                            Text(niche.displayName).tag(niche as NicheType?)
                        }
                    }
                }
                
                Section("Followers Range") {
                    HStack {
                        Text("Min")
                        TextField(
                            "Min Followers",
                            value: $viewModel.minFollowers,
                            format: .number
                        )
                        .keyboardType(.numberPad)
                    }
                    
                    HStack {
                        Text("Max")
                        TextField(
                            "Max Followers",
                            value: $viewModel.maxFollowers,
                            format: .number
                        )
                        .keyboardType(.numberPad)
                    }
                }
                
                Section("Minimum Rating") {
                    Picker("Minimum Rating", selection: $viewModel.minRating) {
                        Text("Any").tag(nil as Double?)
                        Text("3.0+").tag(3.0)
                        Text("4.0+").tag(4.0)
                        Text("4.5+").tag(4.5)
                    }
                }

                Section("Platform") {
                    Picker("Platform", selection: $viewModel.platform) {
                        Text("Any").tag(nil as String?)
                        ForEach(PlatformType.allCases, id: \.self) { platform in
                            Text(platform.displayName).tag(platform.rawValue as String?)
                        }
                    }
                }
                
                Section("Subscription Tier") {
                    Picker("Subscription", selection: $viewModel.subscriptionTier) {
                        Text("Any").tag(nil as String?)
                        Text("Free").tag("free" as String?)
                        Text("Pro").tag("pro" as String?)
                        Text("Premium").tag("premium" as String?)
                    }
                }
            }
            .navigationTitle("Filter Creators")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        viewModel.searchCreators()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Creator Detail View

struct CreatorDetailView: View {
    let creator: CreatorProfile
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Creator Header
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(creator.niche?.displayName ?? "Creator")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            HStack(spacing: 12) {
                                if let rating = creator.rating {
                                    HStack(spacing: 4) {
                                        Image(systemName: "star.fill")
                                            .foregroundStyle(.yellow)
                                        Text(String(format: "%.1f", rating))
                                    }
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                }
                                
                                Text((creator.subscriptionTier ?? "free").uppercased())
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(subscriptionColor)
                                    .foregroundStyle(.white)
                                    .cornerRadius(4)
                            }
                        }
                        
                        Spacer()
                    }
                }
                .padding(16)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Creator Stats
                HStack(spacing: 20) {
                    statCard(
                        title: "Total Followers",
                        value: String(creator.totalFollowers),
                        icon: "person.2.fill"
                    )
                    
                    statCard(
                        title: "Pricing",
                        value: String(format: "$%.0f", creator.pricingPerPost ?? 0),
                        icon: "dollarsign.circle.fill"
                    )
                    
                    statCard(
                        title: "Earnings",
                        value: String(format: "$%.0f", creator.totalEarnings ?? 0),
                        icon: "banknote.fill"
                    )
                }
                
                Divider()
                
                // Bio
                VStack(alignment: .leading, spacing: 8) {
                    Text("About")
                        .font(.headline)
                    
                    Text(creator.bio)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .lineSpacing(4)
                }
                
                // Social Platforms
                VStack(alignment: .leading, spacing: 12) {
                    Text("Social Platforms")
                        .font(.headline)
                    
                    VStack(spacing: 8) {
                        ForEach(creator.socialPlatforms ?? []) { platform in
                            platformCard(platform)
                        }
                    }
                }
                
                // Portfolio
                if let portfolioUrl = creator.portfolioUrl {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Portfolio")
                            .font(.headline)
                        
                        Link(destination: URL(string: portfolioUrl) ?? URL(string: "about:blank")!) {
                            HStack {
                                Image(systemName: "link.circle.fill")
                                Text("View Portfolio")
                                Spacer()
                                Image(systemName: "arrow.up.right")
                            }
                            .font(.subheadline)
                            .foregroundStyle(.blue)
                        }
                    }
                }
                
                Divider()
                
                // CTA Button
                Button(action: {}) {
                    Text("Send Collaboration Request")
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .foregroundStyle(.white)
                        .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                
                Spacer()
            }
            .padding(16)
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemBackground))
    }
    
    private func statCard(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(.blue)
                
                Spacer()
            }
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private func platformCard(_ platform: SocialPlatform) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(platform.platform.displayName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("@\(platform.handle)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(platform.followers)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                if let engagement = platform.engagementRate {
                    Text(String(format: "%.1f%% engagement", engagement))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private var subscriptionColor: Color {
        switch creator.subscriptionTier ?? "free" {
        case "pro":
            return .blue
        case "premium":
            return .purple
        default:
            return .gray
        }
    }
}

#Preview {
    CreatorSearchView(session: SessionManager())
}

