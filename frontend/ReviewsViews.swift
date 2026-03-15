import SwiftUI

struct ReviewFormView: View {
    let revieweeId: String
    let revieweeRole: String
    let campaignId: String?

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionManager
    @State private var rating: Double = 5
    @State private var comment: String = ""
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Rating") {
                    Slider(value: $rating, in: 1...5, step: 0.5)
                    Text("Rating: \(rating, specifier: "%.1f")")
                }
                Section("Comment") {
                    TextEditor(text: $comment)
                        .frame(minHeight: 120)
                }
                if let errorMessage = errorMessage {
                    Text(errorMessage).foregroundColor(.red)
                }
            }
            .navigationTitle("Leave Review")
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
                let payload = ReviewCreateRequest(
                    revieweeId: revieweeId,
                    revieweeRole: revieweeRole,
                    rating: rating,
                    comment: comment.isEmpty ? nil : comment,
                    campaignId: campaignId
                )
                _ = try await session.apiService.createReview(payload)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

struct ReviewsListView: View {
    let revieweeId: String
    let revieweeRole: String
    
    @State private var reviews: [Review] = []
    @State private var isLoading = false
    @EnvironmentObject private var session: SessionManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Reviews")
                .font(.headline)
            
            if isLoading {
                ProgressView()
            } else if reviews.isEmpty {
                Text("No reviews yet.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                ForEach(reviews) { review in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            ForEach(0..<5, id: \.self) { i in
                                Image(systemName: i < Int(review.rating) ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                                    .font(.caption)
                            }
                            Spacer()
                            if let date = review.createdAt {
                                Text(date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        if let comment = review.comment {
                            Text(comment)
                                .font(.subheadline)
                                .italic()
                        }
                    }
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
        }
        .onAppear {
            loadReviews()
        }
    }
    
    private func loadReviews() {
        isLoading = true
        Task {
            do {
                let response = try await session.apiService.listReviews(revieweeId: revieweeId, revieweeRole: revieweeRole)
                reviews = response.reviews
            } catch {
                print("Failed to load reviews:", error)
            }
            isLoading = false
        }
    }
}

