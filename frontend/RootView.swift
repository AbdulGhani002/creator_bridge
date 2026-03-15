import SwiftUI

struct RootView: View {
    @EnvironmentObject private var session: SessionManager
    @StateObject private var profileStore = ProfileStore()

    var body: some View {
        Group {
            if !session.isAuthenticated {
                AuthView()
            } else if profileStore.isLoading {
                ProgressView("Loading profile...")
            } else if session.user?.role == .creator && profileStore.creatorProfile == nil {
                CreatorProfileSetupView(profileStore: profileStore)
            } else if session.user?.role == .brand && profileStore.brandProfile == nil {
                BrandProfileSetupView(profileStore: profileStore)
            } else {
                MainTabView()
            }
        }
        .onAppear {
            Task { await profileStore.loadProfile(session: session) }
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject private var session: SessionManager

    var body: some View {
        if session.user?.role == .creator {
            CreatorTabView()
        } else {
            BrandTabView()
        }
    }
}

struct CreatorTabView: View {
    var body: some View {
        TabView {
            CreatorHomeView()
                .tabItem { Label("Home", systemImage: "house") }
            CampaignListView()
                .tabItem { Label("Campaigns", systemImage: "megaphone") }
            MessagesListView()
                .tabItem { Label("Messages", systemImage: "message") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}

struct BrandTabView: View {
    var body: some View {
        TabView {
            BrandHomeView()
                .tabItem { Label("Home", systemImage: "house") }
            CreatorSearchView()
                .tabItem { Label("Creators", systemImage: "safari") }
            MessagesListView()
                .tabItem { Label("Messages", systemImage: "message") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}

