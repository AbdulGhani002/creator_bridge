import SwiftUI

// MARK: - Settings & Earnings View
struct SettingsEarningsView: View {
    @State private var selectedTab = 0
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            AppTheme.backgroundLight.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                tabs

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        if selectedTab == 0 {
                            earningsContent
                        } else if selectedTab == 1 {
                            placeholderContent(title: "Account")
                        } else {
                            placeholderContent(title: "Security")
                        }
                    }
                    .padding(.bottom, 90)
                }

                bottomNav
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

            Text("Creator Settings")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(AppTheme.text900)
                .padding(.leading, 6)

            Spacer()

            Button(action: {}) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.text900)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.9))
        .backdrop()
    }

    private var tabs: some View {
        HStack(spacing: 24) {
            TabButton(title: "Earnings", active: selectedTab == 0) { selectedTab = 0 }
            TabButton(title: "Account", active: selectedTab == 1) { selectedTab = 1 }
            TabButton(title: "Security", active: selectedTab == 2) { selectedTab = 2 }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .background(Color.white)
        .overlay(Divider(), alignment: .bottom)
    }

    private var earningsContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Earnings Overview")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppTheme.text900)
                .padding(.horizontal, 16)

            HStack(spacing: 12) {
                EarningsCard(title: "Total Balance", value: "$4,250.00", badge: "+12.5%", badgeColor: AppTheme.successGreen)
                EarningsCard(title: "Pending Payout", value: "$850.00", subtitle: "Est. May 24")
            }
            .padding(.horizontal, 16)

            revenueChart
            payoutMethods
            visibilitySettings
        }
        .padding(.top, 6)
    }

    private var revenueChart: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Revenue Growth")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppTheme.text900)
                Spacer()
                Text("Last 7 days")
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(AppTheme.text500)
            }

            HStack(alignment: .bottom, spacing: 6) {
                ForEach([40, 60, 85, 45, 70, 90, 30], id: \.self) { value in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(value == 85 ? AppTheme.primary : AppTheme.primary.opacity(0.2))
                        .frame(height: CGFloat(value))
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 120)

            HStack {
                ForEach(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"], id: \.self) { day in
                    Text(day)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(AppTheme.text400)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.slate200, lineWidth: 1))
        .padding(.horizontal, 16)
    }

    private var payoutMethods: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Payout Methods")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(AppTheme.text900)
                .padding(.horizontal, 16)

            HStack {
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.blue)
                            .frame(width: 36, height: 36)
                        Text("S")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Stripe Connect")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppTheme.text900)
                        Text("Linked to **** 4242")
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(AppTheme.text500)
                    }
                }

                Spacer()

                Text("Connected")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(AppTheme.successGreen)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.successGreen.opacity(0.1))
                    .cornerRadius(10)
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.slate200, lineWidth: 1))
            .padding(.horizontal, 16)

            Button(action: {}) {
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle")
                    Text("Add payout method")
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppTheme.text500)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppTheme.slate300, style: StrokeStyle(lineWidth: 1, dash: [6]))
                )
            }
            .padding(.horizontal, 16)
        }
    }

    private var visibilitySettings: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Account Visibility")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(AppTheme.text900)
                Spacer()
                Text("PRO PLAN")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(AppTheme.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.primary.opacity(0.1))
                    .cornerRadius(8)
            }
            .padding(.horizontal, 16)

            ToggleRow(title: "Public Profile", subtitle: "Allow search engines to index your profile.", enabled: true)
                .padding(.horizontal, 16)

            ToggleRow(title: "Incognito Mode", subtitle: "Browse and create without notifications to followers.", enabled: false, locked: true)
                .padding(.horizontal, 16)

            ToggleRow(title: "Show Revenue Stats", subtitle: "Display your total earnings on your public profile.", enabled: false)
                .padding(.horizontal, 16)
        }
    }

    private func placeholderContent(title: String) -> some View {
        VStack(spacing: 12) {
            Text("\(title) settings coming soon")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(AppTheme.text500)
                .padding(.top, 40)
        }
        .frame(maxWidth: .infinity)
    }

    private var bottomNav: some View {
        HStack {
            SettingsBottomNavItem(icon: "house", title: "Home", active: false)
            SettingsBottomNavItem(icon: "chart.bar", title: "Analytics", active: false)
            SettingsBottomNavItem(icon: "creditcard", title: "Earnings", active: true)
            SettingsBottomNavItem(icon: "person", title: "Profile", active: false)
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .padding(.bottom, 20)
        .background(Color.white.opacity(0.95))
        .overlay(Divider(), alignment: .top)
    }
}

// MARK: - Components

struct TabButton: View {
    let title: String
    let active: Bool
    let action: () -> Void

    var body: some View {
        VStack(spacing: 6) {
            Button(action: action) {
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(active ? AppTheme.primary : AppTheme.text500)
            }

            if active {
                RoundedRectangle(cornerRadius: 2)
                    .fill(AppTheme.primary)
                    .frame(height: 3)
            }
        }
        .padding(.bottom, 6)
    }
}

struct EarningsCard: View {
    let title: String
    let value: String
    var badge: String? = nil
    var badgeColor: Color? = nil
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(AppTheme.text500)

            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppTheme.text900)

            if let badge = badge {
                HStack(spacing: 4) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 10, weight: .bold))
                    Text(badge)
                        .font(.system(size: 10, weight: .bold))
                }
                .foregroundColor(badgeColor ?? AppTheme.successGreen)
            }

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(AppTheme.text400)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.slate200, lineWidth: 1))
    }
}

struct ToggleRow: View {
    let title: String
    let subtitle: String
    let enabled: Bool
    var locked: Bool = false

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(title)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppTheme.text900)
                    if locked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(AppTheme.warningOrange)
                    }
                }
                Text(subtitle)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(AppTheme.text500)
            }

            Spacer()

            ZStack(alignment: enabled ? .trailing : .leading) {
                Capsule()
                    .fill(enabled ? AppTheme.primary : AppTheme.slate300)
                    .frame(width: 40, height: 20)

                Circle()
                    .fill(Color.white)
                    .frame(width: 16, height: 16)
                    .padding(2)
            }
        }
        .padding(12)
        .background(locked ? AppTheme.slate100 : Color.white)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.slate200, lineWidth: 1))
        .opacity(locked ? 0.7 : 1.0)
    }
}

struct SettingsBottomNavItem: View {
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
    SettingsEarningsView()
}
