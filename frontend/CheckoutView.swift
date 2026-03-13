import SwiftUI

// MARK: - Checkout View
struct CheckoutView: View {
    @State private var cardholderName = ""
    @State private var cardNumber = ""
    @State private var expiryDate = ""
    @State private var cvc = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            AppTheme.backgroundLight.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        selectedPlan
                        paymentDetails
                        summarySection
                        securityBadges
                    }
                    .padding(16)
                    .padding(.bottom, 90)
                }

                paymentFooter
            }
        }
        .navigationBarHidden(true)
    }

    private var header: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.text600)
                    .padding(6)
                    .background(AppTheme.slate100)
                    .clipShape(Circle())
            }

            Text("Checkout")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(AppTheme.text900)
                .padding(.leading, 8)

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 10, weight: .bold))
                Text("SECURE")
                    .font(.system(size: 10, weight: .bold))
            }
            .foregroundColor(AppTheme.primary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(AppTheme.primary.opacity(0.1))
            .cornerRadius(10)
        }
        .padding(16)
        .background(Color.white.opacity(0.9))
        .backdrop()
    }

    private var selectedPlan: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Selected Plan")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(AppTheme.text900)

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Subscription")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(AppTheme.primary)

                    Text("Premium Plan")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppTheme.text900)

                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Text("$49")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppTheme.text900)
                        Text("/month")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(AppTheme.text500)
                    }
                }

                Spacer()

                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [AppTheme.primary, AppTheme.primary.opacity(0.7)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 72, height: 72)
            }
            .padding(12)
            .background(AppTheme.slate50)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.slate200, lineWidth: 1))
        }
    }

    private var paymentDetails: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Payment Details")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(AppTheme.text900)

            VStack(alignment: .leading, spacing: 6) {
                Text("Cardholder Name")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.text700)
                TextField("John Doe", text: $cardholderName)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppTheme.slate200, lineWidth: 1))
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Card Number")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.text700)
                HStack {
                    TextField("0000 0000 0000 0000", text: $cardNumber)
                        .font(.system(size: 14, weight: .regular, design: .monospaced))
                    Image(systemName: "creditcard")
                        .foregroundColor(AppTheme.text400)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.white)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppTheme.slate200, lineWidth: 1))
            }

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Expiry Date")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppTheme.text700)
                    TextField("MM / YY", text: $expiryDate)
                        .font(.system(size: 14, weight: .regular, design: .monospaced))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppTheme.slate200, lineWidth: 1))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("CVC")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppTheme.text700)
                    TextField("123", text: $cvc)
                        .font(.system(size: 14, weight: .regular, design: .monospaced))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppTheme.slate200, lineWidth: 1))
                }
            }
        }
    }

    private var summarySection: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Subtotal")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(AppTheme.text600)
                Spacer()
                Text("$49.00")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(AppTheme.text600)
            }

            HStack {
                Text("Tax")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(AppTheme.text600)
                Spacer()
                Text("$0.00")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(AppTheme.text600)
            }

            Divider()

            HStack {
                Text("Total Due")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppTheme.text900)
                Spacer()
                Text("$49.00")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.primary)
            }

            Button(action: {}) {
                Text("Start Subscription")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppTheme.primary)
                    .cornerRadius(14)
                    .shadow(color: AppTheme.primary.opacity(0.2), radius: 8, x: 0, y: 4)
            }

            Text("By clicking \"Start Subscription\", you agree to our Terms of Service and Privacy Policy. You can cancel at any time.")
                .font(.system(size: 10, weight: .regular))
                .foregroundColor(AppTheme.text500)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10)
        }
        .padding(.top, 6)
    }

    private var securityBadges: some View {
        HStack(spacing: 10) {
            SecurityBadge(icon: "checkmark.shield", text: "PCI DSS")
            SecurityBadge(icon: "lock.shield", text: "256-bit SSL")
            SecurityBadge(icon: "shield", text: "Safe")
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    private var paymentFooter: some View {
        HStack(spacing: 8) {
            PaymentLogo(text: "VISA")
            PaymentLogo(text: "MC")
            PaymentLogo(text: "AMEX")
            PaymentLogo(text: "APPLE")
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(AppTheme.slate50)
        .overlay(Divider(), alignment: .top)
    }
}

struct SecurityBadge: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .bold))
            Text(text)
                .font(.system(size: 9, weight: .bold))
        }
        .foregroundColor(AppTheme.text500)
    }
}

struct PaymentLogo: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 9, weight: .bold))
            .foregroundColor(AppTheme.text500)
            .frame(width: 40, height: 20)
            .background(AppTheme.slate200)
            .cornerRadius(4)
    }
}

#Preview {
    CheckoutView()
}
