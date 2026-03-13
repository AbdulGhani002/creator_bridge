import SwiftUI

struct CreatorDashboardView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundLight.ignoresSafeArea()

                VStack(spacing: 0) {
                    header

                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 20) {
                            statsSection
                            newOpportunitiesSection
                            recentMessagesSection
                        }
                        .padding(.bottom, 90)
                    }

                    bottomNav
                }
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: "https://lh3.googleusercontent.com/aida-public/AB6AXuCNAa9YiUXjQFIETGCjd7Pr1DvWbIT8jBxV8rIrBvKE-X86nTfyoZ9vZ-GVd8Owy4RuA-xy1jLH-MihBjC3qjZhRMXl9e4QvDP_MouuFb6Ey9kyBLH4gENd9JETThw-0CLBtwL9f6aq5dwMuZ-FGhobrTwiMqBdnfZRnCjlUT7CTV-WnkWXCLsgVuwSiew28ypbEIVgUa7ngSLezg_lG8tUhIuwd0-i-ccTuvxVMhyXo7ed3rdQPFftQLx3reJzKeTosWKFITirQgk")) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                AppTheme.slate200
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())
            .overlay(Circle().stroke(AppTheme.primary.opacity(0.2), lineWidth: 2))

            VStack(alignment: .leading, spacing: 2) {
                Text("Alex Rivera")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.text900)

                Text("Professional Creator")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(AppTheme.text500)
            }

            Spacer()

            Button(action: {}) {
                Image(systemName: "bell")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.text600)
                    .frame(width: 36, height: 36)
                    .background(AppTheme.slate100)
                    .cornerRadius(18)
            }
        }
        .padding(16)
        .background(colorScheme == .dark ? AppTheme.slate900 : Color.white)
        .overlay(Divider(), alignment: .bottom)
    }

    // MARK: - Stats

    private var statsSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                StatMiniCard(
                    icon: "eye",
                    title: "Profile Views",
                    value: "12.5K",
                    badge: "+15%",
                    badgeColor: AppTheme.successGreen
                )
                StatMiniCard(
                    icon: "doc.text",
                    title: "Active Proposals",
                    value: "8",
                    badge: "Stable",
                    badgeColor: AppTheme.text400
                )
            }

            StatPrimaryCard(
                title: "Total Earnings (This Month)",
                value: "$4,250",
                delta: "+12%",
                progress: 0.75,
                footnote: "75% of your $6,000 monthly goal"
            )
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }

    // MARK: - New Opportunities

    private var newOpportunitiesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("New Opportunities")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.text900)
                Spacer()
                Button("View all") {}
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppTheme.primary)
            }

            OpportunityCard(
                niche: "Real Estate",
                price: "$300 / Reel",
                title: "Promote Luxury Condos in Dubai",
                description: "Highlight the premium amenities and views of the Azure Heights project.",
                imageURL: "https://lh3.googleusercontent.com/aida-public/AB6AXuDlGErqadcMy8bGWJO2jy2vSvZb4JVaQSoF3aq-SOkghbRyPju8pBbWGQkkKvJIuCbnXV0HkzTigtm91oX-Tl8tZ4dZNH2Mf3zwLSNy2Z4AWlNvNry_K1uLvtkDG5oPsdNceOcQ3cKTWufLCS_YccY8Fy3AQFlgxHwiH40riXtfJeQrTIEybr86mAIgm1eBejBuOLEqpUvaVm58QRp8IRo_4LbcN_o4HBMR1kh4lkhmkZieuim9pjxFr55PUwH9o_tLjrxv90h7FuY",
                filledCTA: true
            )

            OpportunityCard(
                niche: "Tech Review",
                price: "$550 / Video",
                title: "NextGen Smartphone Launch",
                description: "Create an unboxing and feature walkthrough for the new flagship device.",
                imageURL: "https://lh3.googleusercontent.com/aida-public/AB6AXuCPhzjVVmLBvGcO0bjKdSl2R1zx8Zv_FEDfryoz8FML-SRvoJg21I_QCHNkawtPIYRv5CiGtPn-1zSI-pGCNVJzUVHK4DuZmFOGzyBuQy5Knii0aOyTKebi0ntVJb37FlICLJprWOv4rnungmvQJe6ait_9yN7AerUneO-ds25H2FA8QKjFAVpjy_O1LpSxZj3J32AQGi2D6GwW5VahIBH0ykh2uVF2ORyxtk-qFXQeXdsaJ86McGP6TaF-Zh6HgXBVzAc9n7y3Rtk",
                filledCTA: false
            )
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Recent Messages

    private var recentMessagesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Messages")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.text900)
                Spacer()
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(AppTheme.text500)
                }
            }

            MessageRow(
                name: "Sarah from Zenith Agency",
                time: "2m ago",
                preview: "The draft looks perfect! We are ready to proceed with the second phase of the campaign...",
                imageURL: "https://lh3.googleusercontent.com/aida-public/AB6AXuDLfgKwOBGG5q2OIhtsjvXVKUAnNDDKVenSspi48vvKZo8nQQvoPa0U_nvtj4YfsmxUdLyHx2JIXb_HGdfNYqtQC8rXeqsc_69vJUZby8SJ46GVAgWnM1zDDRT1YcS4U4sXW7VfUbMbR5PMgeRXH4c1P7IxweJaHWOQCiQQt636VUJ9yBbPfPE2sfc6lB-IOvRiQ0NcO-dmUegNeVmgxDhWEGpJZhuUqB5XlFTe6y09COXQtmHpV1Aw0MBtg1Qm_iGhVmw02lzAXuY",
                online: true,
                highlighted: true
            )

            MessageRow(
                name: "Marcus Wright",
                time: "1h ago",
                preview: "Sent you a new proposal for the summer festival. Let me know your thoughts.",
                imageURL: "https://lh3.googleusercontent.com/aida-public/AB6AXuACv8vG6AxAwvFNnWCbtuTP00bG7R9zm1-Le8-JtL3F4HhMAq_4oPWSn8aVR73nxZNiiDsC7Vxw0K7twGcPHGen-TQFkeo7MpBu9kTfezvmpBMHgFNRBW5mSebTOuvbZxCuVQylGyr7G42TO1ULtEIQkyoXFRDjuwQreyWdDLciNuP92bpQ4iscY9yoEmMz3ltA5m427WVsYZ8DR4rWx6gLkj0-bjXFTW7FqwBQ63ReYG47np0GvPFaG30MK2JstW7tvR5foUhZ91I",
                online: false,
                highlighted: false
            )
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Bottom Navigation

    private var bottomNav: some View {
        HStack {
            DashboardBottomNavItem(icon: "house", title: "Home", active: true)
            DashboardBottomNavItem(icon: "magnifyingglass", title: "Search", active: false)
            DashboardBottomNavItem(icon: "message", title: "Messages", active: false, badge: true)
            DashboardBottomNavItem(icon: "person", title: "Profile", active: false)
        }
        .padding(.horizontal, 12)
        .padding(.top, 10)
        .padding(.bottom, 20)
        .background(Color.white.opacity(0.95))
        .overlay(Divider(), alignment: .top)
    }
}

// MARK: - Components

struct StatMiniCard: View {
    let icon: String
    let title: String
    let value: String
    let badge: String
    let badgeColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(AppTheme.primary)
                Spacer()
                Text(badge)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(badgeColor)
            }

            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(AppTheme.text500)

            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppTheme.text900)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.slate200, lineWidth: 1)
        )
    }
}

struct StatPrimaryCard: View {
    let title: String
    let value: String
    let delta: String
    let progress: Double
    let footnote: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.8))
                Spacer()
                Image(systemName: "creditcard")
                    .foregroundColor(.white)
            }

            HStack(alignment: .lastTextBaseline, spacing: 6) {
                Text(value)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
                Text(delta)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color.white.opacity(0.8))
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.2))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white)
                        .frame(width: geometry.size.width * progress)
                }
            }
            .frame(height: 6)

            Text(footnote)
                .font(.system(size: 10, weight: .regular))
                .foregroundColor(Color.white.opacity(0.7))
        }
        .padding(16)
        .background(AppTheme.primary)
        .cornerRadius(14)
        .shadow(color: AppTheme.primary.opacity(0.2), radius: 10, x: 0, y: 6)
    }
}

struct OpportunityCard: View {
    let niche: String
    let price: String
    let title: String
    let description: String
    let imageURL: String
    let filledCTA: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AsyncImage(url: URL(string: imageURL)) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                AppTheme.slate200
            }
            .frame(height: 120)
            .clipped()

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(niche.uppercased())
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(AppTheme.primary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(AppTheme.primary.opacity(0.1))
                        .cornerRadius(6)

                    Spacer()

                    Text(price)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppTheme.text900)
                }

                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppTheme.text900)

                Text(description)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(AppTheme.text500)
                    .lineLimit(2)

                Button(action: {}) {
                    Text("Apply Now")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(filledCTA ? .white : AppTheme.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(filledCTA ? AppTheme.primary : Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(filledCTA ? Color.clear : AppTheme.primary, lineWidth: 1)
                        )
                        .cornerRadius(8)
                }
            }
            .padding(12)
            .background(Color.white)
        }
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.slate200, lineWidth: 1)
        )
    }
}

struct MessageRow: View {
    let name: String
    let time: String
    let preview: String
    let imageURL: String
    let online: Bool
    let highlighted: Bool

    var body: some View {
        HStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    AppTheme.slate200
                }
                .frame(width: 44, height: 44)
                .clipShape(Circle())

                if online {
                    Circle()
                        .fill(AppTheme.successGreen)
                        .frame(width: 10, height: 10)
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(name)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppTheme.text900)
                    Spacer()
                    Text(time)
                        .font(.system(size: 9, weight: .regular))
                        .foregroundColor(AppTheme.text400)
                }

                Text(preview)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(AppTheme.text500)
                    .lineLimit(1)
            }
        }
        .padding(12)
        .background(highlighted ? Color.white : Color.white.opacity(0.8))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.slate200, lineWidth: 1)
        )
    }
}

struct DashboardBottomNavItem: View {
    let icon: String
    let title: String
    let active: Bool
    var badge: Bool = false

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(active ? AppTheme.primary : AppTheme.text400)

                if badge {
                    Circle()
                        .fill(AppTheme.primary)
                        .frame(width: 6, height: 6)
                        .offset(x: 10, y: -8)
                }
            }

            Text(title)
                .font(.system(size: 9, weight: active ? .bold : .medium))
                .foregroundColor(active ? AppTheme.primary : AppTheme.text400)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    CreatorDashboardView()
}
