extends Control

var _gamecenter: Variant
var _achievements: Dictionary = {}

@onready var status_label: Label = $VBoxContainer/StatusLabel


func _ready() -> void:
	if _gamecenter == null && ClassDB.class_exists("GameCenter"):
		_gamecenter = ClassDB.instantiate("GameCenter")
		_gamecenter.signin_success.connect(_on_signin_success)
		_gamecenter.signin_fail.connect(_on_signin_fail)
		_gamecenter.achievements_description_success.connect(on_achievements_description_success)
		_gamecenter.achievements_description_fail.connect(on_achievements_description_fail)
		_gamecenter.achievements_report_success.connect(on_achievements_report_success)
		_gamecenter.achievements_report_fail.connect(on_achievements_report_fail)
		_gamecenter.achievements_reset_success.connect(on_achievements_reset_success)
		_gamecenter.achievements_reset_fail.connect(on_achievements_reset_fail)
		_gamecenter.debugger.connect(_on_debugger)
		status_label.text = "Plugin loaded"
	else:
		status_label.text = "No plugin"


func _on_signin_fail(error: int, message: String) -> void:
	status_label.text = message


func _on_signin_success(player: GameCenterPlayerLocal) -> void:
	status_label.text = "Signin success %s" % player.alias


func on_achievements_description_fail(error: int, message: String) -> void:
	status_label.text = message


func on_achievements_description_success(achievements: Array[GameCenterAchievementDescription]) -> void:
	status_label.text = "Achievements received"
	for achievement in achievements:
		status_label.text = "%s - %s - %s" % [achievement.identifier, achievement.title, achievement.unachievedDescription]
		_achievements[achievement.identifier] = achievement


func on_achievements_report_fail(error: int, message: String) -> void:
	status_label.text = message


func on_achievements_report_success() -> void:
	status_label.text = "Achievements progresses reported"


func on_achievements_reset_fail(error: int, message: String) -> void:
	status_label.text = message


func on_achievements_reset_success() -> void:
	status_label.text = "Achievements progresses reset"


func _on_connect_button_pressed() -> void:
	_gamecenter.authenticate()


func _on_achievement_list_button_pressed() -> void:
	_gamecenter.loadAchievementaDescription()


func _on_achievement_progress_button_pressed() -> void:
	var achievements: Array[GameCenterAchievement] = []
	for achievementIdentifier in _achievements:
		var achievement: GameCenterAchievement = GameCenterAchievement.new()
		achievement.identifier = achievementIdentifier
		achievement.percentComplete = 100.0
		achievement.showsCompletionBanner = true
		achievements.append(achievement)
#
	_gamecenter.reportAchievements(achievements)


func _on_achievement_reset_button_pressed() -> void:
	_gamecenter.resetAchievements()


func _on_debugger(message:String) ->void:
	print("[SwiftDebugger] %s" % message)
