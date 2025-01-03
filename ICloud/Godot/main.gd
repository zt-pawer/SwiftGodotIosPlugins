extends Control

@onready var status_label: Label = $MarginContainer/VBoxContainer/StatusLabel

var _icloud: ICloud

func _ready() -> void:
	if _icloud == null && ClassDB.class_exists("ICloud"):
		_icloud = ClassDB.instantiate("ICloud")
		_icloud.setAutoSync(true)
		_icloud.icloud_fail.connect(_on_icloud_fail)
		_icloud.notification_change.connect(_on_notification_change)


func _on_save_str_button_pressed() -> void:
	var value: Variant = "Hello World"
	_icloud.setValue(value, "keystring")


func _on_load_str_button_pressed() -> void:
	_readAny("keystring")


func _on_save_int_button_pressed() -> void:
	var value: Variant = 6
	_icloud.setValue(value, "keyint")


func _on_load_int_button_pressed() -> void:
	_readAny("keyint")


func _on_save_float_button_pressed() -> void:
	var value: Variant = 6.987654321
	_icloud.setValue(value, "keyfloat")


func _on_load_float_button_pressed() -> void:
	_readAny("keyfloat")


func _on_save_bool_button_pressed() -> void:
	var value: Variant = true
	_icloud.setValue(value, "keybool")


func _on_load_bool_button_pressed() -> void:
	_readAny("keybool")


func _on_icloud_fail(error: int, message: String) -> void:
	status_label.text = message


func _on_notification_change(code:int, keyValues:Dictionary) -> void:
	status_label.text = "%d - %s" % [code,str(keyValues)]


func _readAny(key:String) -> void:
	var value: Variant = _icloud.getValue(key)
	match typeof(value):
		TYPE_NIL:
			status_label.text = "Null value"
		TYPE_BOOL:
			status_label.text = str(value)
		TYPE_INT:
			status_label.text = str(value)
		TYPE_FLOAT:
			status_label.text = str(value)
		TYPE_STRING:
			status_label.text = value
		_:
			status_label.text = "Not implemented typeof(%d)" % typeof(value)
