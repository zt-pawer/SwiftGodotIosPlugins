//
//  InAppPurchase.swift
//  SwiftGodotIosPlugins
//
//  Created by ZT Pawer on 12/30/24.
//

import Foundation
import StoreKit
import SwiftGodot

#initSwiftExtension(
    cdecl: "inapppurchase",
    types: [
        InAppPurchase.self,
        InAppPurchaseProduct.self,
    ]
)

enum InAppPurchaseError: Int, Error {
    case unknownError = 1
    case notAuthenticated = 2
    case notAvailable = 3
    case productNotFound = 4
    case failedToFetchProducts = 5
    case failedToPurchase = 6
    case failedToVerify = 7
    case failedToRestore = 8
    case pending = 9

    var localizedDescription: String {
        switch self {
        case .unknownError:
            return "An unknown error occurred."
        case .notAuthenticated:
            return "The user is not authenticated."
        case .notAvailable:
            return "The feature is not available."
        case .productNotFound:
            return "The requested product was not found."
        case .failedToFetchProducts:
            return "Failed to fetch the products from the store."
        case .failedToPurchase:
            return "An error occurred during the purchase process."
        case .failedToVerify:
            return "Failed to verify purchase."
        case .failedToRestore:
            return "Failed to restore purchases."
        case .pending:
            return "The purchase is pending some user action."
        }
    }
}

@Godot
class InAppPurchase: Object , ObservableObject {

    static var shared: InAppPurchase?

    // Static ISO8601 formatter for performance (creating formatters is expensive)
    private static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    var availableProducts: [InAppPurchaseProduct] = []
    var purchasedProductIDs: Set<String> = []
    internal var products_cached: [Product] = []
    internal var allAutoRenewableSubscriptionTransactions = Set<Transaction>()

    // StoreKit's transaction listener
    private var updateListenerTask: Task<Void, Never>?

    /// @Signal
    /// Success signal during purchase process (backward compatible - emits only productID)
    @Signal var inAppPurchaseSuccess: SignalWithArguments<String>
    /// @Signal
    /// Success signal with full transaction data for server-side validation
    /// Dictionary contains: product_id (String), transaction_id (String), original_transaction_id (String),
    /// jws_representation (String), purchase_date (String ISO8601), app_account_token (String or empty)
    @Signal var inAppPurchaseSuccessWithTransaction: SignalWithArguments<GDictionary>
    /// @Signal
    /// Success signal during products fetch process
    @Signal var inAppPurchaseFetchSuccess:
        SignalWithArguments<ObjectCollection<InAppPurchaseProduct>>
    /// @Signal
    /// Error signal during products fetch process
    @Signal var inAppPurchaseFetchError: SignalWithArguments<Int, String>
    /// @Signal
    /// Success signal during active renewable products fetch process
    @Signal var inAppPurchaseFetchActiveAutoRenewableSubscriptions:
        SignalWithArguments<GArray>
    /// @Signal
    /// Success signal during renewable transaction counts fetch process
    @Signal var inAppPurchaseFetchAutoRenewableTransactionCounts:
        SignalWithArguments<GDictionary>
    /// @Signal
    /// Error signal during purchase process
    @Signal var inAppPurchaseError: SignalWithArguments<Int, String>
    /// @Signal
    /// Success signal during purchase restore process
    @Signal var inAppPurchaseRestoreSuccess: SignalWithArguments<GArray>
    /// @Signal
    /// Error signal during purchase restore process
    @Signal var inAppPurchaseRestoreError: SignalWithArguments<Int, String>

    required override init() {
        super.init()
        startTransactionListener()
        InAppPurchase.shared = self
    }

    required init(nativeHandle: UnsafeRawPointer) {
        super.init()
        startTransactionListener()
        InAppPurchase.shared = self
    }

    deinit {
        stopTransactionListener()
        InAppPurchase.shared = nil
    }

    // MARK: - Synchronous API Exposed to the Caller

    /// @Callable
    ///
    /// Fetch products from the App Store with listeners (completion handlers)
    @Callable
    func fetchProducts(_ products: [String]) {
        fetchProductsAsync(
            with: products,
            completion: { error in
                guard error == nil else {
                    DispatchQueue.main.async {
                        self.inAppPurchaseFetchError.emit(
                            error!.rawValue, error!.localizedDescription)
                    }
                    return
                }
                var iapProducts = ObjectCollection<InAppPurchaseProduct>()
                for product in self.products_cached {
                    iapProducts.append(InAppPurchaseProduct(product: product))
                }
                DispatchQueue.main.async {
                    self.inAppPurchaseFetchSuccess.emit(iapProducts)
                }
            })
    }

    /// @Callable
    ///
    /// Synchronously fetches active auto-renewable subscriptions (does not block UI, callback when done)
    @Callable
    func fetchActiveAutoRenewableSubscriptions() {
        fetchActiveAutoRenewableSubscriptionsAsync(completion: { products in
            var productsArray = GArray()
            products.forEach { productsArray.append(Variant($0)) }
            DispatchQueue.main.async {
                self.inAppPurchaseFetchActiveAutoRenewableSubscriptions.emit(productsArray)
            }
        })
    }

    /// @Callable
    ///
    /// Synchronously fetches all auto-renewable subscription transactions (does not block UI, callback when done)
    @Callable
    func fetchAutoRenewableTransactionCounts() {
        fetchAutoRenewableTransactionsAsync(completion: { transactions in
            
            // Tally the transaction count for each subscription.
            self.allAutoRenewableSubscriptionTransactions = self.allAutoRenewableSubscriptionTransactions.union(transactions)
            var autoRenewableTransactionCounts = [String : Int]()
            for transaction in self.allAutoRenewableSubscriptionTransactions {
                let transactionCount = autoRenewableTransactionCounts[transaction.productID] ?? 0
                autoRenewableTransactionCounts[transaction.productID] = transactionCount + transaction.purchasedQuantity
            }

            // Convert the dictionary to a GDictionary, and pass it back to Godot via the signal.
            var countGDictionary = GDictionary()
            autoRenewableTransactionCounts.forEach { countGDictionary[Variant($0.key)] = Variant($0.value) }
            DispatchQueue.main.async {
                self.inAppPurchaseFetchAutoRenewableTransactionCounts.emit(countGDictionary)
            }
        })
    }

    /// @Callable
    ///
    /// Synchronously purchase a product (does not block UI, callback when done)
    @Callable
    func purchaseProduct(_ productID: String) {
        purchaseProductAsync(
            productID,
            completion: { result, error in
                guard error == nil, let result = result else {
                    DispatchQueue.main.async {
                        self.inAppPurchaseError.emit(
                            error!.rawValue, error!.localizedDescription)
                    }
                    return
                }
                DispatchQueue.main.async {
                    // Emit backward-compatible signal with just productID
                    self.inAppPurchaseSuccess.emit(productID)

                    // Build transaction data dictionary for server-side validation
                    let transactionData = self.buildTransactionDictionary(from: result)
                    self.inAppPurchaseSuccessWithTransaction.emit(transactionData)
                }
            })
    }

    /// Builds a GDictionary containing transaction data for server-side validation
    private func buildTransactionDictionary(from result: TransactionResult) -> GDictionary {
        var dict = GDictionary()
        let transaction = result.transaction

        // Product identifier
        dict["product_id"] = Variant(transaction.productID)

        // Transaction ID (UInt64 as String for cross-platform compatibility)
        dict["transaction_id"] = Variant(String(transaction.id))

        // Original transaction ID (for subscription renewals)
        dict["original_transaction_id"] = Variant(String(transaction.originalID))

        // JWS representation - cryptographic proof for server validation
        dict["jws_representation"] = Variant(result.jwsRepresentation)

        // Purchase date in ISO8601 format (using static formatter for performance)
        dict["purchase_date"] = Variant(Self.iso8601Formatter.string(from: transaction.purchaseDate))

        // App account token (optional UUID set during purchase)
        if let appAccountToken = transaction.appAccountToken {
            dict["app_account_token"] = Variant(appAccountToken.uuidString)
        } else {
            dict["app_account_token"] = Variant("")
        }

        return dict
    }

    /// @Callable
    ///
    /// Synchronously restore purchases (does not block UI, callback when done)
    @Callable
    func restorePurchases(skipSync noSync:Bool = false) {
        restorePurchasesAsync(skipSync: noSync, completion: { products, error in
            guard error == nil else {
                DispatchQueue.main.async {
                    self.inAppPurchaseRestoreError.emit(
                        error!.rawValue, error!.localizedDescription)
                }
                return
            }
            var productsArray = GArray()
            products.forEach { productsArray.append(Variant($0)) }
            DispatchQueue.main.async {
                self.inAppPurchaseRestoreSuccess.emit(productsArray)
            }
        })
    }

    // MARK: - Private Helpers
    private func startTransactionListener() {
        updateListenerTask = Task.detached(priority: .background) {
            for await result in Transaction.updates {
                switch result {
                case .verified(let transaction):
                    await self.handleTransaction(transaction)
                    
                    // Store any auto-renewable subscription transactions.
                    if .autoRenewable == transaction.productType
                        && transaction.revocationDate == nil
                        && transaction.isUpgraded == false {
                            self.allAutoRenewableSubscriptionTransactions.insert(transaction)
                    }
                case .unverified(_, let error):
                    GD.printErr("Unverified transaction: \(error)")
                }
            }
        }
    }

    private func stopTransactionListener() {
        updateListenerTask?.cancel()
    }

    @MainActor
    internal func handleTransaction(_ transaction: Transaction) {
        self.purchasedProductIDs.insert(transaction.productID)
        Task {
            await transaction.finish()
        }
    }
}
