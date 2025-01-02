//
//  InAppPurchaseProduct.swift
//  InAppPurchase
//
//  Created by ZT Pawer on 12/31/24.
//

import Foundation
import StoreKit
import SwiftGodot

@Godot
class InAppPurchaseProduct: Object {
    
    @PickerNameProvider
    enum ProductType: Int {
        case unknown = 0
        case consumable = 1
        case nonConsumable = 2
        case autoRenewable = 3
        case nonRenewable = 4
    }
    
    @Export var identifier: String = ""
    @Export var displayName: String = ""
    @Export var longDescription: String = ""
    @Export var displayPrice: String = ""
    @Export var type: Int = ProductType.unknown.rawValue
    
    // Initialize using StoreKit's Product
    convenience init(product: Product) {
        self.init()
        self.identifier = product.id
        self.displayName = product.displayName
        self.longDescription = product.description
        self.displayPrice = product.displayPrice

        // Determine product type
        switch product.type {
        case .consumable:
            self.type = ProductType.consumable.rawValue
        case .nonConsumable:
            self.type = ProductType.nonConsumable.rawValue
        case .autoRenewable:
            self.type = ProductType.autoRenewable.rawValue
        case .nonRenewable:
            self.type = ProductType.nonRenewable.rawValue
        default:
            self.type = ProductType.unknown.rawValue
        }
    }
}
