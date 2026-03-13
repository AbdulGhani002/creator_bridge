import SwiftUI

// MARK: - Messages Chat View
struct MessagesChatView: View {
    @State private var messageText = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            AppTheme.backgroundLight.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        dateSeparator
                        receivedMessage
                        sentMessage
                        sentFileMessage
                        typingIndicator
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 12)
                }

                inputArea
                draftChips
            }
        }
        .navigationBarHidden(true)
    }

    private var header: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.text600)
                }

                HStack(spacing: 10) {
                    ZStack(alignment: .bottomTrailing) {
                        AsyncImage(url: URL(string: "https://lh3.googleusercontent.com/aida-public/AB6AXuBkL-CNNLCbenpUU-S_eW44_PedsxjG96c1ZXx1bBciFYsYBrJuk2K0B40XjIPUvYWcGdVOZiTMRKM2pQE-_fhcxXnNZl_BLW3SIk4wiFXfelw5sTSdG88ymorJEpNNYVAZFi29nM5mNkmO1Su0HvNJn0Go4AoCeZYnIE103-DBBmy21eOmEYlS_j3SBMw6MRrlWMmijXDQcafqrVmR3XgO7hCEtBKb7lEgVTy0B3faeqfIxosY54r5FlWvNxmPaCy2NMKo_9yfKT0")) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            AppTheme.slate200
                        }
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())

                        Circle()
                            .fill(AppTheme.successGreen)
                            .frame(width: 8, height: 8)
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Sarah from Zenith")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.text900)

                        Text("Brand Manager - Active now")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(AppTheme.text500)
                    }
                }

                Spacer()

                HStack(spacing: 6) {
                    Button(action: {}) {
                        Image(systemName: "video")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(AppTheme.text600)
                            .padding(6)
                            .background(AppTheme.slate100)
                            .clipShape(Circle())
                    }

                    Button(action: {}) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(AppTheme.text600)
                            .padding(6)
                            .background(AppTheme.slate100)
                            .clipShape(Circle())
                    }
                }
            }
            .padding(16)

            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "megaphone")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppTheme.primary)
                    Text("Zenith Summer Campaign 2024")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AppTheme.primary)
                }

                Spacer()

                Text("In Progress")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(AppTheme.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(AppTheme.primary.opacity(0.2))
                    .cornerRadius(10)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(AppTheme.primary.opacity(0.05))
        }
        .background(Color.white.opacity(0.9))
        .backdrop()
    }

    private var dateSeparator: some View {
        HStack {
            Text("Today")
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(AppTheme.text400)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(AppTheme.slate100)
                .cornerRadius(10)
        }
    }

    private var receivedMessage: some View {
        HStack(alignment: .bottom, spacing: 10) {
            AsyncImage(url: URL(string: "https://lh3.googleusercontent.com/aida-public/AB6AXuAiRynWfuY-ybgDTohrFXgmuNkZt2UFM_TaJIDpx6o7tmVZaiakWeXv1uEQsm7uek9_R7Ay_qTLH0NaCRR_4oH0YMrFqy-ech0IsrLLMv0WPF8Zj2BJS8PEDSrpnpsEXZyJaVHWXmVs_SfvxXLpnf81bTusmy25yl5UEkei_pSIbSq4ciFqqlFUK9yUtQWNgOimdW5jkfvUevc2EWKV-3JpwcA-_2VidRtBvZ4jLoZc88iEdPF4TjnmA8ytc0fD2Gi509e0rHowtYw")) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                AppTheme.slate200
            }
            .frame(width: 28, height: 28)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text("Hi there! We loved your recent content about sustainable travel. We are kicking off our Zenith Summer Campaign and would love to have you on board as a primary creator. Are you available for a July partnership?")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(AppTheme.text900)
                    .padding(12)
                    .background(AppTheme.slate100)
                    .cornerRadius(16)
                    .cornerRadius(4, corners: [.bottomLeft])

                Text("10:24 AM")
                    .font(.system(size: 9, weight: .regular))
                    .foregroundColor(AppTheme.text400)
            }

            Spacer()
        }
    }

    private var sentMessage: some View {
        HStack(alignment: .bottom, spacing: 10) {
            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("I would love to! Zenith has been on my radar for a while. I have already put together a quick moodboard and a first draft of the concept we could explore. Let me know what you think!")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.white)
                    .padding(12)
                    .background(AppTheme.primary)
                    .cornerRadius(16)
                    .cornerRadius(4, corners: [.bottomRight])

                HStack(spacing: 4) {
                    Text("10:45 AM - Read")
                        .font(.system(size: 9, weight: .regular))
                        .foregroundColor(AppTheme.text400)
                }
            }

            ZStack {
                Circle()
                    .fill(AppTheme.primary.opacity(0.2))
                    .frame(width: 28, height: 28)
                Text("YO")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(AppTheme.primary)
            }
        }
    }

    private var sentFileMessage: some View {
        HStack(alignment: .bottom, spacing: 10) {
            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 10) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white)
                                .frame(width: 32, height: 32)
                            Image(systemName: "film")
                                .foregroundColor(AppTheme.primary)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Zenith_Concept_Draft_v1.mp4")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                                .lineLimit(1)
                            Text("24.8 MB - Video")
                                .font(.system(size: 10, weight: .regular))
                                .foregroundColor(.white.opacity(0.7))
                        }

                        Spacer()

                        Image(systemName: "arrow.down.circle")
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(10)
                    .background(Color.white.opacity(0.12))
                    .cornerRadius(10)

                    Text("Here is the initial video concept. Focused on the Unfiltered Summer theme we discussed.")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white)
                }
                .padding(12)
                .background(AppTheme.primary)
                .cornerRadius(16)
                .cornerRadius(4, corners: [.bottomRight])

                Text("10:46 AM")
                    .font(.system(size: 9, weight: .regular))
                    .foregroundColor(AppTheme.text400)
            }
        }
    }

    private var typingIndicator: some View {
        HStack {
            Spacer()
            Text("Sarah is typing...")
                .font(.system(size: 10, weight: .regular))
                .foregroundColor(AppTheme.text400)
            Spacer()
        }
    }

    private var inputArea: some View {
        HStack(spacing: 8) {
            Button(action: {}) {
                Image(systemName: "plus.circle")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(AppTheme.text500)
            }

            Button(action: {}) {
                Image(systemName: "photo")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(AppTheme.text500)
            }

            ZStack(alignment: .trailing) {
                TextField("Type a message...", text: $messageText)
                    .font(.system(size: 13, weight: .regular))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(AppTheme.slate100)
                    .cornerRadius(20)

                Image(systemName: "face.smiling")
                    .foregroundColor(AppTheme.text400)
                    .padding(.trailing, 12)
            }

            Button(action: {}) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 38, height: 38)
                    .background(AppTheme.primary)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.white)
        .overlay(Divider(), alignment: .top)
    }

    private var draftChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                HStack(spacing: 6) {
                    Image(systemName: "paperclip")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(AppTheme.text500)
                    Text("Campaign_Brief.pdf")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(AppTheme.text600)
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(AppTheme.text400)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(AppTheme.slate100)
                .cornerRadius(14)

                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(AppTheme.text500)
                    Text("Set reminder")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(AppTheme.text600)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(AppTheme.slate100)
                .cornerRadius(14)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .background(Color.white)
    }
}

// MARK: - Corner Radius Modifier
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                               byRoundingCorners: corners,
                               cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// MARK: - Backdrop Modifier
extension View {
    func backdrop() -> some View {
        self.background(Material.ultraThin)
    }
}

#Preview {
    MessagesChatView()
}
