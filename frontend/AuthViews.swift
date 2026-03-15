import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var session: SessionManager
    @State private var isLogin = true
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var role: UserRole = .creator
    @State private var location = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("CreatorBridge")
                    .font(.largeTitle.bold())

                Picker("Mode", selection: $isLogin) {
                    Text("Login").tag(true)
                    Text("Sign Up").tag(false)
                }
                .pickerStyle(.segmented)

                if !isLogin {
                    TextField("Name", text: $name)
                        .textFieldStyle(.roundedBorder)
                    Picker("Role", selection: $role) {
                        Text("Creator").tag(UserRole.creator)
                        Text("Brand").tag(UserRole.brand)
                    }
                    .pickerStyle(.segmented)
                    TextField("Location", text: $location)
                        .textFieldStyle(.roundedBorder)
                }

                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)

                if let error = session.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.footnote)
                }

                Button(isLogin ? "Login" : "Create Account") {
                    submit()
                }
                .buttonStyle(.borderedProminent)
                .disabled(session.isLoading)

                HStack(spacing: 12) {
                    Button("Demo Creator") {
                        Task { await session.demoLogin(role: "creator") }
                    }
                    Button("Demo Brand") {
                        Task { await session.demoLogin(role: "brand") }
                    }
                }
                .font(.footnote)

                Spacer()
            }
            .padding()
            .navigationTitle(isLogin ? "Login" : "Sign Up")
        }
    }

    private func submit() {
        if isLogin {
            Task { await session.login(email: email, password: password) }
        } else {
            let request = SignupRequest(
                name: name,
                email: email,
                password: password,
                role: role.rawValue,
                location: location,
                creatorProfile: nil,
                brandProfile: nil
            )
            Task { await session.signup(request) }
        }
    }
}

