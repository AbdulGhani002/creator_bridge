import SwiftUI

// MARK: - Primary Button

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading = false
    var isDisabled = false
    var icon: String?
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(AppTheme.primary)
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(color: AppTheme.primary.opacity(0.3), radius: 8, y: 4)
        }
        .disabled(isLoading || isDisabled)
        .opacity(isDisabled ? 0.5 : 1.0)
    }
}

// MARK: - Secondary Button

struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading = false
    var icon: String?
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                
                if isLoading {
                    ProgressView()
                        .tint(AppTheme.primary)
                } else {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.white)
            .foregroundColor(AppTheme.primary)
            .border(AppTheme.primary, width: 2)
            .cornerRadius(12)
        }
        .disabled(isLoading)
    }
}

// MARK: - Icon Button

struct IconButton: View {
    let icon: String
    let action: () -> Void
    var size: CGFloat = 40
    var backgroundColor: Color = AppTheme.slate100
    var foregroundColor: Color = AppTheme.slate600
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(foregroundColor)
                .frame(width: size, height: size)
                .background(backgroundColor)
                .cornerRadius(size / 2)
        }
    }
}

// MARK: - Text Input Field

struct TextInputField: View {
    let label: String
    @Binding var text: String
    var placeholder: String = ""
    var isSecure = false
    var icon: String?
    var keyboardType: UIKeyboardType = .default
    var errorMessage: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.slate900)
            
            HStack(spacing: 12) {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(AppTheme.slate600)
                }
                
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                }
            }
            .padding(12)
            .background(Color.white)
            .border(
                errorMessage != nil ? AppTheme.errorRed : AppTheme.slate300,
                width: 1
            )
            .cornerRadius(8)
            
            if let error = errorMessage {
                Text(error)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.errorRed)
            }
        }
    }
}

// MARK: - Email Input Field

struct EmailInputField: View {
    let label: String = "Email"
    @Binding var email: String
    var errorMessage: String?
    
    var body: some View {
        TextInputField(
            label: label,
            text: $email,
            placeholder: "name@example.com",
            icon: "envelope",
            keyboardType: .emailAddress,
            errorMessage: errorMessage
        )
    }
}

// MARK: - Search Bar

struct SearchBar: View {
    @Binding var searchText: String
    var placeholder: String = "Search..."
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppTheme.slate600)
            
            TextField(placeholder, text: $searchText)
                .textContentType(.none)
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppTheme.slate400)
                }
            }
        }
        .padding(12)
        .background(AppTheme.slate100)
        .cornerRadius(8)
    }
}

// MARK: - Badge

struct Badge: View {
    let text: String
    var backgroundColor: Color = AppTheme.primaryLight
    var foregroundColor: Color = AppTheme.primary
    var icon: String?
    
    var body: some View {
        HStack(spacing: 6) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
            }
            Text(text)
                .font(.system(size: 12, weight: .semibold))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(backgroundColor)
        .foregroundColor(foregroundColor)
        .cornerRadius(6)
    }
}

// MARK: - Loading View

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
                .tint(AppTheme.primary)
                .scaleEffect(1.5)
            Text("Loading...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppTheme.slate600)
                .padding(.top, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.slate100.opacity(0.5))
    }
}

// MARK: - Empty State View

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48, weight: .light))
                .foregroundColor(AppTheme.slate400)
            
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppTheme.slate900)
            
            Text(message)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(AppTheme.slate600)
                .multilineTextAlignment(.center)
            
            if let actionTitle = actionTitle, let action = action {
                PrimaryButton(title: actionTitle, action: action)
                    .padding(.top, 16)
            }
        }
        .padding(32)
        .multilineTextAlignment(.center)
    }
}

// MARK: - Error View

struct ErrorView: View {
    let message: String
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(AppTheme.errorRed)
            
            Text("Error")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppTheme.slate900)
            
            Text(message)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(AppTheme.slate600)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 12) {
                SecondaryButton(title: "Dismiss") {}
                PrimaryButton(title: "Retry", action: action)
            }
            .padding(.top, 16)
        }
        .padding(32)
        .background(AppTheme.errorRedLight)
        .cornerRadius(16)
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let change: String?
    let changeType: ChangeType
    
    enum ChangeType {
        case positive, stable, negative
        
        var color: Color {
            switch self {
            case .positive: return AppTheme.successGreen
            case .stable: return AppTheme.slate600
            case .negative: return AppTheme.errorRed
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(AppTheme.primary)
                
                Spacer()
                
                if let change = change {
                    Text(change)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(changeType.color)
                }
            }
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppTheme.slate600)
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppTheme.slate900)
        }
        .padding(16)
        .background(Color.white)
        .border(AppTheme.slate300, width: 1)
        .cornerRadius(12)
    }
}

#Preview {
    VStack(spacing: 20) {
        PrimaryButton(title: "Primary") {}
        SecondaryButton(title: "Secondary") {}
        TextInputField(label: "Email", text: .constant(""))
        SearchBar(searchText: .constant(""))
        Badge(text: "Pro Plan")
        StatCard(icon: "eye", title: "Views", value: "1.2K", change: "+15%", changeType: .positive)
    }
    .padding(20)
    .background(AppTheme.slate100)
}
