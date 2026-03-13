import SwiftUI

// MARK: - Brand Profile View
struct BrandProfileView: View {
    @State private var selectedTab = 0
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            AppTheme.backgroundLight.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        heroSection
                        statsSection
                        tabBar

                        if selectedTab == 0 {
                            aboutContent
                        } else if selectedTab == 1 {
                            campaignsContent
                        } else {
                            collaborationsContent
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
                    .frame(width: 32, height: 32)
            }

            Spacer()

            Text("DubaiLuxuryHomes")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(AppTheme.text900)

            Spacer()

            Button(action: {}) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.text900)
                    .frame(width: 32, height: 32)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.9))
        .backdrop()
    }

    private var heroSection: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                AsyncImage(url: URL(string: "https://lh3.googleusercontent.com/aida-public/AB6AXuBpQ1FdugTlNGQIO43pTutVCeMQPgT83j_fOPTVK-_uezZK-BkCW2ffbHuhW3cr5ep8sIwDaizCGUSpOBh-IvpaYipLggdX3iQHYTSqnqTeyZfMJUsIx6r1ER5QOyGmpPuADN9Od0TnBzmAmiO9Z7tvytQNwB3VYUpo1M41EjRv4KJUf2JQ-h_TLdpcQCZ7PIl30Ef7XA1EHWJ-NAJTXk0LLnCH0PjelMExFX7eyaDu_NzDKP9xEosm4os1gSPR6BIcwlS8-znGBCg")) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    AppTheme.slate200
                }
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .overlay(Circle().stroke(AppTheme.primary.opacity(0.1), lineWidth: 4))

                ZStack {
                    Circle()
                        .fill(AppTheme.primary)
                        .frame(width: 28, height: 28)
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
                .offset(x: 6, y: 6)
            }

            VStack(spacing: 6) {
                Text("DubaiLuxuryHomes")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(AppTheme.text900)

                HStack(spacing: 6) {
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppTheme.primary)
                    Text("Real Estate - Dubai, UAE")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppTheme.primary)
                }

                Text("Curating the finest residential properties in the Middle East. Specialized in waterfront villas, penthouse suites, and architectural masterpieces for high-net-worth investors.")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(AppTheme.text600)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
            }

            HStack(spacing: 10) {
                Button(action: {}) {
                    HStack(spacing: 6) {
                        Image(systemName: "envelope.fill")
                        Text("Message")
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(AppTheme.primary)
                    .cornerRadius(12)
                }

                Button(action: {}) {
                    HStack(spacing: 6) {
                        Image(systemName: "person.badge.plus")
                        Text("Follow")
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(AppTheme.text900)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(AppTheme.slate100)
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal, 12)
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(Color.white)
    }

    private var statsSection: some View {
        HStack(spacing: 12) {
            BrandStatPill(value: "120", label: "Properties")
            BrandStatPill(value: "45.2k", label: "Followers")
            BrandStatPill(value: "310", label: "Deals Closed")
        }
        .padding(.horizontal, 16)
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(0..<3, id: \.self) { index in
                VStack(spacing: 6) {
                    Button(action: { selectedTab = index }) {
                        Text(["About", "Campaigns", "Collaborations"][index])
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(selectedTab == index ? AppTheme.primary : AppTheme.text500)
                    }

                    if selectedTab == index {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(AppTheme.primary)
                            .frame(height: 3)
                            .padding(.horizontal, 10)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
        }
        .background(Color.white)
        .overlay(Divider(), alignment: .bottom)
    }

    private var aboutContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Location and Presence")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.text900)

                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppTheme.slate200)
                        .frame(height: 160)

                    AsyncImage(url: URL(string: "https://lh3.googleusercontent.com/aida-public/AB6AXuDEVhC_KJnB6MzwNq7whlARaKmTfGMQ1V2V_FnLnsEZk8-n9ulZlZTqEBRO3B70C-SA8DYCW-tUxVvKayfW2Kn-soCF_L9b8k3R9ddkrrk_veqX2Y42Rr_vh8AsBKMyWHchpewyhl8GMm7e1nlZUNhTsFDrxRCioV4F7Ge1DwbOKvN7WoxgW_9hAbLvvujf-Ho0a117ZqK4OlOSOG5jRZu6-uypqjH3pw6p6PTU372ZAjsiltAipx01qT-kcDgFY88bXmeWtxSevL8")) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        AppTheme.slate200
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    HStack(spacing: 6) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Downtown Dubai, UAE")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppTheme.primary.opacity(0.9))
                    .cornerRadius(14)
                }
            }

            campaignsContent
            collaborationsContent
        }
        .padding(.horizontal, 16)
    }

    private var campaignsContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Active Campaigns")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.text900)
                Spacer()
                Button("View all") {}
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(AppTheme.primary)
            }

            CampaignRow(
                label: "New Project",
                title: "The Sky Garden Residences",
                description: "Exclusive pre-launch opportunity for luxury apartments in the Marina.",
                imageURL: "https://lh3.googleusercontent.com/aida-public/AB6AXuBkhAfkuopPn1WssnAPMJBNjVWMSFPX3pk1_MH1H1gyMFhyPFhM2kiEaOojMvNyk_Iv4jvoQ51Lkf-8ZIi_Ezg2LMQLIhkjqWfC9OsP1kXhFrkG2PVw5a70epBHfIidRnKj672KMRMuwkbfXfsx5gTXcpl4wkRlCM_rzhSkFScFVCjxfMh89zD4jEyTdEphJDfbiURytFisJ2QKWflRdpZiNHfqo7nqv-WOs-1fHNK-y9YatUSq2Pkq_x3wdUmm1oIzqyVkeds33Xg"
            )

            CampaignRow(
                label: "Limited Offer",
                title: "Summer Waterfront Collection",
                description: "Curated portfolio of beachfront villas with private beach access.",
                imageURL: "https://lh3.googleusercontent.com/aida-public/AB6AXuBqqs7Vnd8ys_MQs3k9ujwzZQIjQ1rW3vIK7fqCzU_HT8qalRGZqoYMtwtVR-MPu9rPNVXTgP4GSAEn8wI9qlR6UNPKOelVFZ07MKOF4iHZ0hXkNt_c9PXkNkwrmOnhmgxT8r5Y9g2YVNPSQTogLWeeAZh9p--GOw7pdNBE-v_xds94VahG2Thzkap1LDBfwhUtyCjmUj_1zK8FTvJoJGMG6sNyM48Et7wXgp7tVbBS4WEYs8q3eN0bamJ6Dkl8AfvsqDG0TCFiU2Q"
            )
        }
    }

    private var collaborationsContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Past Collaborations")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(AppTheme.text900)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    CollaborationPill(icon: "building.columns", title: "Zaha Hadid Arch")
                    CollaborationPill(icon: "diamond", title: "Cartier UAE")
                    CollaborationPill(icon: "airplane", title: "Emirates Sky")
                    CollaborationPill(icon: "bed.double", title: "Four Seasons")
                }
                .padding(.vertical, 4)
            }
        }
    }

    private var bottomNav: some View {
        HStack {
            BrandBottomNavItem(icon: "house", title: "Home", active: false)
            BrandBottomNavItem(icon: "safari", title: "Explore", active: false)

            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(AppTheme.primary)
                    .frame(width: 48, height: 48)
                    .shadow(color: AppTheme.primary.opacity(0.3), radius: 10, x: 0, y: 6)
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)

            BrandBottomNavItem(icon: "bell", title: "Activity", active: false)
            BrandBottomNavItem(icon: "person", title: "Profile", active: true)
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .padding(.bottom, 20)
        .background(Color.white.opacity(0.95))
        .overlay(Divider(), alignment: .top)
    }
}

// MARK: - Components

struct BrandStatPill: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppTheme.primary)
            Text(label.uppercased())
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(AppTheme.text500)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color.white)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppTheme.slate200, lineWidth: 1)
        )
    }
}

struct CampaignRow: View {
    let label: String
    let title: String
    let description: String
    let imageURL: String

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: imageURL)) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                AppTheme.slate200
            }
            .frame(width: 64, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(label.uppercased())
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(AppTheme.primary)
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(AppTheme.text900)
                Text(description)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(AppTheme.text500)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(10)
        .background(Color.white)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppTheme.slate200, lineWidth: 1)
        )
    }
}

struct CollaborationPill: View {
    let icon: String
    let title: String

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 48, height: 48)
                    .overlay(Circle().stroke(AppTheme.slate200, lineWidth: 1))
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(AppTheme.text400)
            }

            Text(title)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(AppTheme.text500)
                .multilineTextAlignment(.center)
                .frame(width: 72)
        }
    }
}

struct BrandBottomNavItem: View {
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
    BrandProfileView()
}
