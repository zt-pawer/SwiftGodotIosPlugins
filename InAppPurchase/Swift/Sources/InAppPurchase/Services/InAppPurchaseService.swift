import Foundation
import StoreKit

// MARK: - InAppPurchase Data Models (Pure Swift)

public struct InAppPurchaseProductData {
    public let identifier: String
    public let displayName: String
    public let longDescription: String
    public let displayPrice: String
    public let price: Float
    public let type: Int
    
    public init(identifier: String, displayName: String, longDescription: String, displayPrice: String, price: Float, type: Int) {
        self.identifier = identifier
        self.displayName = displayName
        self.longDescription = longDescription
        self.displayPrice = displayPrice
        self.price = price
        self.type = type
    }
}

public struct InAppPurchaseTransactionData {
    public let productID: String
    public let transactionID: String
    public let originalTransactionID: String
    public let jwsRepresentation: String
    public let purchaseDate: Date
    public let appAccountToken: UUID?
    
    public init(productID: String, transactionID: String, originalTransactionID: String, jwsRepresentation: String, purchaseDate: Date, appAccountToken: UUID?) {
        self.productID = productID
        self.transactionID = transactionID
        self.originalTransactionID = originalTransactionID
        self.jwsRepresentation = jwsRepresentation
        self.purchaseDate = purchaseDate
        self.appAccountToken = appAccountToken
    }
}

// MARK: - InAppPurchaseService Protocol

public protocol InAppPurchaseServiceProtocol {
    func fetchProducts(identifiers: [String], completion: @escaping (Result<[InAppPurchaseProductData], InAppPurchaseError>) -> Void)
    func purchaseProduct(_ productID: String, completion: @escaping (Result<InAppPurchaseTransactionData, InAppPurchaseError>) -> Void)
    func fetchActiveAutoRenewableSubscriptions(completion: @escaping ([String]) -> Void)
    func fetchAutoRenewableTransactionCounts(completion: @escaping ([String: Int]) -> Void)
    func restorePurchases(skipSync noSync: Bool, completion: @escaping (Result<[String], InAppPurchaseError>) -> Void)
    var onTransactionUpdated: ((Result<InAppPurchaseTransactionData, Error>) -> Void)? { get set }
}

// MARK: - InAppPurchaseService Concrete Implementation

public final class InAppPurchaseService: InAppPurchaseServiceProtocol {
    
    private var productsCached: [Product] = []
    private var allAutoRenewableSubscriptionTransactions = Set<Transaction>()
    private var updateListenerTask: Task<Void, Never>?
    
    public var onTransactionUpdated: ((Result<InAppPurchaseTransactionData, Error>) -> Void)?
    
    public init() {
        startTransactionListener()
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    public func fetchProducts(identifiers: [String], completion: @escaping (Result<[InAppPurchaseProductData], InAppPurchaseError>) -> Void) {
        Task {
            do {
                let storeProducts = try await Product.products(for: identifiers)
                self.productsCached = storeProducts
                
                let result = storeProducts.map { product in
                    let typeValue: Int
                    switch product.type {
                    case .consumable: typeValue = 1
                    case .nonConsumable: typeValue = 2
                    case .autoRenewable: typeValue = 3
                    case .nonRenewable: typeValue = 4
                    default: typeValue = 0
                    }
                    return InAppPurchaseProductData(
                        identifier: product.id,
                        displayName: product.displayName,
                        longDescription: product.description,
                        displayPrice: product.displayPrice,
                        price: Float(product.price.toDouble()),
                        type: typeValue
                    )
                }
                completion(.success(result))
            } catch {
                completion(.failure(.failedToFetchProducts))
            }
        }
    }
    
    public func purchaseProduct(_ productID: String, completion: @escaping (Result<InAppPurchaseTransactionData, InAppPurchaseError>) -> Void) {
        guard let product = productsCached.first(where: { $0.id == productID }) else {
            completion(.failure(.productNotFound))
            return
        }
        
        Task {
            do {
                let result = try await product.purchase()
                switch result {
                case .success(let verification):
                    switch verification {
                    case .verified(let transaction):
                        await transaction.finish()
                        let data = InAppPurchaseTransactionData(
                            productID: transaction.productID,
                            transactionID: String(transaction.id),
                            originalTransactionID: String(transaction.originalID),
                            jwsRepresentation: verification.jwsRepresentation,
                            purchaseDate: transaction.purchaseDate,
                            appAccountToken: transaction.appAccountToken
                        )
                        completion(.success(data))
                    case .unverified(_, _):
                        completion(.failure(.failedToVerify))
                    }
                case .pending:
                    completion(.failure(.pending))
                case .userCancelled:
                    completion(.failure(.failedToPurchase))
                }
            } catch {
                completion(.failure(.unknownError))
            }
        }
    }
    
    public func fetchActiveAutoRenewableSubscriptions(completion: @escaping ([String]) -> Void) {
        Task {
            var activeSubscriptions: [String] = []
            for await latestTransaction in Transaction.currentEntitlements {
                switch latestTransaction {
                case .verified(let transaction):
                    if .autoRenewable == transaction.productType
                        && transaction.revocationDate == nil
                        && !transaction.isUpgraded {
                        activeSubscriptions.append(transaction.productID)
                    }
                case .unverified(_, _):
                    continue
                }
            }
            completion(activeSubscriptions)
        }
    }
    
    public func fetchAutoRenewableTransactionCounts(completion: @escaping ([String: Int]) -> Void) {
        Task {
            var counts = [String: Int]()
            for await latestTransaction in Transaction.all {
                switch latestTransaction {
                case .verified(let transaction):
                    if .autoRenewable == transaction.productType
                        && transaction.revocationDate == nil
                        && !transaction.isUpgraded {
                        self.allAutoRenewableSubscriptionTransactions.insert(transaction)
                    }
                case .unverified(_, _):
                    continue
                }
            }
            
            for transaction in self.allAutoRenewableSubscriptionTransactions {
                let current = counts[transaction.productID] ?? 0
                counts[transaction.productID] = current + transaction.purchasedQuantity
            }
            completion(counts)
        }
    }
    
    public func restorePurchases(skipSync noSync: Bool, completion: @escaping (Result<[String], InAppPurchaseError>) -> Void) {
        Task {
            do {
                if !noSync { try await AppStore.sync() }
                
                var restored: [String] = []
                for await restoredTransactions in Transaction.currentEntitlements {
                    switch restoredTransactions {
                    case .verified(let transaction):
                        if transaction.revocationDate == nil && !transaction.isUpgraded {
                            restored.append(transaction.productID)
                        }
                    case .unverified(_, _):
                        continue
                    }
                }
                completion(.success(restored))
            } catch {
                completion(.failure(.failedToRestore))
            }
        }
    }
    
    private func startTransactionListener() {
        updateListenerTask = Task.detached(priority: .background) {
            for await result in Transaction.updates {
                switch result {
                case .verified(let transaction):
                    await transaction.finish()
                    let data = InAppPurchaseTransactionData(
                        productID: transaction.productID,
                        transactionID: String(transaction.id),
                        originalTransactionID: String(transaction.originalID),
                        jwsRepresentation: result.jwsRepresentation,
                        purchaseDate: transaction.purchaseDate,
                        appAccountToken: transaction.appAccountToken
                    )
                    
                    if .autoRenewable == transaction.productType
                        && transaction.revocationDate == nil
                        && !transaction.isUpgraded {
                        self.allAutoRenewableSubscriptionTransactions.insert(transaction)
                    }
                    self.onTransactionUpdated?(.success(data))
                    
                case .unverified(_, let error):
                    self.onTransactionUpdated?(.failure(error))
                }
            }
        }
    }
}

// MARK: - Extension Helper

extension Decimal {
    func toDouble() -> Double {
        var d: Double = 0.0
        for idx in (0..<min(self._length, 8)).reversed() {
            var m: Double = Double(0.0)
            switch idx {
            case 0: m = Double(self._mantissa.0)
            case 1: m = Double(self._mantissa.1)
            case 2: m = Double(self._mantissa.2)
            case 3: m = Double(self._mantissa.3)
            case 4: m = Double(self._mantissa.4)
            case 5: m = Double(self._mantissa.5)
            case 6: m = Double(self._mantissa.6)
            case 7: m = Double(self._mantissa.7)
            default: break
            }
            d = d * 65536 + m
        }
        if self._exponent < 0 {
            for _ in self._exponent..<0 { d /= 10.0 }
        } else {
            for _ in 0..<self._exponent { d *= 10.0 }
        }
        return self._isNegative != 0 ? -d : d
    }
    
    func toFloat() -> Float {
        return Float(self.toDouble())
    }
}
