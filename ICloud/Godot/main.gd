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
	_icloud.setStringValue("Hello World", "keystring")


func _on_load_str_button_pressed() -> void:
	var value: String = _icloud.getStringValue("keystring")
	status_label.text = value


func _on_save_int_button_pressed() -> void:
	_icloud.setIntValue(6, "keyint")


func _on_load_int_button_pressed() -> void:
	var value: int = _icloud.getIntValue("keyint")
	status_label.text = str(value)


func _on_save_float_button_pressed() -> void:
	_icloud.setFloatValue(6.987654321, "keyfloat")


func _on_load_float_button_pressed() -> void:
	var value: float = _icloud.getFloatValue("keyfloat")
	status_label.text = str(value)


func _on_save_bool_button_pressed() -> void:
	_icloud.setBoolValue(true, "keybool")


func _on_load_bool_button_pressed() -> void:
	var value: bool = _icloud.getBoolValue("keybool")
	status_label.text = str(value)


func _on_icloud_fail(error: int, message: String) -> void:
	status_label.text = message


func _on_notification_change(code:int, keyValues:Dictionary) -> void:
	status_label.text = "%d - %s" % [code,str(keyValues)]
