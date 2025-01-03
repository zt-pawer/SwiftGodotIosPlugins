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
		_inapppurchase.in_app_purchase_fetch_fail.connect(_on_in_app_purchase_fetch_fail)
		_inapppurchase.in_app_purchase_success.connect(_on_in_app_purchase_success)
		_inapppurchase.in_app_purchase_fail.connect(_on_in_app_purchase_fail)
		_inapppurchase.in_app_purchase_restore_success.connect(_on_in_app_purchase_restore_success)
		_inapppurchase.in_app_purchase_restore_fail.connect(_on_in_app_purchase_restore_fail)
```

The Godot method signature required

```
func _on_in_app_purchase_fetch_fail(error: int, message: String) -> void:
func _on_in_app_purchase_fetch_success(products: Array[InAppPurchaseProduct]) -> void:
func _on_in_app_purchase_success(message: String) -> void:
func _on_in_app_purchase_fail(error: int, message: String) -> void:
func _on_in_app_purchase_restore_success(products: Array[Variant]) -> void:
func _on_in_app_purchase_restore_fail(error: int, message: String) -> void:
```

# Technical details

## Signals
- `in_app_purchase_fetch_success` SignalWithArguments<ObjectCollection<InAppPurchaseProduct>>
- `in_app_purchase_fetch_fail` SignalWithArguments<Int,Dictionary>
- `in_app_purchase_success` SignalWithArguments<String>
- `in_app_purchase_fail` SignalWithArguments<Int,Dictionary>
- `in_app_purchase_restore_success` SignalWithArguments<GArray>
- `in_app_purchase_restore_fail` SignalWithArguments<Int,Dictionary>

## Methods

- `fetchProducts(products: [String])` - Fetch all products given in input, this method **must** be called once before any purchase.
- `purchaseProduct(productID: String)` - Purchase a given pruduct.
- `restorePurchases()` - Restore all the previous purchased products returning a list of productIds.
