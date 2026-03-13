import SwiftUI

// MARK: - Creator Profile Brand View (Brand viewing Creator)
struct CreatorProfileBrandView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            AppTheme.backgroundLight.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        heroSection
                        statsSection
                        rateCardSection
                        portfolioSection
                        locationSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 90)
                }

                bottomNav
            }
        }
        .navigationBarHidden(true)
    }

    private var header: some View {
        HStack {
            HStack(spacing: 8) {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.text900)
                        .padding(6)
                        .background(AppTheme.primary.opacity(0.1))
                        .clipShape(Circle())
                }
                Text("Creator Profile")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.text900)
            }

            Spacer()

            HStack(spacing: 6) {
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(AppTheme.text600)
                }
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(AppTheme.text600)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.9))
        .backdrop()
    }

    private var heroSection: some View {
        VStack(spacing: 10) {
            ZStack(alignment: .bottomTrailing) {
                AsyncImage(url: URL(string: "https://lh3.googleusercontent.com/aida-public/AB6AXuDs6f0E48e7vkom2ctw4-aZt7p2qHvxZSh74JN-12r_X5Srqhw0NeTNjWal1mV2YHO73BUBlH55w61xX7y0ThtIQUNOEozAqgfODtw1HlNqa8c2JC8G3DAJAU9gSnfAYdRAiHLHSKwFRRUTSi9m--PmK0aJpek70o0LBApn4WnnFdsKarTfRhkFqIIedl6Rd1lb1ncxBpehfamoh9NPc2SI-5Pjs0ZXbY0cQ6LDLl5Z8eWYELbKwVyP0E8H53HWPFLVMx2s1eW7grM")) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    AppTheme.slate200
                }
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                .shadow(color: AppTheme.shadowMd, radius: 8, x: 0, y: 4)

                ZStack {
                    Circle()
                        .fill(AppTheme.primary)
                        .frame(width: 24, height: 24)
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                }
                .offset(x: 4, y: 4)
            }

            Text("Sarah J. | Dubai")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppTheme.text900)

            HStack(spacing: 6) {
                Image(systemName: "house.lodge")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(AppTheme.primary)
                Text("Real Estate and Luxury Lifestyle")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.primary)
            }

            HStack(spacing: 6) {
                Image(systemName: "mappin")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(AppTheme.text500)
                Text("Dubai, United Arab Emirates")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(AppTheme.text500)
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
                    Image(systemName: "bookmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppTheme.primary)
                        .frame(width: 44, height: 44)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppTheme.primary.opacity(0.2), lineWidth: 1)
                        )
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 12)
        }
        .padding(.top, 12)
    }

    private var statsSection: some View {
        HStack(spacing: 10) {
            CreatorStatPill(value: "120k", label: "Instagram")
            CreatorStatPill(value: "40k", label: "YouTube")
            CreatorStatPill(value: "5.2%", label: "Eng. Rate")
        }
    }

    private var rateCardSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "creditcard")
                    .foregroundColor(AppTheme.primary)
                Text("Rate Card")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.text900)
            }

            VStack(spacing: 0) {
                RateRow(title: "Instagram Reel", subtitle: "60s edited video with music", price: "$300")
                Divider()
                RateRow(title: "Property Tour (Full)", subtitle: "YouTube 10-15min walkthrough", price: "$850")
                Divider()
                RateRow(title: "Story Set", subtitle: "3x Stories with swipe-up", price: "$150")
            }
            .background(Color.white)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.slate200, lineWidth: 1))
        }
    }

    private var portfolioSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "photo.on.rectangle")
                        .foregroundColor(AppTheme.primary)
                    Text("Recent Collaborations")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppTheme.text900)
                }
                Spacer()
                Button("View All") {}
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppTheme.primary)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                PortfolioTile(title: "EMAAR Properties", imageURL: "https://lh3.googleusercontent.com/aida-public/AB6AXuAB105DpMlDqbwSPhLFQ1KMU0u3qVU8a3yWCERnuyRhrbedF__rwr9h3PFLr7mLeemav7gyk8Ng2p1ToOP6EbjGTlKVK9wMsUzPXXssDG-G4MaAVh9-0lJkjKs6i8MXq4pyIb1ubTPGcl-BINE0IK2kj9U5piAk451sKLWx01mcYHeTi6HH6FpqPFqT5rGzZfGj1rdnoGtwKEoFJVkCHPpc0iB0f0Pe1Fan40Z8UwdNLWgVH_snNljn-IL9sRnmXcY5SouuRYwOznE")
                PortfolioTile(title: "Damac Living", imageURL: "https://lh3.googleusercontent.com/aida-public/AB6AXuA9Xr1CRQCRAIMq8AwdvQoQUgJEoeJEtISE6XKmF9h_j_g1PZfxmgu5M5T8f0rr4XbTarU1NZmWsgzd-xRQH_zqE6W7by9abXrNkHoFsCsUNiiPQnAEOXcFP6fKXLCzknBtpwUg576H6HcsG5rCvkoSWUqGsxUwcvjQRVYrzEACnsYn3BlPThLvMnQn2fCNCHDN7f3w08oJRDODgPZLReW2yegKfUMWgLzUAjnJPE_Hfbo5f064D9J-Uz-vDT14xwEN9Sp7YPun4q4")
                PortfolioTile(title: "Dubai Tourism", imageURL: "https://lh3.googleusercontent.com/aida-public/AB6AXuDMGrvMGvxyNrraX9gMT5nzMMea9vaX_cKBoq14N7lJqSV79YB7AXU4HuhQTHfknu4ZRzJahe6V6irwxoMCYSeu8cGBOLM24aKoRWBDSU_6Gr8COCzw7MFGObnLkdeGG_jBWyftBIDVfw3BRokYCWyThNATCIv355KgdGY97pAwAZgRfYL5BPq6Hr40M1i_pHQhP7riD_zk-fm3qyMeOLaNmWt0_jzVvNe51JTWNpFJf1KbcL7vz6t2UbIZvxx-wrW_j8MIHfHBF8M")
                PortfolioTile(title: "SmartHome Tech", imageURL: "https://lh3.googleusercontent.com/aida-public/AB6AXuBt3i0icE8JghN94edbyJ2IXKB-zHbFEgC_cNDpSO8q0gaV5BeVnm1vkTpS4Cmmt2ZI-r5GiJp_WQtV9L193n0yGCntA9hqEMSBcmotOlp8Fzsf9CQUdC0c99QEcRkEl5-pehZMmyENCu-SaSHM7ETeQdIE4V3gyJ9EN4TrbZX4NBvS07-sIJe0xw0iI2IX_LnkaOBlLmc-ZjzDAUyaJHr6s99YGHJqKkFNU34PWgBPLplj1NsRyth7Whja6sGCwC6iJ99N5TyqHDY")
            }
        }
    }

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "map")
                    .foregroundColor(AppTheme.primary)
                Text("Base Location")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.text900)
            }

            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(AppTheme.slate200)
                    .frame(height: 160)

                AsyncImage(url: URL(string: "https://lh3.googleusercontent.com/aida-public/AB6AXuDEVhC_KJnB6MzwNq7whlARaKmTfGMQ1V2V_FnLnsEZk8-n9ulZlZTqEBRO3B70C-SA8DYCW-tUxVvKayfW2Kn-soCF_L9b8k3R9ddkrrk_veqX2Y42Rr_vh8AsBKMyWHchpewyhl8GMm7e1nlZUNhTsFDrxRCioV4F7Ge1DwbOKvN7WoxgW_9hAbLvvujf-Ho0a117ZqK4OlOSOG5jRZu6-uypqjH3pw6p6PTU372ZAjsiltAipx01qT-kcDgFY88bXmeWtxSevL8")) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    AppTheme.slate200
                }
                .clipShape(RoundedRectangle(cornerRadius: 14))

                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 44, height: 44)
                        .shadow(color: AppTheme.shadowMd, radius: 6, x: 0, y: 4)
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(AppTheme.primary)
                        .font(.system(size: 20, weight: .bold))
                }
            }
        }
    }

    private var bottomNav: some View {
        HStack {
            CreatorProfileBottomNavItem(icon: "safari", title: "Explore", active: false)
            CreatorProfileBottomNavItem(icon: "megaphone", title: "Campaigns", active: false)
            CreatorProfileBottomNavItem(icon: "message", title: "Messages", active: false)
            CreatorProfileBottomNavItem(icon: "person", title: "Profile", active: true)
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .padding(.bottom, 20)
        .background(Color.white.opacity(0.95))
        .overlay(Divider(), alignment: .top)
    }
}

// MARK: - Components

struct CreatorStatPill: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppTheme.primary)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(AppTheme.text500)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.slate200, lineWidth: 1)
        )
    }
}

struct RateRow: View {
    let title: String
    let subtitle: String
    let price: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppTheme.text900)
                Text(subtitle)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(AppTheme.text500)
            }

            Spacer()

            Text(price)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(AppTheme.primary)
        }
        .padding(12)
    }
}

struct PortfolioTile: View {
    let title: String
    let imageURL: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: URL(string: imageURL)) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                AppTheme.slate200
            }
            .frame(height: 140)
            .clipped()

            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0.6), Color.clear]),
                startPoint: .bottom,
                endPoint: .top
            )
            .frame(height: 140)

            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white)
                .padding(8)
        }
        .cornerRadius(12)
    }
}

struct CreatorProfileBottomNavItem: View {
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
    CreatorProfileBrandView()
}
