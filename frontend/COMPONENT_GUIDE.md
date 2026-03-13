# Frontend Component & Theme Integration Guide

## Overview

This guide explains how to use the new modular Theme system and Component Library in your SwiftUI views.

## Theme System

### AppTheme Structure

All colors, spacing, and styling constants are defined in `Theme.swift`:

```swift
struct AppTheme {
    // MARK: - Colors
    
    // Primary Brand Color
    static let primary = Color(red: 0.314, green: 0.282, blue: 0.902)  // #5048e5
    static let primaryLight = Color(red: 0.314, green: 0.282, blue: 0.902).opacity(0.1)
    static let primaryDark = Color(red: 0.239, green: 0.219, blue: 0.647)
    
    // Backgrounds
    static let backgroundLight = Color(red: 0.976, green: 0.976, blue: 0.972)  // #f6f6f8
    static let backgroundDark = Color(red: 0.071, green: 0.071, blue: 0.129)   // #121121
    
    // Semantic Colors
    static let successGreen = Color(red: 0.043, green: 0.667, blue: 0.416)      // #0baa6a
    static let warningOrange = Color(red: 1.0, green: 0.583, blue: 0.0)         // #ff9500
    static let errorRed = Color(red: 1.0, green: 0.231, blue: 0.188)            // #ff3b30
    static let infoBlue = Color(red: 0.0, green: 0.475, blue: 1.0)              // #0079ff
    
    // Neutral Slate Palette
    static let slate50 = Color(red: 0.988, green: 0.988, blue: 0.992)
    static let slate100 = Color(red: 0.976, green: 0.976, blue: 0.984)
    // ... slate 200-900
    
    // MARK: - Spacing
    static let spacing1: CGFloat = 4
    static let spacing2: CGFloat = 8
    static let spacing3: CGFloat = 16
    static let spacing4: CGFloat = 24
    static let spacing5: CGFloat = 32
    static let spacing6: CGFloat = 48
    
    // MARK: - Border Radius
    static let radiusSmall: CGFloat = 8
    static let radiusMedium: CGFloat = 12
    static let radiusLarge: CGFloat = 16
    static let radiusFull: CGFloat = .infinity
}
```

### Using Theme Colors

```swift
struct MyView: View {
    var body: some View {
        VStack {
            // Use theme colors
            Text("Primary Text")
                .foregroundColor(AppTheme.primary)
            
            Text("Secondary Text")
                .foregroundColor(AppTheme.slate600)
            
            // With modifiers
            Text("Success")
                .foregroundColor(AppTheme.successGreen)
                .padding(AppTheme.spacing3)
                .background(AppTheme.successGreen.opacity(0.1))
                .cornerRadius(AppTheme.radiusSmall)
        }
        .padding(AppTheme.spacing4)
        .background(AppTheme.backgroundLight)
    }
}
```

### Dark Mode Support

All theme colors automatically adapt to light/dark mode:

```swift
@Environment(\.colorScheme) var colorScheme

var body: some View {
    VStack {
        if colorScheme == .dark {
            // Use dark mode colors
            Text("Dark").foregroundColor(AppTheme.backgroundLight)
        } else {
            // Use light mode colors
            Text("Light").foregroundColor(AppTheme.slate900)
        }
    }
}
```

## Component Library

### Available Components

#### 1. Buttons

**PrimaryButton** - Main action button
```swift
PrimaryButton(
    title: "Submit",
    action: { print("Clicked") }
)

// With icon
PrimaryButton(
    title: "Upload",
    action: { },
    icon: "cloud.upload"
)

// With loading state
@State var isLoading = false
PrimaryButton(
    title: "Save",
    action: { },
    isLoading: isLoading
)

// Disabled state
PrimaryButton(
    title: "Disabled",
    action: { },
    isDisabled: true
)
```

**SecondaryButton** - Secondary action
```swift
SecondaryButton(
    title: "Cancel",
    action: { }
)
```

**IconButton** - Compact icon button
```swift
IconButton(
    icon: "heart",
    action: { print("Liked") }
)

// Customized
IconButton(
    icon: "bell",
    action: { },
    size: 48,
    backgroundColor: AppTheme.primary,
    foregroundColor: .white
)
```

#### 2. Input Fields

**TextInputField** - Standard text input
```swift
@State var email = ""

TextInputField(
    label: "Email",
    text: $email,
    placeholder: "name@example.com",
    icon: "envelope"
)
```

**EmailInputField** - Pre-configured email field
```swift
@State var email = ""

EmailInputField(
    email: $email,
    errorMessage: validationError
)
```

**SearchBar** - Search with clear button
```swift
@State var searchText = ""

SearchBar(
    searchText: $searchText,
    placeholder: "Search creators..."
)
```

#### 3. Cards

**StatCard** - Statistics display
```swift
StatCard(
    icon: "eye",
    title: "Profile Views",
    value: "12.5K",
    change: "+15%",
    changeType: .positive
)

// Different change types
StatCard(..., changeType: .positive)    // Green
StatCard(..., changeType: .stable)      // Gray
StatCard(..., changeType: .negative)    // Red
```

#### 4. Feedback Components

**Badge** - Small label
```swift
Badge(
    text: "Pro Plan",
    backgroundColor: AppTheme.primaryLight,
    foregroundColor: AppTheme.primary
)

// With icon
Badge(
    text: "Verified",
    icon: "checkmark.circle.fill"
)
```

**LoadingView** - Loading indicator
```swift
if isLoading {
    LoadingView()
} else {
    ContentView()
}
```

**EmptyStateView** - Empty state
```swift
EmptyStateView(
    icon: "briefcase",
    title: "No Campaigns",
    message: "Check back soon for new opportunities",
    actionTitle: "Browse All",
    action: { browseAll() }
)
```

**ErrorView** - Error state
```swift
ErrorView(
    message: "Failed to load data",
    action: { retryLoading() }
)
```

### Component Styling

All components support:
- **Dark mode** - Automatically adapt theme
- **Accessibility** - VoiceOver, Dynamic Type
- **States** - Loading, disabled, error
- **Customization** - Colors, sizes, actions

## Building New Screens

### Step 1: Use Theme

```swift
struct NewScreenView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            Text("Title")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppTheme.slate900)
                .padding(AppTheme.spacing4)
        }
        .background(
            colorScheme == .dark ?
            AppTheme.slate900 : Color.white
        )
    }
}
```

### Step 2: Compose from Components

```swift
struct NewScreenView: View {
    @State var text = ""
    @State var isLoading = false
    
    var body: some View {
        VStack(spacing: AppTheme.spacing3) {
            TextInputField(
                label: "Name",
                text: $text,
                placeholder: "Enter your name"
            )
            
            PrimaryButton(
                title: "Submit",
                action: handleSubmit,
                isLoading: isLoading
            )
            
            SecondaryButton(
                title: "Cancel",
                action: { }
            )
        }
        .padding(AppTheme.spacing4)
    }
    
    func handleSubmit() {
        isLoading = true
        // Do work...
        isLoading = false
    }
}
```

### Step 3: Add Navigation

```swift
NavigationStack {
    VStack {
        NavigationLink(destination: DetailView()) {
            Text("Go to Detail")
        }
    }
}
```

## Common Patterns

### Loading State
```swift
@State var isLoading = false
@State var data: [Item] = []

var body: some View {
    if isLoading {
        LoadingView()
    } else if data.isEmpty {
        EmptyStateView(
            icon: "folders",
            title: "No Items",
            message: "Create your first item",
            actionTitle: "Create",
            action: { }
        )
    } else {
        List(data) { item in
            ItemRow(item: item)
        }
    }
}

.onAppear { 
    loadData() 
}
```

### Form Submission
```swift
@State var formData = FormData()
@State var isSubmitting = false
@State var errorMessage: String?

var body: some View {
    VStack(spacing: AppTheme.spacing3) {
        TextInputField(
            label: "Email",
            text: $formData.email,
            errorMessage: errorMessage
        )
        
        PrimaryButton(
            title: "Submit",
            action: submit,
            isLoading: isSubmitting
        )
    }
}

func submit() {
    isSubmitting = true
    // Validate
    if !formData.email.contains("@") {
        errorMessage = "Invalid email"
        isSubmitting = false
        return
    }
    // Submit
    Task {
        do {
            try await someAPI.submit(formData)
            // Handle success
        } catch {
            errorMessage = error.localizedDescription
        }
        isSubmitting = false
    }
}
```

### Grid Layout
```swift
var body: some View {
    let columns = [
        GridItem(.adaptive(minimum: 160, maximum: .infinity))
    ]
    
    LazyVGrid(columns: columns, spacing: AppTheme.spacing3) {
        ForEach(items) { item in
            ItemCard(item: item)
        }
    }
    .padding(AppTheme.spacing4)
}
```

### Responsive Layout
```swift
@Environment(\.horizontalSizeClass) var sizeClass

var body: some View {
    if sizeClass == .compact {
        VStack {
            // Mobile layout
            ItemList()
            ItemDetail()
        }
    } else {
        HStack {
            // iPad layout
            ItemList()
                .frame(maxWidth: 300)
            ItemDetail()
        }
    }
}
```

## Color Reference Guide

### Primary Colors
```swift
AppTheme.primary         // #5048e5 - Purple
AppTheme.primaryLight    // #f0ecff - Light Purple (10% opacity)
AppTheme.primaryDark     // #3d38a5 - Dark Purple
```

### Semantic Colors
```swift
AppTheme.successGreen    // #0baa6a - Success
AppTheme.warningOrange   // #ff9500 - Warning
AppTheme.errorRed        // #ff3b30 - Error
AppTheme.infoBlue        // #0079ff - Information
```

### Backgrounds
```swift
AppTheme.backgroundLight // #f6f6f8 - Light background
AppTheme.backgroundDark  // #121121 - Dark background
```

### Neutrals (Slate 50-900)
```swift
AppTheme.slate50         // Nearly white
AppTheme.slate100        // Light gray
AppTheme.slate200-400    // Light to medium
AppTheme.slate500        // Medium gray
AppTheme.slate600-700    // Medium to dark
AppTheme.slate800-900    // Nearly black
```

## Best Practices

### 1. Always Use Theme Colors
❌ Bad:
```swift
Color(red: 0.314, green: 0.282, blue: 0.902)
```

✅ Good:
```swift
AppTheme.primary
```

### 2. Use Spacing Constants
❌ Bad:
```swift
.padding(16)
.spacing: 12
```

✅ Good:
```swift
.padding(AppTheme.spacing3)
.spacing(AppTheme.spacing2)
```

### 3. Compose Components
❌ Bad:
```swift
HStack {
    Text("Submit")
        .foregroundColor(.white)
        .padding(12)
        .background(Color(red: 0.314, green: 0.282, blue: 0.902))
        .cornerRadius(8)
}
```

✅ Good:
```swift
PrimaryButton(title: "Submit", action: { })
```

### 4. Handle Dark Mode
❌ Bad:
```swift
.background(Color.white)
```

✅ Good:
```swift
@Environment(\.colorScheme) var colorScheme
.background(colorScheme == .dark ? AppTheme.slate900 : Color.white)
```

## Performance Tips

1. **Use @ViewBuilder for complex layouts**
```swift
@ViewBuilder
var content: some View {
    if condition {
        View1()
    } else {
        View2()
    }
}
```

2. **Limit view hierarchy depth**
```swift
// Limit nesting to 10 levels max
```

3. **Use .constant() for previews**
```swift
#Preview {
    MyView()
}
```

4. **Cache expensive computations**
```swift
@State var cachedValue: String?

var computedValue: String {
    cachedValue ?? {
        let value = expensive()
        cachedValue = value
        return value
    }()
}
```

## Troubleshooting

### Colors Look Different
- Check color scheme (light vs dark mode)
- Verify hex values in Theme.swift
- Test in both modes: `.preferredColorScheme(.light/.dark)`

### Components Don't Resize
- Use `.frame(maxWidth: .infinity)` for full width
- Use `GeometryReader` for responsive sizing
- Check padding/spacing values

### Text Overflow
- Use `.lineLimit(n)` for max lines
- Use `.truncationMode(.tail)` for truncation
- Use `.minimumScaleFactor` for text scaling

## Next Steps

1. **Create New Screen:**
   - Start with Theme and spacing
   - Use ComponentLibrary for UI elements
   - Apply domain-specific styling if needed

2. **Add Navigation:**
   - Use `NavigationStack` for navigation flow
   - NavigationLink for pushing screens
   - `.navigationTitle()` for titles

3. **Connect to API:**
   - Create APIService in your project
   - Use `@State/@ObservedObject` for data binding
   - Handle loading/error/success states

---

**Status:** Ready for development ✅
