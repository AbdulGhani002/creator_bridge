import SwiftUI

// MARK: - Create Campaign View
struct CreateCampaignView: View {
    @State private var campaignTitle = ""
    @State private var requirements = ""
    @State private var budgetPerVideo = ""
    @State private var deadline = Date()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            AppTheme.backgroundLight.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        stepIndicator
                        formSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 90)
                }

                bottomBar
            }
        }
        .navigationBarHidden(true)
    }

    private var header: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.text900)
                    .padding(6)
                    .background(AppTheme.slate100)
                    .clipShape(Circle())
            }

            Spacer()

            Text("Create Campaign")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(AppTheme.text900)

            Spacer()

            Spacer().frame(width: 28)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.9))
        .backdrop()
    }

    private var stepIndicator: some View {
        HStack(spacing: 12) {
            StepBubble(step: "1", title: "Details", active: true)
            Capsule().fill(AppTheme.primary).frame(width: 40, height: 2)
            StepBubble(step: "2", title: "Budget", active: false)
            Capsule().fill(AppTheme.slate200).frame(width: 40, height: 2)
            StepBubble(step: "3", title: "Review", active: false)
        }
        .padding(.top, 12)
    }

    private var formSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Campaign Information")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppTheme.text900)
                Text("Fill in the basic details for your upcoming influencer campaign.")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(AppTheme.text500)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Campaign Title")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppTheme.text900)
                TextField("e.g., Promote Luxury Villas", text: $campaignTitle)
                    .font(.system(size: 14, weight: .regular))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppTheme.slate200, lineWidth: 1))
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Requirements")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppTheme.text900)
                TextEditor(text: $requirements)
                    .font(.system(size: 14, weight: .regular))
                    .frame(minHeight: 120)
                    .padding(8)
                    .background(Color.white)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppTheme.slate200, lineWidth: 1))
            }

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Budget per Video ($)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppTheme.text900)

                    HStack(spacing: 6) {
                        Text("$")
                            .foregroundColor(AppTheme.text400)
                        TextField("200", text: $budgetPerVideo)
                            .keyboardType(.numberPad)
                            .font(.system(size: 14, weight: .regular))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppTheme.slate200, lineWidth: 1))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Application Deadline")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppTheme.text900)

                    DatePicker("", selection: $deadline, displayedComponents: .date)
                        .labelsHidden()
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppTheme.slate200, lineWidth: 1))
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Campaign Banner (Optional)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppTheme.text900)

                VStack(spacing: 6) {
                    Image(systemName: "icloud.and.arrow.up")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(AppTheme.primary)
                    Text("Click to upload or drag and drop")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(AppTheme.text600)
                    Text("PNG, JPG or WEBP (max. 5MB)")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(AppTheme.text400)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppTheme.slate200, style: StrokeStyle(lineWidth: 1, dash: [6]))
                )
                .cornerRadius(12)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.slate200, lineWidth: 1))
    }

    private var bottomBar: some View {
        HStack(spacing: 12) {
            Button(action: {}) {
                Text("Save Draft")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppTheme.text700)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppTheme.slate200, lineWidth: 1))
                    .cornerRadius(10)
            }

            Button(action: {}) {
                Text("Next Step")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(AppTheme.primary)
                    .cornerRadius(10)
            }
        }
        .padding(16)
        .background(Color.white)
        .overlay(Divider(), alignment: .top)
    }
}

struct StepBubble: View {
    let step: String
    let title: String
    let active: Bool

    var body: some View {
        VStack(spacing: 6) {
            Circle()
                .fill(active ? AppTheme.primary : Color.white)
                .frame(width: 36, height: 36)
                .overlay(
                    Text(step)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(active ? .white : AppTheme.text400)
                )
                .overlay(
                    Circle().stroke(active ? AppTheme.primary : AppTheme.slate200, lineWidth: 2)
                )

            Text(title)
                .font(.system(size: 10, weight: active ? .semibold : .medium))
                .foregroundColor(active ? AppTheme.primary : AppTheme.text400)
        }
    }
}

#Preview {
    CreateCampaignView()
}
