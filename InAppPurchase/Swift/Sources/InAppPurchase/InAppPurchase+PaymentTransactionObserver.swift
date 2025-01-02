//
//  ICloudViewController.swift
//  SwiftGodotIosPlugins
//
//  Created by ZT Pawer on 12/30/24.
//

// MARK: - SKPaymentTransactionObserver
extension InAppPurchase: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                completeTransaction(transaction)
            case .failed:
                failTransaction(transaction)
            case .restored:
                restoreTransaction(transaction)
            case .purchasing, .deferred:
                break
            @unknown default:
                break
            }
        }
    }

    private func completeTransaction(_ transaction: SKPaymentTransaction) {
        DispatchQueue.main.async {
            self.purchaseStatus = "Purchase successful!"
        }
        // Unlock purchased content here
        SKPaymentQueue.default().finishTransaction(transaction)
    }

    private func failTransaction(_ transaction: SKPaymentTransaction) {
        DispatchQueue.main.async {
            self.purchaseStatus = "Purchase failed: \(transaction.error?.localizedDescription ?? "Unknown error")"
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }

    private func restoreTransaction(_ transaction: SKPaymentTransaction) {
        DispatchQueue.main.async {
            self.purchaseStatus = "Purchase restored!"
        }
        // Restore purchased content here
        SKPaymentQueue.default().finishTransaction(transaction)
    }
}