extends Control

@onready var status_label: Label = $MarginContainer/VBoxContainer/StatusLabel

var iap_items : Array[String] = ['consumable1','noconsumable1','subscription1','SubscriptioGroup','NoSubscription1']
var _inapppurchase: InAppPurchase
var _products : Dictionary = {}
var _active_auto_renewable_subscription_product_ids : Array[Variant]

func _ready() -> void:
	if _inapppurchase == null && ClassDB.class_exists("InAppPurchase"):
		_inapppurchase = ClassDB.instantiate("InAppPurchase")
		_inapppurchase.in_app_purchase_fetch_success.connect(_on_in_app_purchase_fetch_success)
		_inapppurchase.in_app_purchase_fetch_error.connect(_on_in_app_purchase_fetch_error)
		_inapppurchase.in_app_purchase_fetch_active_auto_renewable_subscriptions.connect(_on_in_app_purchase_fetch_active_auto_renewable_subscriptions)
		_inapppurchase.in_app_purchase_fetch_auto_renewable_transaction_counts.connect(_on_in_app_purchase_fetch_auto_renewable_transaction_counts)
		_inapppurchase.in_app_purchase_success.connect(_on_in_app_purchase_success)
		_inapppurchase.in_app_purchase_error.connect(_on_in_app_purchase_error)
		_inapppurchase.in_app_purchase_restore_success.connect(_on_in_app_purchase_restore_success)
		_inapppurchase.in_app_purchase_restore_error.connect(_on_in_app_purchase_restore_error)

		status_label.text = "Plugin loaded"
	else:
		status_label.text = "No plugin"


func _on_in_app_purchase_fetch_error(error: int, message: String) -> void:
	status_label.text = message


func _on_in_app_purchase_fetch_success(products: Array[InAppPurchaseProduct]) -> void:
	status_label.text = "Products descriptions received"
	for product in products:
		status_label.text = "%s" % product.identifier
		print("%s - %s - %s - %s - %s" % [product.identifier, product.displayName, product.longDescription, product.displayPrice, str(product.type)])
		_products[product.identifier] = product
	$MarginContainer/VBoxContainer/PurchaseConsumableButton.disabled = false
	$MarginContainer/VBoxContainer/PurchaseNonConsumableButton.disabled = false
	$MarginContainer/VBoxContainer/PurchaseSubscriptionButton.disabled = false
	$MarginContainer/VBoxContainer/PurchaseSubscriptionNorenewButton.disabled = false
	$MarginContainer/VBoxContainer/FetchActiveAutoRenewableSubscriptionsButton.disabled = false
	$MarginContainer/VBoxContainer/FetchAutoRenewableTransactionCountsButton.disabled = false


func _on_in_app_purchase_fetch_active_auto_renewable_subscriptions(product_ids: Array[Variant]) -> void:
	_active_auto_renewable_subscription_product_ids.clear()
	for product_id in product_ids:
		print("%s" % product_id)
		_active_auto_renewable_subscription_product_ids.append(product_id)
	status_label.text = "Active subscriptions received: %d" % len(_active_auto_renewable_subscription_product_ids)


func _on_in_app_purchase_fetch_auto_renewable_transaction_counts(counts: Dictionary) -> void:
	print("counts: %s" % counts)
	if counts:
		status_label.text = "counts: %s" % counts
	else:
		status_label.text = "no transactions"


func _on_in_app_purchase_success(message: String) -> void:
	status_label.text = "Product %s purchased" % message


func _on_in_app_purchase_error(error: int, message: String) -> void:
	status_label.text = message


func _on_in_app_purchase_restore_success(product_ids: Array[Variant]) -> void:
	print("Products restored")
	for product_id in product_ids:
		print("%s" % product_id)
		status_label.text = str(product_id)


func _on_in_app_purchase_restore_error(error: int, message: String) -> void:
	status_label.text = message


func _on_load_products_button_pressed() -> void:
	status_label.text = "Requesting products"
	_inapppurchase.fetchProducts(iap_items)


func _on_purchase_consumable_button_pressed() -> void:
	_purchase(1)


func _on_purchase_non_consumable_button_pressed() -> void:
	_purchase(2)


func _on_purchase_subscription_button_pressed() -> void:
	_purchase(3)


func _on_purchase_subscription_norenew_button_pressed() -> void:
	_purchase(4)


func _on_fetch_active_auto_renewable_subscriptions_button_pressed() -> void:
	_inapppurchase.fetchActiveAutoRenewableSubscriptions()


func _on_fetch_auto_renewable_transaction_counts_button_pressed() -> void:
	_inapppurchase.fetchAutoRenewableTransactionCounts()


func _on_restore_button_pressed() -> void:
	_inapppurchase.restorePurchases()


func _find_a_product_by_type(type:int) -> InAppPurchaseProduct:
	var products: Array = _products.values().filter(
		func(product: InAppPurchaseProduct) -> bool:
			return product.type == type
	)
	return products.pop_front()

func _purchase(type:int) -> void:
	# @PickerNameProvider macro has some issue here using int
	var product = _find_a_product_by_type(type)
	if product == null:
		status_label.text = "No products of type %d" % type
		return
	_inapppurchase.purchaseProduct(product.identifier)
