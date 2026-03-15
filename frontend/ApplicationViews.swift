import SwiftUI

struct ApplicationFormView: View {
    let campaignId: String

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionManager

    @State private var proposal = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Proposal") {
                    TextEditor(text: $proposal)
                        .frame(minHeight: 160)
                }

                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle("Apply to Campaign")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isSubmitting ? "Submitting..." : "Submit") {
                        submit()
                    }
                    .disabled(isSubmitting || proposal.trimmingCharacters(in: .whitespacesAndNewlines).count < 10)
                }
            }
        }
    }

    private func submit() {
        isSubmitting = true
        errorMessage = nil
        Task {
            do {
                let request = ApplicationCreateRequest(campaignId: campaignId, proposal: proposal)
                _ = try await session.apiService.createApplication(request)
                isSubmitting = false
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                isSubmitting = false
            }
        }
    }
}

struct ApplicationsListView: View {
    let session: SessionManager
    @StateObject private var viewModel: ApplicationsViewModel

    init(session: SessionManager) {
        self.session = session
        _viewModel = StateObject(wrappedValue: ApplicationsViewModel(apiService: session.apiService))
    }

    var body: some View {
        List {
            ForEach(viewModel.applications) { app in
                VStack(alignment: .leading, spacing: 8) {
                    Text("Proposal: \(app.proposal)")
                        .font(.body)
                        .lineLimit(3)
                    
                    HStack {
                        Text(app.status.displayName)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(statusColor(for: app.status))
                        Spacer()
                        Text("Campaign ID: \(app.campaignId.suffix(6))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    if session.user?.role == .brand && app.status == .pending {
                        HStack(spacing: 12) {
                            Button("Accept") {
                                viewModel.updateStatus(applicationId: app.id, status: .accepted)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                            
                            Button("Reject") {
                                viewModel.updateStatus(applicationId: app.id, status: .rejected)
                            }
                            .buttonStyle(.bordered)
                            .tint(.red)
                        }
                        .padding(.top, 4)
                    } else if session.user?.role == .brand && app.status == .accepted {
                        HStack {
                            NavigationLink(destination: CreateAgreementView(application: app)) {
                                Text("Make Deal")
                                    .fontWeight(.bold)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Applications")
        .refreshable {
            viewModel.loadApplications()
        }
        .onAppear {
            viewModel.loadApplications()
        }
    }
    
    private func statusColor(for status: ApplicationStatus) -> Color {
        switch status {
        case .pending: return .orange
        case .accepted: return .green
        case .rejected: return .red
        case .completed: return .blue
        case .withdrawn: return .gray
        }
    }
}

