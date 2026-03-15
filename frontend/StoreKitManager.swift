import StoreKit
import SwiftUI

enum StoreError: Error {
    case failedVerification
}

@MainActor
class StoreKitManager: ObservableObject {
    static let shared = StoreKitManager()
    
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isLoading = false
    @Published var purchaseError: String? = nil
    
    let productIds = [
        "com.creatorbridge.pro.monthly",
        "com.creatorbridge.premium.monthly"
    ]
    
    init() {
        Task {
            await loadProducts()
            await checkCurrentEntitlements()
        }
    }
    
    func loadProducts() async {
        isLoading = true
        do {
            products = try await Product.products(for: productIds)
        } catch {
            purchaseError = "Failed to load products: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func purchase(_ product: Product, session: SessionManager) async throws {
        isLoading = true
        purchaseError = nil
        
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verificationResult):
                let transaction = try checkVerified(verificationResult)
                
                // Update backend with receipt
                let tier = product.id.contains("premium") ? "premium" : "pro"
                let payload = SubscriptionUpdateRequest(
                    productId: product.id,
                    transactionId: String(transaction.id),
                    expiresAt: transaction.expirationDate,
                    plan: tier
                )
                
                _ = try await session.apiService.updateSubscription(payload)
                
                // Finish transaction
                await transaction.finish()
                
                // Refresh local session user state
                let updatedUser = try await session.apiService.getMe()
                await MainActor.run {
                    session.user = updatedUser
                }
                
            case .userCancelled:
                purchaseError = "Purchase was cancelled."
            case .pending:
                purchaseError = "Purchase is pending approval."
            @unknown default:
                purchaseError = "Unknown purchase error."
            }
        } catch {
            purchaseError = "Purchase failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func checkCurrentEntitlements() async {
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                purchasedProductIDs.insert(transaction.productID)
            } catch {
                // Ignore unverified
            }
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}
