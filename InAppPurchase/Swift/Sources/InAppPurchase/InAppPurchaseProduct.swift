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
    @Export var price: Float = 0 // Needs to be float to conform to Godot float
    @Export var type: Int = ProductType.unknown.rawValue
    
    // Initialize using StoreKit's Product
    convenience init(product: Product) {
        self.init()
        self.identifier = product.id
        self.displayName = product.displayName
        self.longDescription = product.description
        self.displayPrice = product.displayPrice
        self.price = product.price.toFloat()

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

extension Decimal {
    func toDouble() -> Double {
        var d: Double = 0.0
        for idx in (0..<min(self._length, 8)).reversed() {
            var m: Double = Double(0.0)
            switch idx {
            case 0: m = Double(self._mantissa.0)
                break
            case 1: m = Double(self._mantissa.1)
                break
            case 2: m = Double(self._mantissa.2)
                break
            case 3: m = Double(self._mantissa.3)
                break
            case 4: m = Double(self._mantissa.4)
                break
            case 5: m = Double(self._mantissa.5)
                break
            case 6: m = Double(self._mantissa.6)
                break
            case 7: m = Double(self._mantissa.7)
                break
            default: break
            }
            d = d * 65536 + m
        }

        if self._exponent < 0 {
            for _ in self._exponent..<0 {
                d /= 10.0
            }
        } else {
            for _ in 0..<self._exponent {
                d *= 10.0
            }
        }
        return self._isNegative != 0 ? -d : d
    }

    func toFloat() -> Float {
        return Float(self.toDouble())
    }}
