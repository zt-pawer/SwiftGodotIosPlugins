extends Control

@onready var status_label: Label = $MarginContainer/VBoxContainer/StatusLabel

var iap_items : Array[String] = ['consumable1','noconsumable1','subscription1','SubscriptioGroup','NoSubscription1']
var _inapppurchase: InAppPurchase
var _products : Dictionary = {}

func _ready() -> void:
	if _inapppurchase == null && ClassDB.class_exists("InAppPurchase"):
		_inapppurchase = ClassDB.instantiate("InAppPurchase")
		_inapppurchase.in_app_purchase_fetch_success.connect(_on_in_app_purchase_fetch_success)
		_inapppurchase.in_app_purchase_fetch_fail.connect(_on_in_app_purchase_fetch_fail)
		_inapppurchase.in_app_purchase_success.connect(_on_in_app_purchase_success)
		_inapppurchase.in_app_purchase_fail.connect(_on_in_app_purchase_fail)
		_inapppurchase.in_app_purchase_restore_success.connect(_on_in_app_purchase_restore_success)
		_inapppurchase.in_app_purchase_restore_fail.connect(_on_in_app_purchase_restore_fail)

		status_label.text = "Plugin loaded"
	else:
		status_label.text = "No plugin"


func _on_in_app_purchase_fetch_fail(error: int, message: String) -> void:
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

func _on_in_app_purchase_success(message: String) -> void:
	status_label.text = "Product %s purchased" % message


func _on_in_app_purchase_fail(error: int, message: String) -> void:
	status_label.text = message


func _on_in_app_purchase_restore_success(products: Array[Variant]) -> void:
	for product in products:
		status_label.text = str(product)


func _on_in_app_purchase_restore_fail(error: int, message: String) -> void:
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
