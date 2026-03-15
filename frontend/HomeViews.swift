import SwiftUI

struct CreatorHomeView: View {
    let session: SessionManager
    @StateObject private var analyticsVM: CreatorAnalyticsViewModel

    init(session: SessionManager) {
        self.session = session
        _analyticsVM = StateObject(wrappedValue: CreatorAnalyticsViewModel(apiService: session.apiService))
    }

    var body: some View {
        NavigationStack {
            List {
                if let analytics = analyticsVM.analytics {
                    Section("Overview") {
                        StatRow(title: "Total Earnings", value: String(format: "$%.0f", analytics.totalEarnings))
                        StatRow(title: "Applications", value: "\(analytics.applications)")
                        StatRow(title: "Accepted", value: "\(analytics.acceptedApplications)")
                        StatRow(title: "Completed Agreements", value: "\(analytics.completedAgreements)")
                    }
                } else if analyticsVM.isLoading {
                    ProgressView()
                }

                Section("Quick Actions") {
                    NavigationLink("View Applications", destination: ApplicationsListView(session: session))
                    NavigationLink("Agreements", destination: AgreementsListView(session: session))
                    NavigationLink("Campaigns", destination: CampaignListView(session: session))
                }
            }
            .navigationTitle("Creator Home")
            .onAppear { analyticsVM.load() }
        }
    }
}

struct BrandHomeView: View {
    let session: SessionManager
    @StateObject private var analyticsVM: BrandAnalyticsViewModel

    init(session: SessionManager) {
        self.session = session
        _analyticsVM = StateObject(wrappedValue: BrandAnalyticsViewModel(apiService: session.apiService))
    }

    var body: some View {
        NavigationStack {
            List {
                if let analytics = analyticsVM.analytics {
                    Section("Overview") {
                        StatRow(title: "Campaigns", value: "\(analytics.campaigns)")
                        StatRow(title: "Open Campaigns", value: "\(analytics.openCampaigns)")
                        StatRow(title: "Applications", value: "\(analytics.applications)")
                        StatRow(title: "Accepted", value: "\(analytics.acceptedApplications)")
                    }
                } else if analyticsVM.isLoading {
                    ProgressView()
                }

                Section("Quick Actions") {
                    NavigationLink("Create Campaign", destination: CreateCampaignView())
                    NavigationLink("Applications", destination: ApplicationsListView(session: session))
                    NavigationLink("Agreements", destination: AgreementsListView(session: session))
                }
            }
            .navigationTitle("Brand Home")
            .onAppear { analyticsVM.load() }
        }
    }
}

struct StatRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
}

