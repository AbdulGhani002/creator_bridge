"""
Frontend/
├── App/
│   ├── CreatorBridgeApp.swift           # Main app entry
│   ├── AppDelegate.swift                # App lifecycle
│   └── AppState.swift                   # Global app state
│
├── Models/                              # Data models
│   ├── CampaignModels.swift
│   ├── CreatorModels.swift
│   ├── BrandModels.swift
│   ├── UserModels.swift
│   └── MessageModels.swift
│
├── Services/                            # Business logic
│   ├── APIService/
│   │   ├── APIService.swift             # HTTP client
│   │   ├── AuthService.swift            # Authentication
│   │   ├── CampaignService.swift        # Campaign API
│   │   ├── CreatorService.swift         # Creator API
│   │   ├── UserService.swift            # User API
│   │   └── MessageService.swift         # Messaging API
│   │
│   ├── LocalServices/
│   │   ├── KeychainService.swift        # Secure storage
│   │   ├── UserDefaultsService.swift    # Local storage
│   │   └── CacheService.swift           # In-memory cache
│   │
│   └── Analytics/
│       ├── AnalyticsService.swift       # Event tracking
│       └── CrashReporter.swift          # Error reporting
│
├── ViewModels/                          # MVVM state
│   ├── Auth/
│   │   ├── SignUpViewModel.swift
│   │   ├── LoginViewModel.swift
│   │   └── OnboardingViewModel.swift
│   │
│   ├── Creator/
│   │   ├── CreatorDashboardViewModel.swift
│   │   ├── CreatorProfileViewModel.swift
│   │   └── CreatorSearchViewModel.swift
│   │
│   ├── Brand/
│   │   ├── BrandDashboardViewModel.swift
│   │   ├── CampaignManagementViewModel.swift
│   │   └── CreatorSearchViewModel.swift
│   │
│   ├── Messages/
│   │   └── MessagesViewModel.swift
│   │
│   └── Shared/
│       ├── TabBarViewModel.swift
│       └── SettingsViewModel.swift
│
├── Views/                               # SwiftUI components
│   ├── Components/                      # Reusable components
│   │   ├── Buttons/
│   │   │   ├── PrimaryButton.swift
│   │   │   ├── SecondaryButton.swift
│   │   │   └── IconButton.swift
│   │   │
│   │   ├── Cards/
│   │   │   ├── CampaignCard.swift
│   │   │   ├── CreatorCard.swift
│   │   │   └── StatCard.swift
│   │   │
│   │   ├── Input/
│   │   │   ├── TextInputField.swift
│   │   │   ├── EmailInput.swift
│   │   │   ├── PickerField.swift
│   │   │   └── SearchBar.swift
│   │   │
│   │   ├── Navigation/
│   │   │   ├── TopAppBar.swift
│   │   │   ├── TabBar.swift
│   │   │   └── BottomSheet.swift
│   │   │
│   │   └── Common/
│   │       ├── EmptyState.swift
│   │       ├── LoadingView.swift
│   │       ├── ErrorView.swift
│   │       └── Badge.swift
│   │
│   ├── Screens/                         # Full page screens
│   │   ├── Auth/
│   │   │   ├── LandingPageView.swift
│   │   │   ├── LoginView.swift
│   │   │   ├── SignUpView.swift
│   │   │   ├── OnboardingView.swift
│   │   │   └── ForgotPasswordView.swift
│   │   │
│   │   ├── Creator/
│   │   │   ├── CreatorDashboardView.swift
│   │   │   ├── CreatorProfileView.swift
│   │   │   ├── CampaignListView.swift
│   │   │   ├── CampaignDetailView.swift
│   │   │   ├── ApplicationsView.swift
│   │   │   └── EarningsView.swift
│   │   │
│   │   ├── Brand/
│   │   │   ├── BrandDashboardView.swift
│   │   │   ├── BrandProfileView.swift
│   │   │   ├── CreateCampaignView.swift
│   │   │   ├── CampaignManagementView.swift
│   │   │   ├── CreatorSearchView.swift
│   │   │   └── CreatorDetailView.swift
│   │   │
│   │   ├── Messages/
│   │   │   ├── MessagesListView.swift
│   │   │   └── ChatDetailView.swift
│   │   │
│   │   ├── Settings/
│   │   │   ├── SettingsView.swift
│   │   │   ├── ProfileSettingsView.swift
│   │   │   ├── NotificationSettingsView.swift
│   │   │   ├── PrivacyView.swift
│   │   │   ├── TermsView.swift
│   │   │   ├── HelpView.swift
│   │   │   └── AboutView.swift
│   │   │
│   │   └── Subscription/
│   │       ├── SubscriptionPlansView.swift
│   │       ├── CheckoutView.swift
│   │       └── ReceiptView.swift
│   │
│   └── Layouts/
│       ├── MainAppLayout.swift          # Authenticated layout
│       ├── AuthLayout.swift             # Guest layout
│       └── TabBarLayout.swift           # Bottom tab navigation
│
├── Extensions/                          # Swift extensions
│   ├── Color+Theme.swift                # Theme colors
│   ├── Font+Custom.swift                # Custom fonts
│   ├── View+Helpers.swift               # View utilities
│   └── Image+Assets.swift               # Image assets
│
├── Constants/                           # App constants
│   ├── AppConstants.swift
│   ├── URLConstants.swift
│   ├── AppColors.swift
│   └── AppFonts.swift
│
└── Resources/                           # Assets
    ├── Fonts/
    ├── Images/
    └── Localizable.strings
"""

print("Frontend modular structure ready")
