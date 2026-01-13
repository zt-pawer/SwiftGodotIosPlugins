//
//  InAppPurchase.swift
//  SwiftGodotIosPlugins
//
//  Created by ZT Pawer on 12/31/24.
//
import StoreKit
import SwiftGodot

extension InAppPurchase {

    internal func fetchProductsAsync(
        with identifiers: [String],
        completion: @escaping (InAppPurchaseError?) -> Void
    ) {
        Task {
            do {
                products_cached = try await Product.products(for: identifiers)
                completion(nil)
            } catch {
                completion(.failedToFetchProducts)
            }
        }

    }

    /// Transaction result containing transaction and JWS representation
    internal struct TransactionResult {
        let transaction: Transaction
        let jwsRepresentation: String
    }

    internal func purchaseProductAsync(
        _ productID: String,
        completion: @escaping (TransactionResult?, InAppPurchaseError?) -> Void
    ) {
        guard let product = products_cached.first(where: { $0.id == productID })
        else {
            completion(nil, .productNotFound)
            return
        }
        Task {
            do {
                let result = try await product.purchase()
                switch result {
                case .success(let verification):
                    switch verification {
                    case .verified(let transaction):
                        await self.handleTransaction(transaction)
                        let transactionResult = TransactionResult(
                            transaction: transaction,
                            jwsRepresentation: verification.jwsRepresentation
                        )
                        completion(transactionResult, nil)
                    case .unverified(_, let error):
                        completion(nil, .failedToVerify)
                    }
                case .pending:
                    completion(nil, .pending)
                case .userCancelled:
                    completion(nil, .failedToPurchase)
                }
            }
            catch {
                completion(nil, .unknownError)
            }
        }
    }

    internal func fetchActiveAutoRenewableSubscriptionsAsync(
        completion: @escaping ([String]) -> Void
    ) {
        Task {
            var activeAutoRenewableSubscriptions: [String] = []
            // Fetch all current entitlements and filter valid transactions
            for await latestTransaction in Transaction
                .currentEntitlements
            {
                switch latestTransaction
                {
                case .verified(let transaction):
                    // Check for active auto-renewable subscriptions
                    if .autoRenewable == transaction.productType
                        && transaction.revocationDate == nil
                        && transaction.isUpgraded == false
                    {
                        activeAutoRenewableSubscriptions.append(transaction.productID)
                    }
                case .unverified(
                    let unverifiedTransaction, let verificationError):
                    // Handle unverified transactions based on your
                    // business model.
                    continue

                }
            }

            // Call the completion handler with active auto-renewable subscriptions
            completion(activeAutoRenewableSubscriptions)
        }
    }
    
    internal func fetchAutoRenewableTransactionsAsync(
        completion: @escaping (Set<Transaction>) -> Void
    ) {
        Task {
            var transactions = Set<Transaction>()
            // Fetch all entitlements and filter valid transactions
            for await latestTransaction in Transaction
                .all
            {
                switch latestTransaction
                {
                case .verified(let transaction):
                    // Check for auto-renewable subscriptions
                    if .autoRenewable == transaction.productType
                        && transaction.revocationDate == nil
                        && transaction.isUpgraded == false
                    {
                        transactions.insert(transaction)
                    }
                case .unverified(
                    let unverifiedTransaction, let verificationError):
                    // Handle unverified transactions based on your
                    // business model.
                    continue

                }
            }

            // Call the completion handler with auto-renewable subscription transactions
            completion(transactions)
        }
    }
    
    internal func restorePurchasesAsync(
        skipSync noSync: Bool,
        completion: @escaping ([String], InAppPurchaseError?) -> Void
    ) {
        Task {
            do {
                // Perform a sync operation
                if !noSync { try await AppStore.sync() }

                var restoredProducts: [String] = []
                // Fetch all current entitlements and filter valid transactions
                for await restoredTransactions in Transaction
                    .currentEntitlements
                {
                    switch restoredTransactions
                    {
                    case .verified(let transaction):
                        // Check the type of product for the transaction
                        // and provide access to the content as appropriate.
                        if transaction.revocationDate == nil
                            && transaction.isUpgraded == false
                        {
                            restoredProducts.append(transaction.productID)
                        }
                    case .unverified(
                        let unverifiedTransaction, let verificationError):
                        // Handle unverified transactions based on your
                        // business model.
                        continue

                    }
                }

                // Call the completion handler with restored products
                completion(restoredProducts, nil)
            } catch {
                completion([], .failedToRestore)
            }
        }
    }
}
