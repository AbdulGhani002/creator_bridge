import SwiftUI

struct AgreementsListView: View {
    let session: SessionManager
    @StateObject private var viewModel: AgreementsViewModel

    init(session: SessionManager) {
        self.session = session
        _viewModel = StateObject(wrappedValue: AgreementsViewModel(apiService: session.apiService))
    }

    var body: some View {
        List {
            ForEach(viewModel.agreements) { agreement in
                NavigationLink(destination: AgreementDetailView(agreement: agreement, session: session)) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(agreement.deliverables)
                            .font(.body)
                            .lineLimit(2)
                        HStack {
                            Text(agreement.status.rawValue.capitalized)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(String(format: "$%.0f", agreement.paymentAmount))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Agreements")
        .onAppear { viewModel.loadAgreements() }
    }
}

struct AgreementDetailView: View {
    let agreement: Agreement
    let session: SessionManager
    @StateObject private var viewModel: AgreementsViewModel

    init(agreement: Agreement, session: SessionManager) {
        self.agreement = agreement
        self.session = session
        _viewModel = StateObject(wrappedValue: AgreementsViewModel(apiService: session.apiService))
    }

    var body: some View {
        Form {
            Section("Deliverables") {
                Text(agreement.deliverables)
            }
            Section("Payment") {
                Text(String(format: "$%.0f", agreement.paymentAmount))
            }
            Section("Status") {
                Text(agreement.status.rawValue.capitalized)
            }
            Section("Actions") {
                if session.user?.role == .creator {
                    Button("Accept") {
                        viewModel.updateAgreement(id: agreement.id, update: AgreementUpdateRequest(deliverables: nil, deadline: nil, paymentAmount: nil, terms: nil, status: .accepted))
                    }
                    Button("Decline") {
                        viewModel.updateAgreement(id: agreement.id, update: AgreementUpdateRequest(deliverables: nil, deadline: nil, paymentAmount: nil, terms: nil, status: .declined))
                    }
                }
                if session.user?.role == .brand {
                    Button("Mark Completed") {
                        viewModel.updateAgreement(id: agreement.id, update: AgreementUpdateRequest(deliverables: nil, deadline: nil, paymentAmount: nil, terms: nil, status: .completed))
                    }
                }
            }
        }
        .navigationTitle("Agreement")
    }
}

// MARK: - Create Agreement View
struct CreateAgreementView: View {
    let application: Application
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionManager
    
    @State private var deliverables = ""
    @State private var paymentAmount = ""
    @State private var deadline = Date()
    @State private var terms = ""
    
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    
    var body: some View {
        Form {
            Section(header: Text("Agreement Details")) {
                TextEditor(text: $deliverables)
                    .frame(minHeight: 120)
                    .overlay(
                        Group {
                            if deliverables.isEmpty {
                                Text("Deliverables / Requirements")
                                    .foregroundColor(Color(UIColor.placeholderText))
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 8)
                                    .allowsHitTesting(false)
                            }
                        },
                        alignment: .topLeading
                    )
                
                TextField("Payment Amount ($)", text: $paymentAmount)
                    .keyboardType(.decimalPad)
                
                DatePicker("Deadline", selection: $deadline, displayedComponents: .date)
            }
            
            Section(header: Text("Additional Terms (Optional)")) {
                TextEditor(text: $terms)
                    .frame(minHeight: 80)
            }
            
            if let error = errorMessage {
                Section {
                    Text(error).foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Draft Deal")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isSubmitting ? "Sending..." : "Send Deal") {
                    submit()
                }
                .disabled(isSubmitting || deliverables.isEmpty || paymentAmount.isEmpty)
            }
        }
        .onAppear {
            self.deliverables = application.proposal
        }
    }
    
    private func submit() {
        guard let amount = Double(paymentAmount) else {
            errorMessage = "Please enter a valid amount"
            return
        }
        
        isSubmitting = true
        errorMessage = nil
        
        Task {
            do {
                let request = AgreementCreateRequest(
                    campaignId: application.campaignId,
                    creatorId: application.creatorId,
                    deliverables: deliverables,
                    deadline: deadline,
                    paymentAmount: amount,
                    terms: terms.isEmpty ? nil : terms
                )
                
                _ = try await session.apiService.createAgreement(request)
                
                isSubmitting = false
                dismiss() // Exit Make Deal screen
            } catch {
                errorMessage = error.localizedDescription
                isSubmitting = false
            }
        }
    }
}

