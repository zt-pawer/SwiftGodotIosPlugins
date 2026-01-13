[![Godot](https://img.shields.io/badge/Godot%20Engine-4.3-blue.svg)](https://github.com/godotengine/godot/)
[![SwiftGodot](https://img.shields.io/badge/SwiftGodot-main-blue.svg)](https://github.com/migueldeicaza/SwiftGodot/)
![Platforms](https://img.shields.io/badge/platforms-iOS-333333.svg?style=flat)
![iOS](https://img.shields.io/badge/iOS-17+-green.svg?style=flat)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg?maxAge=2592000)](https://github.com/zt-pawer/SwiftGodotGameCenter/blob/main/LICENSE)

# Development status
Initial effort focused on bringing this GDExtension implementation to parity with [Godot InAppStore Ios Plugin](https://github.com/godot-sdk-integrations/godot-ios-plugins/tree/master/plugins/inappstore).
More functionality may be added based on needs.

# How to use it
See Godot demo project for an end to end implementation.
Register all the signals required, this can be done in the ``_ready()`` method and connect each signal to the relative method.

```
func _ready() -> void:
	if _inapppurchase == null && ClassDB.class_exists("InAppPurchase"):
		_inapppurchase = ClassDB.instantiate("InAppPurchase")
		_inapppurchase.in_app_purchase_fetch_success.connect(_on_in_app_purchase_fetch_success)
		_inapppurchase.in_app_purchase_fetch_error.connect(_on_in_app_purchase_fetch_error)
		_inapppurchase.in_app_purchase_fetch_active_auto_renewable_subscriptions.connect(_on_in_app_purchase_fetch_active_auto_renewable_subscriptions)
		_inapppurchase.in_app_purchase_fetch_auto_renewable_transaction_counts.connect(_on_in_app_purchase_fetch_auto_renewable_transaction_counts)
		_inapppurchase.in_app_purchase_success.connect(_on_in_app_purchase_success)
		_inapppurchase.in_app_purchase_success_with_transaction.connect(_on_in_app_purchase_success_with_transaction)
		_inapppurchase.in_app_purchase_error.connect(_on_in_app_purchase_error)
		_inapppurchase.in_app_purchase_restore_success.connect(_on_in_app_purchase_restore_success)
		_inapppurchase.in_app_purchase_restore_error.connect(_on_in_app_purchase_restore_error)

```

The Godot method signature required

```
func _on_in_app_purchase_fetch_error(error: int, message: String) -> void:
func _on_in_app_purchase_fetch_success(products: Array[InAppPurchaseProduct]) -> void:
func _on_in_app_purchase_fetch_active_auto_renewable_subscriptions(product_ids: Array[Variant]) -> void:
func _on_in_app_purchase_fetch_auto_renewable_transaction_counts(counts: Dictionary) -> void:
func _on_in_app_purchase_success(message: String) -> void:
func _on_in_app_purchase_success_with_transaction(result: Dictionary) -> void:
func _on_in_app_purchase_error(error: int, message: String) -> void:
func _on_in_app_purchase_restore_success(product_ids: Array[Variant]) -> void:
func _on_in_app_purchase_restore_error(error: int, message: String) -> void:
```

# Technical details

## Signals
- `in_app_purchase_fetch_success` SignalWithArguments\<ObjectCollection\<InAppPurchaseProduct>>
- `in_app_purchase_fetch_error` SignalWithArguments\<Int,Dictionary>
- `in_app_purchase_fetch_active_auto_renewable_subscriptions` SignalWithArguments\<GArray>
- `in_app_purchase_fetch_auto_renewable_transaction_counts` SignalWithArguments\<GDictionary>
- `in_app_purchase_success` SignalWithArguments\<String>
- `in_app_purchase_success_with_transaction` SignalWithArguments\<GDictionary>
- `in_app_purchase_error` SignalWithArguments\<Int,Dictionary>
- `in_app_purchase_restore_success` SignalWithArguments\<GArray>
- `in_app_purchase_restore_error` SignalWithArguments\<Int,Dictionary>

### Transaction Data Exposed in `in_app_purchase_success_with_transaction`
| Key                       | Type   | Description                               |
| ------------------------- | ------ | ----------------------------------------- |
| `product_id`              | String | Product identifier                        |
| `transaction_id`          | String | Unique transaction ID (UInt64 as String)  |
| `original_transaction_id` | String | For subscription renewals                 |
| `jws_representation`      | String | Cryptographic proof for server validation |
| `purchase_date`           | String | ISO8601 formatted timestamp               |
| `app_account_token`       | String | Optional UUID (empty string if not set)   |

## Methods

- `fetchProducts(products: [String])` - Fetch all products given in input, this method **must** be called once before any purchase.
- `fetchActiveAutoRenewableSubscriptions()` - Fetch all active auto-renewable subscriptions, returning a list of product ids.
- `fetchAutoRenewableTransactionCounts()` - Fetch all auto-renewable subscription transaction counts. Returns a dictionary, with product ids as the key, and the number of transactions as the value.  Useful for tracking monthly awards, etc.
- `purchaseProduct(productID: String)` - Purchase a given pruduct.
- `restorePurchases()` - Restore all the previous purchased products, returning a list of product ids.
