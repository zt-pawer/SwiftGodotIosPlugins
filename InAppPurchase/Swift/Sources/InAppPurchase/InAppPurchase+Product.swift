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

    internal func purchaseProductAsync(
        _ productID: String,
        completion: @escaping (InAppPurchaseError?) -> Void
    ) {
        guard let product = products_cached.first(where: { $0.id == productID })
        else {
            completion(.productNotFound)
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
                        completion(nil)
                    case .unverified(_, let error):
                        completion(.failedToVerify)
                    }
                case .pending:
                    completion(.pending)
                case .userCancelled:
                    completion(.failedToPurchase)
                }
            }
            catch {
                completion(.unknownError)
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
        completion: @escaping ([String], InAppPurchaseError?) -> Void
    ) {
        Task {
            do {
                // Perform a sync operation
                try await AppStore.sync()

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
