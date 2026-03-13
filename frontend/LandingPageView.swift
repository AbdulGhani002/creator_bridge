import SwiftUI

struct LandingPageView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    navBar
                    heroSection
                    discoverySection
                    howItWorksSection
                    topCategoriesSection
                    ctaSection
                    footerSection
                }
            }
            .background(colorScheme == .dark ? AppTheme.backgroundDark : AppTheme.backgroundLight)
            .navigationBarHidden(true)
        }
    }

    // MARK: - Navigation Bar

    private var navBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppTheme.primary)
                        .frame(width: 32, height: 32)

                    Image(systemName: "link")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .semibold))
                }

                Text("CreatorBridge")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.text900)
            }

            Spacer()

            HStack(spacing: 20) {
                NavigationLink(destination: Text("Discover")) {
                    Text("Discover")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppTheme.text600)
                }

                NavigationLink(destination: Text("Categories")) {
                    Text("Categories")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppTheme.text600)
                }

                NavigationLink(destination: Text("Pricing")) {
                    Text("Pricing")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppTheme.text600)
                }
            }

            Spacer()

            HStack(spacing: 12) {
                Button("Login") {}
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(AppTheme.text700)

                Button("Join Now") {}
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(AppTheme.primary)
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(colorScheme == .dark ? AppTheme.backgroundDark.opacity(0.9) : Color.white.opacity(0.95))
        .overlay(Divider(), alignment: .bottom)
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Text("New: Hyper-local creator filtering")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppTheme.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(AppTheme.primary.opacity(0.1))
                    .cornerRadius(20)

                (Text("Bridge the Gap Between ")
                    .foregroundColor(AppTheme.text900)
                 + Text("Brands")
                    .foregroundColor(AppTheme.primary)
                 + Text(" and ")
                    .foregroundColor(AppTheme.text900)
                 + Text("Local Creators.")
                    .foregroundColor(AppTheme.primary))
                    .font(.system(size: 34, weight: .black))
                    .multilineTextAlignment(.center)

                Text("The location-based marketplace for authentic creator collaborations. Connect with talent in your neighborhood and grow your presence locally.")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(AppTheme.text600)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)

            HStack(spacing: 12) {
                Button(action: {}) {
                    Text("I am a Creator")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AppTheme.primary)
                        .cornerRadius(14)
                }

                Button(action: {}) {
                    Text("I am a Brand")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(AppTheme.text900)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(colorScheme == .dark ? AppTheme.slate800 : Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(AppTheme.slate200, lineWidth: 1)
                        )
                        .cornerRadius(14)
                }
            }
            .padding(.horizontal, 20)

            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(AppTheme.slate100)
                    .shadow(color: AppTheme.shadowLg, radius: 16, x: 0, y: 10)

                AsyncImage(url: URL(string: "https://lh3.googleusercontent.com/aida-public/AB6AXuCEQxOThrnqMd1dfa5zTws2ZumGPYh0VLQTSdbbSVX0MzqpgXNv5pBFYd99O7kbKTGPZz0697SlCYsYCSGWQrK381F-jMx4lsWAvQ2lbIIvaFWcGrU-gHi9qXtrnQqynPyK_rVx7MH8r8xwAD2QqjgiNMOWY1rcWv3yT3OeoNCarlA2M1s-mu-0V5Uky4AoWPI5XP4vyQi0w6JP3jdfiMqs7NWe6sXAeDm9N3ZIW78IStpj76vRAka8_o1DLDYHXB7KltBhNXwFox8")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    AppTheme.slate200
                }
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .padding(8)
            }
            .frame(height: 260)
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 24)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [AppTheme.primaryLight, AppTheme.slate100]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    // MARK: - Discovery by Location

    private var discoverySection: some View {
        VStack(spacing: 20) {
            Text("Discovery by Location")
                .font(.system(size: 24, weight: .black))
                .foregroundColor(AppTheme.text900)

            Text("Find the perfect creative partner right in your neighborhood. Our map-based discovery tool ensures relevance and local authenticity for every campaign.")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(AppTheme.text600)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 18)
                    .fill(AppTheme.slate200)
                    .frame(height: 220)

                AsyncImage(url: URL(string: "https://lh3.googleusercontent.com/aida-public/AB6AXuCTqnvxSCIl6oTaUbv1P5AMhsafnjUOsg70DxGlgF6BY4xsZyRygc8BbN57QvocDQkPGMURh111PnpK26jB121Ph11Qb8ify9Qjjy8kItZdIxuQrTVkeSngSyKuYm_Ln2H1fHyBkizVDVCqilcf84kQTKqOZdUOxhSi3DJEKnX5nN5G-XXGSEjkv68oYCnxdZ2QTxDjagaqByviUBP-SMPQsNFGNDFdrA19F-Fu0zBzZrcJuicfQsVuEtyipN_Fed8ohAUcUHqnH0g")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    AppTheme.slate200
                }
                .clipShape(RoundedRectangle(cornerRadius: 18))

                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.primary.opacity(0.2))
                            .frame(width: 36, height: 36)
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(AppTheme.primary)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Brooklyn, NY")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppTheme.text900)
                        Text("124 active creators found")
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(AppTheme.text500)
                    }
                }
                .padding(12)
                .background(Color.white.opacity(0.9))
                .cornerRadius(12)
                .padding(12)
            }
            .padding(.horizontal, 20)

            VStack(spacing: 16) {
                DiscoveryFeatureRow(
                    icon: "magnifyingglass",
                    title: "Hyper-Local Search",
                    description: "Filter creators by city, neighborhood, or landmarks to find the perfect fit."
                )
                DiscoveryFeatureRow(
                    icon: "checkmark.seal.fill",
                    title: "Authentic Context",
                    description: "Content that resonates with the local community because creators are part of it."
                )
                DiscoveryFeatureRow(
                    icon: "shippingbox.fill",
                    title: "Reduced Logistics",
                    description: "Save time and shipping costs with creators already on-site and ready to shoot."
                )
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 28)
        .background(Color.white)
    }

    // MARK: - How It Works

    private var howItWorksSection: some View {
        VStack(spacing: 20) {
            Text("How it Works")
                .font(.system(size: 24, weight: .black))
                .foregroundColor(AppTheme.text900)

            Text("Get your campaign running in minutes with our streamlined collaboration process.")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(AppTheme.text600)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            VStack(spacing: 16) {
                HowItWorksCard(icon: "location.magnifyingglass", title: "Discover", description: "Search for local creators or brands based on your location and niche needs.")
                HowItWorksCard(icon: "message.fill", title: "Connect", description: "Reach out through our secure platform to discuss project details and goals.")
                HowItWorksCard(icon: "handshake.fill", title: "Collaborate", description: "Execute your vision and manage payments safely within CreatorBridge.")
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 28)
        .background(colorScheme == .dark ? AppTheme.backgroundDark : AppTheme.backgroundLight)
    }

    // MARK: - Top Categories

    private var topCategoriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Top Categories")
                        .font(.system(size: 22, weight: .black))
                        .foregroundColor(AppTheme.text900)
                    Text("Explore the most active niches in our marketplace.")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(AppTheme.text600)
                }

                Spacer()

                Button(action: {}) {
                    HStack(spacing: 6) {
                        Text("View all categories")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppTheme.primary)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppTheme.primary)
                    }
                }
            }
            .padding(.horizontal, 20)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                CategoryCard(
                    title: "Real Estate",
                    description: "Professional tours and architectural highlights.",
                    imageURL: "https://lh3.googleusercontent.com/aida-public/AB6AXuDDlCsUr2i5zY5NmuoMdPwdNOwtKYeQtpuvngBzVFhSO2Qntg2K0U0mQUZ6QwSww4W-XhQ-HVAJLnM9A50WW88taabevia-2uulGBiKdvq1XsA5SURfTjoXUC17taUolj6SZrX1VCK0QcL9cUfWEVdMn4ejyCLlLGFC8ilxSTBKzRRqqOL7HdWptuTTCzqoYlIE7N8ghz0hteeVUV12lANy5vOoNq-wmezkWuCiiRuOjmK9OeMiA5313YO24Ji-sQ0DsRzCennClZg"
                )
                CategoryCard(
                    title: "Tech",
                    description: "App reviews, gadget unboxings, tutorials.",
                    imageURL: "https://lh3.googleusercontent.com/aida-public/AB6AXuCJujf2om3zIDYJzA-zCBXdK7fFkM_0FtvxyKXdnAmG18WgvL3nWSN8XGk2AxIepSSeI0iRZrgXEkxiTwBCs1Pqhg3bPJanIRqStdSsM-beKOUDigRHd0OiRHAn1pgkPfh2ZrK1E_THDmXqKLYQJVmLacKxgW5kg4sTSvuElhKXGzaPgNJqagW6YP8IK-PZbvPUbR_kzY0GhLC4clmaqCjULiwmLR2x1V35FAfV2bAlXQAMLAMfZr306xmiowZ4k-xd8AfbygGgz2c"
                )
                CategoryCard(
                    title: "Lifestyle",
                    description: "Daily vlogs, fashion hauls, wellness journeys.",
                    imageURL: "https://lh3.googleusercontent.com/aida-public/AB6AXuBQmKrFSvs430z6ULUmgWidaoYsAyj_Py_mfrLLQYyyz1kX7dCIwCzh96ZWSBUdBzWK1iY7CR5G9uB-3JNEf2qktLlUrdzxQjsESpmQJV5yQq2UU1Bpr5zKC49Aeufyq9Y_lDlimoxzcpZcQ1wcaXZll2DYCbTPBPCADaHogi2YjMWQdJispclN7bek6pR5q741go-UvaPCrKy_w2zBUBlbb4MdeC6iF9Qn_IA-q6_pdukUFDjH2Z5MmvqlltYKZX6BnWmsylxtG_Y"
                )
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 24)
        .background(Color.white)
    }

    // MARK: - CTA

    private var ctaSection: some View {
        VStack(spacing: 16) {
            Text("Ready to start your next big collaboration?")
                .font(.system(size: 24, weight: .black))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text("Join thousands of creators and brands building authentic connections across the globe.")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            HStack(spacing: 12) {
                Button(action: {}) {
                    Text("Get Started for Free")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppTheme.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .cornerRadius(12)
                }

                Button(action: {}) {
                    Text("Contact Sales")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AppTheme.primary.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 28)
        .background(AppTheme.primary)
    }

    private var footerSection: some View {
        VStack(spacing: 12) {
            Text("(c) 2024 CreatorBridge. All rights reserved.")
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(AppTheme.text600)

            HStack(spacing: 16) {
                NavigationLink(destination: PrivacyPolicyView()) {
                    Text("Privacy")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AppTheme.text600)
                }

                NavigationLink(destination: TermsOfServiceView()) {
                    Text("Terms")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AppTheme.text600)
                }
            }
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(AppTheme.slate100)
    }
}

// MARK: - Components

struct DiscoveryFeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.primary.opacity(0.1))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .foregroundColor(AppTheme.primary)
                    .font(.system(size: 18, weight: .semibold))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppTheme.text900)
                Text(description)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(AppTheme.text600)
            }

            Spacer()
        }
    }
}

struct HowItWorksCard: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 64, height: 64)
                    .overlay(Circle().stroke(AppTheme.primary.opacity(0.2), lineWidth: 3))

                Image(systemName: icon)
                    .foregroundColor(AppTheme.primary)
                    .font(.system(size: 22, weight: .bold))
            }

            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(AppTheme.text900)

            Text(description)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(AppTheme.text600)
                .multilineTextAlignment(.center)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(colorScheme == .dark ? AppTheme.slate900 : Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppTheme.slate200, lineWidth: 1)
        )
    }

    @Environment(\.colorScheme) private var colorScheme
}

struct CategoryCard: View {
    let title: String
    let description: String
    let imageURL: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: URL(string: imageURL)) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                AppTheme.slate300
            }
            .frame(height: 200)
            .clipped()

            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0.8), Color.clear]),
                startPoint: .bottom,
                endPoint: .top
            )
            .frame(height: 200)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                Text(description)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.8))
            }
            .padding(12)
        }
        .cornerRadius(16)
    }
}

// MARK: - Placeholder Views

struct CreatorSignupView: View {
    var body: some View {
        VStack {
            Text("Creator Signup")
                .font(.system(size: 24, weight: .bold))
            Spacer()
        }
        .padding()
        .navigationTitle("Become a Creator")
    }
}

struct BrandSignupView: View {
    var body: some View {
        VStack {
            Text("Brand Signup")
                .font(.system(size: 24, weight: .bold))
            Spacer()
        }
        .padding()
        .navigationTitle("Register Your Brand")
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy Policy")
                    .font(.system(size: 24, weight: .bold))

                Text("Your privacy is important to us...")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(AppTheme.text600)

                Spacer()
            }
            .padding(16)
        }
        .navigationTitle("Privacy Policy")
    }
}

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Terms of Service")
                    .font(.system(size: 24, weight: .bold))

                Text("By using our service, you agree to...")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(AppTheme.text600)

                Spacer()
            }
            .padding(16)
        }
        .navigationTitle("Terms of Service")
    }
}

#Preview {
    LandingPageView()
}
