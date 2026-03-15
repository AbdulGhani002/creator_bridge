import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var session: SessionManager
    @State private var showDeleteConfirm = false
    @State private var deletionInProgress = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Account") {
                    Text(session.user?.email ?? "")
                    Button("Sign Out") { session.logout() }
                }

                Section("Subscription") {
                    HStack {
                        Text("Current Plan")
                        Spacer()
                        Text((session.user?.subscriptionTier ?? "Free").capitalized)
                            .foregroundColor(.secondary)
                    }
                    NavigationLink("Upgrade Plan", destination: SubscriptionPlansView())
                }

                Section("Compliance") {
                    NavigationLink("Privacy Policy", destination: PrivacyPolicyFullView())
                    NavigationLink("Terms of Service", destination: TermsOfServiceFullView())
                    NavigationLink("Community Guidelines", destination: CommunityGuidelinesView())
                    NavigationLink("Accessibility", destination: AccessibilityStatementView())
                }

                Section("Support") {
                    Text("Contact: support@creatorbridge.com")
                    Text("Report issues via the in‑app Report button in Messages.")
                }

                Section("Delete Account") {
                    Button(deletionInProgress ? "Deleting..." : "Delete Account") {
                        showDeleteConfirm = true
                    }
                    .foregroundColor(.red)
                }

                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage).foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog("Are you sure you want to delete your account?", isPresented: $showDeleteConfirm) {
                Button("Delete", role: .destructive) { deleteAccount() }
                Button("Cancel", role: .cancel) { }
            }
        }
    }

    private func deleteAccount() {
        deletionInProgress = true
        Task {
            let success = await session.deleteAccount()
            if !success {
                errorMessage = session.errorMessage
            }
            deletionInProgress = false
        }
    }
}

