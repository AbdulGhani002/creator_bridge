import SwiftUI

struct MessagesListView: View {
    let session: SessionManager
    @StateObject private var viewModel: MessagesViewModel

    init(session: SessionManager) {
        self.session = session
        _viewModel = StateObject(wrappedValue: MessagesViewModel(apiService: session.apiService))
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.threads) { thread in
                    NavigationLink(destination: ChatThreadView(thread: thread, session: session)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(thread.threadId)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(thread.lastMessage.content)
                                .font(.body)
                                .lineLimit(1)
                            Text(thread.lastMessage.timestamp?.formatted() ?? "")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Messages")
            .onAppear {
                viewModel.loadThreads()
            }
        }
    }
}

struct ChatThreadView: View {
    let thread: MessageThread
    let session: SessionManager
    @StateObject private var viewModel: MessagesViewModel
    @State private var messageText = ""
    @State private var showReport = false

    init(thread: MessageThread, session: SessionManager) {
        self.thread = thread
        self.session = session
        _viewModel = StateObject(wrappedValue: MessagesViewModel(apiService: session.apiService))
    }

    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(viewModel.messages) { message in
                            HStack {
                                if message.fromId == session.user?.id {
                                    Spacer()
                                    TextBubble(text: message.content, isOwn: true)
                                } else {
                                    TextBubble(text: message.content, isOwn: false)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages.count) { _, _ in
                    if let last = viewModel.messages.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }

            HStack(spacing: 8) {
                TextField("Type a message", text: $messageText)
                    .textFieldStyle(.roundedBorder)
                Button("Send") { sendMessage() }
                    .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
        }
        .navigationTitle("Chat")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Report") { showReport = true }
                    if let otherId = otherParticipantId() {
                        Button("Block User") {
                            Task { _ = try? await session.apiService.blockUser(blockedId: otherId) }
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
        .onAppear {
            viewModel.loadMessages(threadId: thread.threadId)
            startPolling()
        }
        .onDisappear {
            stopPolling()
        }
        .sheet(isPresented: $showReport) {
            ReportView(targetType: "message", targetId: thread.lastMessage.id)
        }
    }

    @State private var pollingTimer: Timer?

    private func startPolling() {
        pollingTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
            viewModel.loadMessages(threadId: thread.threadId)
        }
    }

    private func stopPolling() {
        pollingTimer?.invalidate()
        pollingTimer = nil
    }

    private func otherParticipantId() -> String? {
        let parts = thread.threadId.split(separator: "_")
        if parts.count >= 2, let current = session.user?.id {
            let a = String(parts[0])
            let b = String(parts[1])
            return a == current ? b : a
        }
        return nil
    }

    private func sendMessage() {
        guard let otherId = otherParticipantId() else { return }
        let payload = MessageCreateRequest(toId: otherId, campaignId: nil, content: messageText)
        messageText = ""
        viewModel.sendMessage(payload, threadId: thread.threadId)
    }
}

struct TextBubble: View {
    let text: String
    let isOwn: Bool

    var body: some View {
        Text(text)
            .padding(10)
            .background(isOwn ? AppTheme.primary : AppTheme.slate100)
            .foregroundColor(isOwn ? .white : AppTheme.text900)
            .cornerRadius(12)
    }
}

struct ReportView: View {
    let targetType: String
    let targetId: String

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionManager
    @State private var reason = ""
    @State private var details = ""
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Reason") {
                    TextField("Reason", text: $reason)
                }
                Section("Details") {
                    TextEditor(text: $details)
                        .frame(minHeight: 120)
                }
                if let errorMessage = errorMessage {
                    Text(errorMessage).foregroundColor(.red)
                }
            }
            .navigationTitle("Report")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Submit") { submit() }
                }
            }
        }
    }

    private func submit() {
        Task {
            do {
                let payload = ReportCreateRequest(targetType: targetType, targetId: targetId, reason: reason, details: details)
                _ = try await session.apiService.report(payload)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

