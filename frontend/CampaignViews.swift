import SwiftUI

// MARK: - Campaign List View

struct CampaignListView: View {
    @StateObject private var viewModel: CampaignListViewModel
    @State private var showFilterSheet = false
    @Environment(\.colorScheme) var colorScheme

    init(session: SessionManager) {
        _viewModel = StateObject(wrappedValue: CampaignListViewModel(apiService: session.apiService))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Main Content
                if viewModel.campaigns.isEmpty && !viewModel.isLoading {
                    emptyStateView
                } else {
                    campaignListContent
                }
                
                // Error Alert
                if viewModel.hasError {
                    errorOverlay
                }
            }
            .navigationTitle("Campaigns")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        // Filter Button
                        Button(action: { showFilterSheet = true }) {
                            Image(systemName: "funnel.fill")
                                .foregroundStyle(.blue)
                        }
                        
                        // Refresh Button
                        Button(action: { viewModel.refreshCampaigns() }) {
                            Image(systemName: "arrow.clockwise")
                                .foregroundStyle(.blue)
                        }
                    }
                }
            }
            .sheet(isPresented: $showFilterSheet) {
                CampaignFilterView(viewModel: viewModel)
            }
            .onAppear {
                viewModel.loadInitialCampaigns()
            }
        }
    }
    
    // MARK: - Subviews
    
    private var campaignListContent: some View {
        List {
            ForEach(viewModel.campaigns) { campaign in
                NavigationLink(destination: CampaignDetailView(campaign: campaign)) {
                    CampaignRowView(campaign: campaign)
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowSeparator(.hidden)
                
                // Pagination trigger
                if campaign.id == viewModel.campaigns.last?.id && viewModel.hasMorePages {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .onAppear {
                            viewModel.loadMoreCampaigns()
                        }
                }
            }
        }
        .listStyle(.plain)
        .refreshable {
            viewModel.refreshCampaigns()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "briefcase")
                .font(.system(size: 48))
                .foregroundStyle(.gray)
            
            Text("No Campaigns Found")
                .font(.headline)
                .foregroundStyle(.primary)
            
            Text("Try adjusting your filters or check back later")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: { viewModel.clearFilters() }) {
                Text("Clear Filters")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 16)
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
                
                Text("Error Loading Campaigns")
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
                    
                    Button(action: { viewModel.refreshCampaigns() }) {
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

// MARK: - Campaign Row View

struct CampaignRowView: View {
    let campaign: Campaign
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(campaign.title)
                        .font(.headline)
                        .lineLimit(2)
                    
                    Text(campaign.niche.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Status Badge
                statusBadge
            }
            
            // Details Row
            HStack(spacing: 16) {
                // Budget
                HStack(spacing: 6) {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundStyle(.green)
                    Text(String(format: "$%.0f", campaign.budget))
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Divider()
                
                // Location
                HStack(spacing: 6) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(.red)
                    Text(campaign.location)
                        .font(.subheadline)
                        .lineLimit(1)
                }
                
                Spacer()
            }
            
            // Description
            Text(campaign.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            
            // Footer
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                        .font(.caption)
                    Text("\(campaign.applicationsCount) applications")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
                
                Spacer()
                
                if campaign.isDeadlinePassed {
                    Text("Expired")
                        .font(.caption)
                        .foregroundStyle(.red)
                } else {
                    Text("\(campaign.daysRemaining) days left")
                        .font(.caption)
                        .foregroundStyle(campaign.daysRemaining <= 3 ? .orange : .secondary)
                }
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
    
    private var statusBadge: some View {
        Text(campaign.status.displayName)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor)
            .cornerRadius(6)
    }
    
    private var statusColor: Color {
        switch campaign.status {
        case .open:
            return .green
        case .inProgress:
            return .blue
        case .closed:
            return .gray
        }
    }
}

// MARK: - Campaign Filter View

struct CampaignFilterView: View {
    @ObservedObject var viewModel: CampaignListViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Niche") {
                    Picker("Select Niche", selection: $viewModel.selectedNiche) {
                        Text("All Niches").tag(nil as NicheType?)
                        
                        ForEach(NicheType.allCases, id: \.self) { niche in
                            Text(niche.displayName).tag(niche as NicheType?)
                        }
                    }
                }
                
                Section("Location") {
                    TextField("Enter location", text: $viewModel.selectedLocation)
                        .autocorrectionDisabled()
                }
                
                Section("Budget Range") {
                    HStack {
                        Text("$")
                        TextField(
                            "Min Budget",
                            value: $viewModel.minBudget,
                            format: .number
                        )
                        .keyboardType(.decimalPad)
                    }
                    
                    HStack {
                        Text("$")
                        TextField(
                            "Max Budget",
                            value: $viewModel.maxBudget,
                            format: .number
                        )
                        .keyboardType(.decimalPad)
                    }
                }
                
                Section("Status") {
                    Picker("Campaign Status", selection: $viewModel.selectedStatus) {
                        ForEach([CampaignStatus.open, .inProgress, .closed], id: \.self) { status in
                            Text(status.displayName).tag(status)
                        }
                    }
                }
            }
            .navigationTitle("Filter Campaigns")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        viewModel.loadInitialCampaigns()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Campaign Detail View

struct CampaignDetailView: View {
    let campaign: Campaign
    @Environment(\.dismiss) var dismiss
    @State private var showApplyForm = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(campaign.title)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(campaign.niche.displayName)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text(String(format: "$%.0f", campaign.budget))
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(.green)
                            
                            Text("Budget")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(16)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Campaign Details
                VStack(alignment: .leading, spacing: 16) {
                    DetailRow(label: "Status", value: campaign.status.displayName)
                    DetailRow(label: "Location", value: campaign.location)
                    DetailRow(
                        label: "Required Followers",
                        value: String(campaign.requiredFollowers)
                    )
                    DetailRow(
                        label: "Applications",
                        value: String(campaign.applicationsCount)
                    )
                    DetailRow(
                        label: "Days Remaining",
                        value: campaign.daysRemaining > 0 ? "\(campaign.daysRemaining)" : "Expired"
                    )
                }
                
                Divider()
                
                // Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.headline)
                    
                    Text(campaign.description)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .lineSpacing(4)
                }
                
                // Deliverables
                VStack(alignment: .leading, spacing: 8) {
                    Text("Deliverables")
                        .font(.headline)
                    
                    Text(campaign.deliverables)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .lineSpacing(4)
                }
                
                Divider()
                
                // CTA Button
                if !campaign.isDeadlinePassed && campaign.status == .open {
                    Button(action: { showApplyForm = true }) {
                        Text("Apply Now")
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .foregroundStyle(.white)
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                }
                
                Spacer()
            }
            .padding(16)
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemBackground))
        .sheet(isPresented: $showApplyForm) {
            ApplicationFormView(campaignId: campaign.id)
        }
    }
}

// MARK: - Detail Row Helper

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.semibold)
        }
        .font(.subheadline)
    }
}

// MARK: - Preview

#Preview {
    CampaignListView(session: SessionManager())
}
