import Foundation
import SwiftGodot

#initSwiftExtension(
    cdecl: "inapppurchase",
    types: [
        InAppPurchase.self,
        InAppPurchaseProduct.self,
    ]
)

public enum InAppPurchaseError: Int, Error {
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
        case .unknownError: return "An unknown error occurred."
        case .notAuthenticated: return "The user is not authenticated."
        case .notAvailable: return "The feature is not available."
        case .productNotFound: return "The requested product was not found."
        case .failedToFetchProducts: return "Failed to fetch the products from the store."
        case .failedToPurchase: return "An error occurred during the purchase process."
        case .failedToVerify: return "Failed to verify purchase."
        case .failedToRestore: return "Failed to restore purchases."
        case .pending: return "The purchase is pending some user action."
        }
    }
}

@Godot
class InAppPurchase: Object, ObservableObject {

    static var shared: InAppPurchase?

    private static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    var purchasedProductIDs: Set<String> = []
    private var service: InAppPurchaseServiceProtocol

    /// @Signal
    /// Success signal during purchase process (backward compatible - emits only productID)
    @Signal var inAppPurchaseSuccess: SignalWithArguments<String>
    /// @Signal
    /// Success signal with full transaction data for server-side validation
    @Signal var inAppPurchaseSuccessWithTransaction: SignalWithArguments<GDictionary>
    /// @Signal
    /// Success signal during products fetch process
    @Signal var inAppPurchaseFetchSuccess:
        SignalWithArguments<TypedArray<InAppPurchaseProduct?>>
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

    required init(_ context: InitContext) {
        let defaultService = InAppPurchaseService()
        self.service = defaultService
        super.init(context)
        
        setupCallbacks()
        InAppPurchase.shared = self
    }

    deinit {
        InAppPurchase.shared = nil
    }
    
    private func setupCallbacks() {
        service.onTransactionUpdated = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                self.purchasedProductIDs.insert(data.productID)
                DispatchQueue.main.async {
                    self.inAppPurchaseSuccess.emit(data.productID)
                    let transactionData = self.buildTransactionDictionary(from: data)
                    self.inAppPurchaseSuccessWithTransaction.emit(transactionData)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.inAppPurchaseError.emit(InAppPurchaseError.failedToVerify.rawValue, error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Synchronous API Exposed to the Caller

    /// @Callable
    /// Fetch products from the App Store.
    @Callable
    func fetchProducts(_ products: [String]) {
        service.fetchProducts(identifiers: products) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let list):
                var iapProducts = TypedArray<InAppPurchaseProduct?>()
                for prodData in list {
                    let iapProd = InAppPurchaseProduct()
                    iapProd.identifier = prodData.identifier
                    iapProd.displayName = prodData.displayName
                    iapProd.longDescription = prodData.longDescription
                    iapProd.displayPrice = prodData.displayPrice
                    iapProd.price = prodData.price
                    iapProd.type = prodData.type
                    iapProducts.append(iapProd)
                }
                DispatchQueue.main.async {
                    self.inAppPurchaseFetchSuccess.emit(iapProducts)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.inAppPurchaseFetchError.emit(error.rawValue, error.localizedDescription)
                }
            }
        }
    }

    /// @Callable
    /// Fetches active auto-renewable subscriptions.
    @Callable
    func fetchActiveAutoRenewableSubscriptions() {
        service.fetchActiveAutoRenewableSubscriptions { [weak self] list in
            guard let self = self else { return }
            var productsArray = GArray()
            list.forEach { productsArray.append(Variant($0)) }
            DispatchQueue.main.async {
                self.inAppPurchaseFetchActiveAutoRenewableSubscriptions.emit(productsArray)
            }
        }
    }

    /// @Callable
    /// Fetches all auto-renewable subscription transaction counts.
    @Callable
    func fetchAutoRenewableTransactionCounts() {
        service.fetchAutoRenewableTransactionCounts { [weak self] counts in
            guard let self = self else { return }
            var countGDictionary = GDictionary()
            counts.forEach { countGDictionary[Variant($0.key)] = Variant($0.value) }
            DispatchQueue.main.async {
                self.inAppPurchaseFetchAutoRenewableTransactionCounts.emit(countGDictionary)
            }
        }
    }

    /// @Callable
    /// Purchase a product.
    @Callable
    func purchaseProduct(_ productID: String) {
        service.purchaseProduct(productID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                self.purchasedProductIDs.insert(data.productID)
                DispatchQueue.main.async {
                    self.inAppPurchaseSuccess.emit(productID)
                    let transactionData = self.buildTransactionDictionary(from: data)
                    self.inAppPurchaseSuccessWithTransaction.emit(transactionData)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.inAppPurchaseError.emit(error.rawValue, error.localizedDescription)
                }
            }
        }
    }

    /// Builds a GDictionary containing transaction data for server-side validation
    private func buildTransactionDictionary(from data: InAppPurchaseTransactionData) -> GDictionary {
        var dict = GDictionary()
        dict["product_id"] = Variant(data.productID)
        dict["transaction_id"] = Variant(data.transactionID)
        dict["original_transaction_id"] = Variant(data.originalTransactionID)
        dict["jws_representation"] = Variant(data.jwsRepresentation)
        dict["purchase_date"] = Variant(Self.iso8601Formatter.string(from: data.purchaseDate))

        if let appAccountToken = data.appAccountToken {
            dict["app_account_token"] = Variant(appAccountToken.uuidString)
        } else {
            dict["app_account_token"] = Variant("")
        }

        return dict
    }

    /// @Callable
    /// Restore purchases.
    @Callable
    func restorePurchases(skipSync noSync: Bool = false) {
        service.restorePurchases(skipSync: noSync) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let list):
                var productsArray = GArray()
                list.forEach { productsArray.append(Variant($0)) }
                DispatchQueue.main.async {
                    self.inAppPurchaseRestoreSuccess.emit(productsArray)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.inAppPurchaseRestoreError.emit(error.rawValue, error.localizedDescription)
                }
            }
        }
    }
}
