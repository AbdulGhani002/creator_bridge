import SwiftUI

// MARK: - Creator Search View (Brand Discovery)
struct CreatorSearchView: View {
    @State private var searchText = "Real Estate Dubai"
    @Environment(\.dismiss) var dismiss

    private let creators: [CreatorCardData] = [
        CreatorCardData(
            name: "John Smith",
            location: "Dubai, UAE",
            niche: "Real Estate",
            followers: "120k Followers",
            startingRate: "$300/post",
            imageURL: "https://lh3.googleusercontent.com/aida-public/AB6AXuBqqbGhbIhXx-BV_gr1S69vtaStyA_MUm1fRD_-PYSWz-piOJF7hjr8T3ervhcUfKenpxiUOlDR6DNq8C7NFzUPhUwteAK3zsIYHKYPxSVxt5hijfhYClA7T45Szty_SzYaNAbGuw0f3mi42mEYxp8UP68BYGkqLNkI6BejKPA8suCb8DCSAGsjYT9HVL8OqRi1sAUX1qrpUoIfO3ya4gtZ7Vb49gkREbH1AGFkvQLfgeU4DBE6GqirlE35dzaKMaXL36cwQsN6Onk",
            showCamera: true,
            showVideo: true
        ),
        CreatorCardData(
            name: "Sarah Chen",
            location: "Dubai Marina, UAE",
            niche: "Luxury Living",
            followers: "85k Followers",
            startingRate: "$450/post",
            imageURL: "https://lh3.googleusercontent.com/aida-public/AB6AXuDPvWcWF4HpoFRsGnr5rm6fqWSG8nDj3ekh1IdVqnRQeV1fabhTWxQW2whgXVRb-0MbCh-Nccv_qmBPSLZ9qDizrrGLmth1K6n-NlNO-xo2oBu_PS9SH80v54sbeP4080zqdEDYgLwQ9ULfVOKs8GXAoFXrxAhiNx2UFVmHnr4X67bTa9V4TybJQUKnLSpUv9VYnmo0Y4C55Otz5LieqnccYoVyeQ4Xz71vwwg-Gieu2SWpncsusKjB-4gn1PP83pFDjoqjLf6V-KU",
            showCamera: true,
            showVideo: false
        ),
        CreatorCardData(
            name: "Marcus Valli",
            location: "Downtown Dubai",
            niche: "Investment",
            followers: "210k Followers",
            startingRate: "$750/post",
            imageURL: "https://lh3.googleusercontent.com/aida-public/AB6AXuCGwuwF6fHVBJ2_3AG9m5-HojRIiUVSljwcdYqf9Z2H_dW_OJ9dDzP-4M2yUScVhxGdX5uXqB1th2iPK5ksd2kW4GfFllupx1ylYYT9jMHKzE3SWyvUis74BIy7jYWqIaUMQQZaTL11KChjfG2RNgxNBwaFaUlzMPAGkzJ9gf65CuD1CkUiHdkQeJAHUhyosVChI6ePARiIXVYhQLRlzqX3nKSJM2sPRmlddwNV-qDGWHnwdfMHPaBbUABXUcwQhVxU4x2rGBxqMbc",
            showCamera: false,
            showVideo: true
        )
    ]

    var body: some View {
        ZStack {
            AppTheme.backgroundLight.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                searchBar
                filterChips

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Featured Real Estate Creators")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(AppTheme.text900)
                            Spacer()
                            Text("248 Results")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(AppTheme.primary)
                        }

                        ForEach(creators) { creator in
                            CreatorCardView(creator: creator)
                        }

                        mapCTA
                    }
                    .padding(16)
                    .padding(.bottom, 90)
                }

                bottomNav
            }
        }
        .navigationBarHidden(true)
    }

    private var header: some View {
        HStack(spacing: 12) {
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.primary)
                    .frame(width: 36, height: 36)
                    .background(AppTheme.primary.opacity(0.1))
                    .clipShape(Circle())
            }

            Text("Find Creators")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(AppTheme.text900)

            Spacer()

            Button(action: {}) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.text600)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.9))
        .backdrop()
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AppTheme.text400)

            TextField("Search by niche, name or location", text: $searchText)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(AppTheme.text900)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(AppTheme.slate50)
        .cornerRadius(14)
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
        .background(Color.white.opacity(0.9))
        .backdrop()
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                HStack(spacing: 6) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 12, weight: .semibold))
                    Text("Dubai")
                        .font(.system(size: 12, weight: .semibold))
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .semibold))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(AppTheme.primary)
                .foregroundColor(.white)
                .cornerRadius(20)

                HStack(spacing: 6) {
                    Text("Real Estate")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppTheme.text700)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(AppTheme.text400)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(AppTheme.slate100)
                .cornerRadius(20)

                HStack(spacing: 6) {
                    Text("50k+ Followers")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppTheme.text700)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(AppTheme.text400)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(AppTheme.slate100)
                .cornerRadius(20)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(Color.white.opacity(0.9))
        .backdrop()
    }

    private var mapCTA: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 14)
                .fill(AppTheme.slate200)
                .frame(height: 140)

            VStack(alignment: .leading, spacing: 4) {
                Text("Discovery Map")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                Text("Find creators near your property locations")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(12)
            .background(Color.black.opacity(0.35))
            .cornerRadius(10)
            .padding(12)

            Image(systemName: "map")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppTheme.primary)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0.5), Color.clear]),
                startPoint: .bottom,
                endPoint: .top
            )
        )
        .cornerRadius(14)
    }

    private var bottomNav: some View {
        HStack {
            SearchBottomNavItem(icon: "safari", title: "Discover", active: true)
            SearchBottomNavItem(icon: "megaphone", title: "Campaigns", active: false)

            ZStack {
                Circle()
                    .fill(AppTheme.primary)
                    .frame(width: 54, height: 54)
                    .shadow(color: AppTheme.primary.opacity(0.3), radius: 10, x: 0, y: 6)
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)

            SearchBottomNavItem(icon: "message", title: "Messages", active: false)
            SearchBottomNavItem(icon: "person", title: "Profile", active: false)
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .padding(.bottom, 20)
        .background(Color.white.opacity(0.95))
        .overlay(Divider(), alignment: .top)
    }
}

// MARK: - Creator Card

struct CreatorCardData: Identifiable {
    let id = UUID()
    let name: String
    let location: String
    let niche: String
    let followers: String
    let startingRate: String
    let imageURL: String
    let showCamera: Bool
    let showVideo: Bool
}

struct CreatorCardView: View {
    let creator: CreatorCardData

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                AsyncImage(url: URL(string: creator.imageURL)) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    AppTheme.slate200
                }
                .frame(width: 70, height: 70)
                .clipShape(Circle())
                .overlay(Circle().stroke(AppTheme.primary.opacity(0.1), lineWidth: 2))

                VStack(alignment: .leading, spacing: 6) {
                    Text(creator.name)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(AppTheme.text900)

                    HStack(spacing: 4) {
                        Image(systemName: "mappin")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(AppTheme.text500)
                        Text(creator.location)
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(AppTheme.text500)
                    }
                }

                Spacer()

                HStack(spacing: 6) {
                    if creator.showCamera {
                        IconBadge(icon: "camera")
                    }
                    if creator.showVideo {
                        IconBadge(icon: "play.circle")
                    }
                }
            }
            .padding(12)

            HStack(spacing: 8) {
                Text(creator.niche)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(AppTheme.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.primary.opacity(0.1))
                    .cornerRadius(8)

                Text(creator.followers)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(AppTheme.text600)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.slate100)
                    .cornerRadius(8)

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 10)

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Starting Rate")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(AppTheme.text400)
                    Text(creator.startingRate)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(AppTheme.text900)
                }
                Spacer()
                Button(action: {}) {
                    Text("View Profile")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(AppTheme.primary)
                        .cornerRadius(10)
                }
            }
            .padding(12)
            .background(AppTheme.slate50)
        }
        .background(Color.white)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppTheme.slate200, lineWidth: 1)
        )
    }
}

struct IconBadge: View {
    let icon: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(AppTheme.slate100)
                .frame(width: 30, height: 30)

            Image(systemName: icon)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(AppTheme.text500)
        }
    }
}

struct SearchBottomNavItem: View {
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
    CreatorSearchView()
}
