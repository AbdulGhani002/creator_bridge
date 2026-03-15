# Creator Bridge – Codebase Changes Documentation

This document describes all codebase changes implemented to fix bugs, resolve build errors, and improve the app's architecture.

---

## Table of Contents

1. [Package & Module Visibility](#1-package--module-visibility)
2. [StoreKit & Subscriptions](#2-storekit--subscriptions)
3. [User Model & Settings](#3-user-model--settings)
4. [API Authentication](#4-api-authentication)
5. [APIService Improvements](#5-apiservice-improvements)
6. [Models & Codable](#6-models--codable)
7. [UI & UX Fixes](#7-ui--ux-fixes)
8. [SwiftUI API Compatibility](#8-swiftui-api-compatibility)
9. [Build & Linker Fixes](#9-build--linker-fixes)

---

## 1. Package & Module Visibility

### Changes

- **`SessionManager`** – Made `public class` with `public init(apiService:)`
- **`RootView`** – Made `public struct` with `public init()` and `public var body`
- **`APIService`** – Made `public class` with `public init`

### Why

When the CreatorBridgeFrontend package is used as a library by the host app (creator-bridge), types used across module boundaries must be `public`. The app imports the package and uses `SessionManager()` and `RootView()` — these types and their initializers must be visible to the app module.

---

## 2. StoreKit & Subscriptions

### Changes

**`StoreKitManager.swift`**

- Replaced `updateSubscription(planId:receiptString:)` with `updateSubscription(_ payload: SubscriptionUpdateRequest)`
- Built `SubscriptionUpdateRequest` with `productId`, `transactionId`, `expiresAt`, and `plan` from StoreKit `Transaction`
- Replaced non-existent `session.me()` with `session.apiService.getMe()` and `session.user = updatedUser`

### Why

- The API expects `SubscriptionUpdateRequest` (productId, transactionId, expiresAt, plan), not raw planId/receiptString
- `SessionManager` has no `me()` method; the correct flow is to call `getMe()` and update the session's user
- StoreKit 2 `Transaction` provides `id`, `productID`, `expirationDate` — these map directly to the API payload

---

## 3. User Model & Settings

### Changes

**`Models.swift`**

- Added `subscriptionTier: String?` to `User` with `subscription_tier` coding key

**`SettingsView.swift`**

- Uses `session.user?.subscriptionTier ?? "free"` for the Current Plan display

### Why

`SettingsView` was referencing `session.user?.subscriptionTier`, but `User` did not define this property, causing a compile error. The backend can return subscription tier on the user object; making it optional keeps decoding compatible with older API responses.

---

## 4. API Authentication

### Changes

**ViewModels** – All ViewModels that call the API now receive `session.apiService` instead of `APIService()`:

- `CampaignListViewModel`
- `CreatorSearchViewModel`
- `CreatorAnalyticsViewModel`
- `BrandAnalyticsViewModel`
- `ApplicationsViewModel`
- `AgreementsViewModel`
- `MessagesViewModel`

**Views** – Updated to pass `session` and create ViewModels with authenticated API:

- `CreatorTabView`, `BrandTabView` – Added `@EnvironmentObject session`, pass to children
- `CampaignListView`, `CreatorSearchView`, `CreatorHomeView`, `BrandHomeView`, `MessagesListView`, `ApplicationsListView`, `AgreementsListView` – Added `init(session:)` and create ViewModels with `session.apiService`
- `ChatThreadView`, `AgreementDetailView` – Accept `session` and create ViewModels with authenticated API

### Why

ViewModels were using `APIService()` without the auth token. All API calls returned 401 Unauthorized. Injecting `session.apiService` ensures the token is set and requests are authenticated.

---

## 5. APIService Improvements

### Changes

**`APIService.swift`**

- Replaced `fatalError("Invalid base URL")` with `URL(string: baseURL) ?? URL(string: "http://localhost:8000")!`
- Updated `buildURL(path:)` to use `URL(string: path, relativeTo: baseURL)` instead of `baseURL.appendingPathComponent(path)`

### Why

- `fatalError` would crash the app if `API_BASE_URL` was invalid; a safe fallback avoids crashes
- `appendingPathComponent` can mangle query strings (e.g. `?` becomes `%3F`); `URL(string:relativeTo:)` correctly handles paths with query parameters

---

## 6. Models & Codable

### Changes

**`Models.swift` – `SocialPlatform`**

- Replaced `let id = UUID()` with `var id: String { "\(platform.rawValue)_\(handle)" }`

### Why

- `id = UUID()` was not in `CodingKeys`, so it was never decoded and each instance got a new UUID
- New UUIDs on every decode broke `ForEach` identity and caused UI glitches
- A computed `id` from `platform` and `handle` is stable and decode-safe

---

## 7. UI & UX Fixes

### Changes

**`CreatorViews.swift`**

- Replaced `URL(fileURLWithPath: "")` with `URL(string: "about:blank")!` for invalid portfolio URLs

**`CreatorSearchView` / `CreatorSearchViewModel`**

- Added `searchWithDebounce(location:)` with 0.3s debounce
- Wired `onChange(of: searchText)` to `searchWithDebounce` instead of calling the API on every keystroke

**`MessagesViewModel`**

- Updated `sendMessage(_:threadId:)` to call `loadMessages(threadId:)` after a successful send
- Ensures the new message appears in the list without manual refresh

**`SubscriptionPlansView.swift`**

- Replaced `.constant(storeManager.purchaseError != nil)` with a `Binding(get:set:)` that updates when the error is cleared

### Why

- `URL(fileURLWithPath: "")` is not a valid web URL; `about:blank` is a safe fallback for invalid links
- Search debouncing reduces API calls while typing and improves performance
- Messages list was not updating after send; reloading after success fixes this
- `.constant()` prevented the alert from dismissing when `purchaseError` was cleared; a proper `Binding` fixes the dismiss behavior

---

## 8. SwiftUI API Compatibility

### Changes

**String formatting**

- Replaced `\(value, specifier: "%.0f")` with `String(format: "%.0f", value)` in:
  - `HomeViews.swift`
  - `CampaignViews.swift`
  - `CreatorViews.swift`
  - `AgreementsViews.swift`
  - `ReviewsViews.swift`

**Section initializer**

- Replaced `Section(header: "text")` with `Section("text")` in:
  - `MoreComplianceViews.swift`
  - `ComplianceViews.swift`

### Why

- `\(value, specifier:)` is not valid Swift string interpolation; the compiler expected a different argument label
- `Section(header: "text")` is not the correct SwiftUI API; the string header form is `Section("text")`

---

## 9. Build & Linker Fixes

### Changes

**`CreatorBridgeApp.swift` (frontend package)**

- Removed `@main` from the `CreatorBridgeApp` struct

### Why

Both the creator-bridge app and the CreatorBridgeFrontend package had `@main`, producing duplicate `_main` symbols and linker errors. The package is used as a library; only the host app should define the entry point.

---

## Summary

| Category        | Files Affected                                      | Purpose                          |
|----------------|-----------------------------------------------------|----------------------------------|
| Visibility     | SessionManager, RootView, APIService                | Enable package-as-library usage  |
| StoreKit       | StoreKitManager                                    | Correct subscription API usage    |
| Models         | Models, SettingsView                               | Add subscriptionTier to User     |
| Auth           | ViewModels, RootView, HomeViews, CampaignViews, etc.| Fix 401 by using session.apiService |
| APIService     | APIService                                         | Safer URL handling               |
| SocialPlatform | Models                                             | Stable Identifiable id           |
| UI/UX          | CreatorViews, CreatorSearchView, MessagesViewModel, SubscriptionPlansView | Debouncing, URLs, alerts |
| SwiftUI        | HomeViews, CampaignViews, CreatorViews, AgreementsViews, ReviewsViews, MoreComplianceViews, ComplianceViews | Formatting and Section API |
| Build          | CreatorBridgeApp                                   | Remove duplicate @main           |
