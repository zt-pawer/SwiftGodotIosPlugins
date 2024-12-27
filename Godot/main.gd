extends Control

var _gamecenter: Variant

@onready var status_label: Label = $VBoxContainer/StatusLabel

func _ready() -> void:
	if _gamecenter == null && ClassDB.class_exists("GameCenter"):
		_gamecenter = ClassDB.instantiate("GameCenter")
		_gamecenter.signin_success.connect(_on_signin_completed)
		_gamecenter.signin_fail.connect(_on_signin_failed)
		status_label.text = "Plugin loaded"
	else:
		status_label.text = "No plugin"


func _on_connect_button_pressed() -> void:
	_gamecenter.authenticate()


func _on_signin_failed(error: String) -> void:
	status_label.text = error


func _on_signin_completed(player: Variant) -> void:
	status_label.text = "Signin success"
	print(player)
