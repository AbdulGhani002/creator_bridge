import SwiftUI

// MARK: - Subscription Plans View
struct SubscriptionPlansView: View {
    @State private var billingPeriod = 0 // 0: Monthly, 1: Annual
    @EnvironmentObject private var session: SessionManager
    @StateObject private var storeManager = StoreKitManager.shared

    private let plans: [PlanData] = [
        PlanData(
            name: "Basic",
            price: "$0",
            description: "Perfect for hobbyists just starting out.",
            features: [
                Feature(name: "Standard Profile Page", included: true),
                Feature(name: "Basic Analytics", included: true),
                Feature(name: "Search Visibility", included: false)
            ],
            cta: "Start for Free",
            highlighted: false,
            badge: nil,
            productId: nil
        ),
        PlanData(
            name: "Pro",
            price: "$19",
            description: "Get discovered by brands and followers.",
            features: [
                Feature(name: "Everything in Basic", included: true),
                Feature(name: "Appear in Search Results", included: true, accent: true),
                Feature(name: "Advanced Audience Insights", included: true),
                Feature(name: "Custom Profile URL", included: true)
            ],
            cta: "Go Pro Now",
            highlighted: true,
            badge: "Most Popular",
            productId: "com.creatorbridge.pro.monthly"
        ),
        PlanData(
            name: "Premium",
            price: "$49",
            description: "Maximum exposure for top creators.",
            features: [
                Feature(name: "Everything in Pro", included: true),
                Feature(name: "Featured Listing (Top 1%)", included: true, accent: true),
                Feature(name: "Ad-free Profile for Fans", included: true, accent: true),
                Feature(name: "Priority Support 24/7", included: true)
            ],
            cta: "Get Featured",
            highlighted: false,
            badge: nil,
            productId: "com.creatorbridge.premium.monthly"
        )
    ]

    var body: some View {
        ZStack {
            AppTheme.backgroundLight.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        heroSection
                        pricingGrid
                        visibilitySection
                    }
                    .padding(.bottom, 90)
                }

                bottomNav
            }
        }
        .navigationBarHidden(true)
        .overlay(
            Group {
                if storeManager.isLoading {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    ProgressView("Processing...")
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                }
            }
        )
        .alert("Store Error", isPresented: .constant(storeManager.purchaseError != nil)) {
            Button("OK") { storeManager.purchaseError = nil }
        } message: {
            Text(storeManager.purchaseError ?? "")
        }
    }

    private var header: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "rocket.launch")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppTheme.primary)
                Text("CreatorFlow")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.text900)
            }

            Spacer()

            Button("Sign In") {}
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(AppTheme.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.9))
        .backdrop()
    }

    private var heroSection: some View {
        VStack(spacing: 12) {
            Text("Choose your creator journey")
                .font(.system(size: 26, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundColor(AppTheme.text900)

            Text("Boost your visibility and grow your audience with professional tools designed for scaling creators.")
                .font(.system(size: 14, weight: .regular))
                .multilineTextAlignment(.center)
                .foregroundColor(AppTheme.text600)
                .padding(.horizontal, 16)

            HStack(spacing: 0) {
                Button(action: { billingPeriod = 0 }) {
                    Text("Monthly")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(billingPeriod == 0 ? AppTheme.text900 : AppTheme.text500)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(billingPeriod == 0 ? Color.white : Color.clear)
                        .cornerRadius(8)
                }

                Button(action: { billingPeriod = 1 }) {
                    HStack(spacing: 6) {
                        Text("Annual")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppTheme.text500)
                        Text("Save 20%")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(AppTheme.successGreen)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(AppTheme.successGreen.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
            }
            .padding(6)
            .background(AppTheme.primary.opacity(0.05))
            .cornerRadius(12)
            .padding(.horizontal, 20)
        }
        .padding(.top, 20)
    }

    private var pricingGrid: some View {
        VStack(spacing: 16) {
            ForEach(plans) { plan in
                PlanCardView(plan: plan, storeManager: storeManager)
            }
        }
        .padding(.horizontal, 16)
    }

    private var visibilitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Unlock Maximum Visibility")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppTheme.text900)

            Text("Creators on our Pro and Premium plans see an average of 4x more engagement. Our algorithm prioritizes premium content, placing you directly in front of active explorers.")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(AppTheme.text600)

            VStack(spacing: 12) {
                VisibilityRow(icon: "chart.line.uptrend.xyaxis", title: "Growth Accelerator", subtitle: "Automatic placement in recommended creator feeds.")
                VisibilityRow(icon: "eye", title: "Search Domination", subtitle: "Rank at the top when fans search for your niche.")
            }

            VisibilityCard()
        }
        .padding(16)
        .background(AppTheme.primary.opacity(0.05))
        .cornerRadius(20)
        .padding(.horizontal, 16)
    }

    private var bottomNav: some View {
        HStack {
            PlansBottomNavItem(icon: "house", title: "Home", active: false)
            PlansBottomNavItem(icon: "magnifyingglass", title: "Search", active: false)
            PlansBottomNavItem(icon: "crown", title: "Plans", active: true)
            PlansBottomNavItem(icon: "person", title: "Profile", active: false)
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .padding(.bottom, 20)
        .background(Color.white.opacity(0.95))
        .overlay(Divider(), alignment: .top)
    }
}

// MARK: - Components

struct PlanData: Identifiable {
    let id = UUID()
    let name: String
    let price: String
    let description: String
    let features: [Feature]
    let cta: String
    let highlighted: Bool
    let badge: String?
    let productId: String?
}

struct Feature: Identifiable {
    let id = UUID()
    let name: String
    let included: Bool
    var accent: Bool = false
}

struct PlanCardView: View {
    let plan: PlanData
    @ObservedObject var storeManager: StoreKitManager
    @EnvironmentObject private var session: SessionManager

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if let badge = plan.badge {
                Text(badge.uppercased())
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppTheme.primary)
                    .cornerRadius(10)
            }

            Text(plan.name)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(AppTheme.text900)

            Text(plan.description)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(AppTheme.text500)

            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(plan.price)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppTheme.text900)
                Text("/mo")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(AppTheme.text500)
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(plan.features) { feature in
                    HStack(spacing: 8) {
                        Image(systemName: feature.included ? "checkmark.circle.fill" : "xmark.circle")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(feature.included ? (feature.accent ? AppTheme.primary : AppTheme.successGreen) : AppTheme.text300)

                        Text(feature.name)
                            .font(.system(size: 12, weight: feature.accent ? .semibold : .regular))
                            .foregroundColor(feature.accent ? AppTheme.primary : (feature.included ? AppTheme.text900 : AppTheme.text400))
                    }
                }
            }

            Button(action: {
                if let pid = plan.productId, let product = storeManager.products.first(where: { $0.id == pid }) {
                    Task {
                        try? await storeManager.purchase(product, session: session)
                    }
                }
            }) {
                Text(plan.cta)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(plan.highlighted ? .white : AppTheme.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(plan.highlighted ? AppTheme.primary : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(plan.highlighted ? Color.clear : AppTheme.primary.opacity(0.2), lineWidth: 2)
                    )
                    .cornerRadius(10)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(plan.highlighted ? AppTheme.primary : AppTheme.slate200, lineWidth: plan.highlighted ? 2 : 1)
        )
        .shadow(color: plan.highlighted ? AppTheme.primary.opacity(0.1) : Color.clear, radius: 8, x: 0, y: 4)
    }
}

struct VisibilityRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(AppTheme.primary.opacity(0.2))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .foregroundColor(AppTheme.primary)
                    .font(.system(size: 16, weight: .bold))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(AppTheme.text900)
                Text(subtitle)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(AppTheme.text500)
            }

            Spacer()
        }
    }
}

struct VisibilityCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Circle()
                    .fill(AppTheme.primary.opacity(0.2))
                    .frame(width: 36, height: 36)
                RoundedRectangle(cornerRadius: 6)
                    .fill(AppTheme.primary.opacity(0.1))
                    .frame(width: 120, height: 10)
            }

            VStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(AppTheme.slate100)
                    .frame(height: 8)
                RoundedRectangle(cornerRadius: 6)
                    .fill(AppTheme.slate100)
                    .frame(height: 8)
                RoundedRectangle(cornerRadius: 6)
                    .fill(AppTheme.slate100)
                    .frame(width: 180, height: 8)
            }

            HStack {
                HStack(spacing: 6) {
                    Circle().fill(AppTheme.primary.opacity(0.2)).frame(width: 10, height: 10)
                    Circle().fill(AppTheme.primary.opacity(0.2)).frame(width: 10, height: 10)
                }
                Spacer()
                Text("Premium Feature")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(AppTheme.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.primary.opacity(0.1))
                    .cornerRadius(10)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.primary.opacity(0.1), lineWidth: 1))
    }
}

struct PlansBottomNavItem: View {
    let icon: String
    let title: String
    let active: Bool

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(active ? AppTheme.primary : AppTheme.text400)
            Text(title)
                .font(.system(size: 9, weight: active ? .bold : .medium))
                .foregroundColor(active ? AppTheme.primary : AppTheme.text400)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    SubscriptionPlansView()
}
