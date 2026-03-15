import SwiftUI

struct CreatorProfileSetupView: View {
    @EnvironmentObject private var session: SessionManager
    @ObservedObject var profileStore: ProfileStore

    @State private var name = ""
    @State private var bio = ""
    @State private var niche: NicheType? = nil
    @State private var location = ""
    @State private var followersCount: String = ""
    @State private var pricingPerPost: String = ""
    @State private var portfolioUrl: String = ""
    @State private var selectedPlatforms: Set<PlatformType> = []
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Basics") {
                    TextField("Name", text: $name)
                    TextField("Location", text: $location)
                    TextField("Bio", text: $bio)
                }

                Section("Niche") {
                    Picker("Niche", selection: $niche) {
                        Text("Select").tag(nil as NicheType?)
                        ForEach(NicheType.allCases, id: \.self) { item in
                            Text(item.displayName).tag(item as NicheType?)
                        }
                    }
                }

                Section("Platforms") {
                    ForEach(PlatformType.allCases, id: \.self) { platform in
                        Toggle(platform.displayName, isOn: Binding(
                            get: { selectedPlatforms.contains(platform) },
                            set: { value in
                                if value { selectedPlatforms.insert(platform) } else { selectedPlatforms.remove(platform) }
                            }
                        ))
                    }
                }

                Section("Metrics") {
                    TextField("Followers Count", text: $followersCount)
                        .keyboardType(.numberPad)
                    TextField("Pricing Per Post", text: $pricingPerPost)
                        .keyboardType(.decimalPad)
                }

                Section("Portfolio") {
                    TextField("Portfolio URL", text: $portfolioUrl)
                }

                if let errorMessage = errorMessage {
                    Text(errorMessage).foregroundColor(.red)
                }
            }
            .navigationTitle("Creator Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { save() }
                }
            }
        }
    }

    private func save() {
        Task {
            do {
                let followers = Int(followersCount)
                let pricing = Double(pricingPerPost)
                let request = CreatorProfileCreateRequest(
                    name: name.isEmpty ? (session.user?.name ?? "Creator") : name,
                    bio: bio,
                    niche: niche,
                    location: location,
                    followersCount: followers,
                    socialLinks: nil,
                    portfolioUrl: portfolioUrl.isEmpty ? nil : portfolioUrl,
                    pricingPerPost: pricing,
                    platforms: selectedPlatforms.map { $0.rawValue }
                )
                _ = try await session.apiService.createCreatorProfile(request)
                await profileStore.loadProfile(session: session)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

struct BrandProfileSetupView: View {
    @EnvironmentObject private var session: SessionManager
    @ObservedObject var profileStore: ProfileStore

    @State private var companyName = ""
    @State private var industry = ""
    @State private var website = ""
    @State private var description = ""
    @State private var location = ""
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Company") {
                    TextField("Company Name", text: $companyName)
                    TextField("Industry", text: $industry)
                    TextField("Website", text: $website)
                    TextField("Location", text: $location)
                }
                Section("Description") {
                    TextEditor(text: $description)
                        .frame(minHeight: 120)
                }
                if let errorMessage = errorMessage {
                    Text(errorMessage).foregroundColor(.red)
                }
            }
            .navigationTitle("Brand Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { save() }
                }
            }
        }
    }

    private func save() {
        Task {
            do {
                let request = BrandProfileCreateRequest(
                    companyName: companyName,
                    industry: industry.isEmpty ? nil : industry,
                    companyWebsite: website.isEmpty ? nil : website,
                    companyDescription: description,
                    location: location.isEmpty ? nil : location
                )
                _ = try await session.apiService.createBrandProfile(request)
                await profileStore.loadProfile(session: session)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

