import XCTest
@testable import InAppPurchase

class MockInAppPurchaseService: InAppPurchaseServiceProtocol {
    var shouldSucceed = true
    var onTransactionUpdated: ((Result<InAppPurchaseTransactionData, Error>) -> Void)?
    
    var mockProduct = InAppPurchaseProductData(
        identifier: "premium_upgrade",
        displayName: "Premium Upgrade",
        longDescription: "Unlock premium features",
        displayPrice: "$4.99",
        price: 4.99,
        type: 2
    )
    
    var mockTransaction = InAppPurchaseTransactionData(
        productID: "premium_upgrade",
        transactionID: "tx_123",
        originalTransactionID: "tx_123",
        jwsRepresentation: "fake_jws_signature",
        purchaseDate: Date(),
        appAccountToken: nil
    )
    
    func fetchProducts(identifiers: [String], completion: @escaping (Result<[InAppPurchaseProductData], InAppPurchaseError>) -> Void) {
        if shouldSucceed {
            completion(.success([mockProduct]))
        } else {
            completion(.failure(.failedToFetchProducts))
        }
    }
    
    func purchaseProduct(_ productID: String, completion: @escaping (Result<InAppPurchaseTransactionData, InAppPurchaseError>) -> Void) {
        if shouldSucceed {
            completion(.success(mockTransaction))
        } else {
            completion(.failure(.failedToPurchase))
        }
    }
    
    func fetchActiveAutoRenewableSubscriptions(completion: @escaping ([String]) -> Void) {
        completion(shouldSucceed ? ["premium_sub"] : [])
    }
    
    func fetchAutoRenewableTransactionCounts(completion: @escaping ([String: Int]) -> Void) {
        completion(shouldSucceed ? ["premium_sub": 2] : [:])
    }
    
    func restorePurchases(skipSync noSync: Bool, completion: @escaping (Result<[String], InAppPurchaseError>) -> Void) {
        if shouldSucceed {
            completion(.success(["premium_upgrade"]))
        } else {
            completion(.failure(.failedToRestore))
        }
    }
}

final class InAppPurchaseTests: XCTestCase {
    func testInAppPurchaseErrorDescriptions() {
        XCTAssertEqual(InAppPurchaseError.unknownError.localizedDescription, "An unknown error occurred.")
        XCTAssertEqual(InAppPurchaseError.notAuthenticated.localizedDescription, "The user is not authenticated.")
        XCTAssertEqual(InAppPurchaseError.notAvailable.localizedDescription, "The feature is not available.")
        XCTAssertEqual(InAppPurchaseError.productNotFound.localizedDescription, "The requested product was not found.")
        XCTAssertEqual(InAppPurchaseError.failedToFetchProducts.localizedDescription, "Failed to fetch the products from the store.")
        XCTAssertEqual(InAppPurchaseError.failedToPurchase.localizedDescription, "An error occurred during the purchase process.")
        XCTAssertEqual(InAppPurchaseError.failedToVerify.localizedDescription, "Failed to verify purchase.")
        XCTAssertEqual(InAppPurchaseError.failedToRestore.localizedDescription, "Failed to restore purchases.")
        XCTAssertEqual(InAppPurchaseError.pending.localizedDescription, "The purchase is pending some user action.")
    }
    
    func testInAppPurchaseServiceFetchSuccess() {
        let service = MockInAppPurchaseService()
        let expectation = self.expectation(description: "Fetch success")
        
        service.fetchProducts(identifiers: ["premium_upgrade"]) { result in
            switch result {
            case .success(let list):
                XCTAssertEqual(list.count, 1)
                XCTAssertEqual(list.first?.identifier, "premium_upgrade")
            case .failure(let error):
                XCTFail("Should not fail: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testInAppPurchaseServicePurchaseSuccess() {
        let service = MockInAppPurchaseService()
        let expectation = self.expectation(description: "Purchase success")
        
        service.purchaseProduct("premium_upgrade") { result in
            switch result {
            case .success(let tx):
                XCTAssertEqual(tx.productID, "premium_upgrade")
                XCTAssertEqual(tx.transactionID, "tx_123")
            case .failure(let error):
                XCTFail("Should not fail: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
}
