import SwiftUI

struct CreatorHomeView: View {
    @StateObject private var analyticsVM = CreatorAnalyticsViewModel()

    var body: some View {
        NavigationStack {
            List {
                if let analytics = analyticsVM.analytics {
                    Section("Overview") {
                        StatRow(title: "Total Earnings", value: "$\(analytics.totalEarnings, specifier: "%.0f")")
                        StatRow(title: "Applications", value: "\(analytics.applications)")
                        StatRow(title: "Accepted", value: "\(analytics.acceptedApplications)")
                        StatRow(title: "Completed Agreements", value: "\(analytics.completedAgreements)")
                    }
                } else if analyticsVM.isLoading {
                    ProgressView()
                }

                Section("Quick Actions") {
                    NavigationLink("View Applications", destination: ApplicationsListView())
                    NavigationLink("Agreements", destination: AgreementsListView())
                    NavigationLink("Campaigns", destination: CampaignListView())
                }
            }
            .navigationTitle("Creator Home")
            .onAppear { analyticsVM.load() }
        }
    }
}

struct BrandHomeView: View {
    @StateObject private var analyticsVM = BrandAnalyticsViewModel()

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
                    NavigationLink("Applications", destination: ApplicationsListView())
                    NavigationLink("Agreements", destination: AgreementsListView())
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

