extends Control

var _gamecenter: GameCenter
var _achievements: Dictionary = {}
var _achievementDescriptions: Dictionary = {}

@onready var status_label: Label = $VBoxContainer/StatusLabel

var score: int = 0
const leaderboardId = "leaderboard1"

func _ready() -> void:
	if _gamecenter == null && ClassDB.class_exists("GameCenter"):
		_gamecenter = ClassDB.instantiate("GameCenter")
		_gamecenter.signin_success.connect(_on_signin_success)
		_gamecenter.signin_fail.connect(_on_signin_fail)
		_gamecenter.achievements_description_success.connect(_on_achievements_description_success)
		_gamecenter.achievements_description_fail.connect(_on_achievements_description_fail)
		_gamecenter.achievements_report_success.connect(_on_achievements_report_success)
		_gamecenter.achievements_report_fail.connect(_on_achievements_report_fail)
		_gamecenter.achievements_load_success.connect(_on_achievements_load_success)
		_gamecenter.achievements_load_fail.connect(_on_achievements_load_fail)
		_gamecenter.achievements_reset_success.connect(_on_achievements_reset_success)
		_gamecenter.achievements_reset_fail.connect(_on_achievements_reset_fail)
		_gamecenter.leaderboard_score_success.connect(_on_leaderboard_score_success)
		_gamecenter.leaderboard_score_fail.connect(_on_leaderboard_score_fail)
		_gamecenter.leaderboard_success.connect(_on_leaderboard_success)
		_gamecenter.leaderboard_dismissed.connect(_on_leaderboard_dismissed)
		_gamecenter.leaderboard_fail.connect(_on_leaderboard_fail)
		status_label.text = "Plugin loaded"
	else:
		status_label.text = "No plugin"


func _on_signin_fail(error: int, message: String) -> void:
	status_label.text = message


func _on_signin_success(player: GameCenterPlayerLocal) -> void:
	status_label.text = "Signin success %s" % player.alias


func _on_achievements_description_fail(error: int, message: String) -> void:
	status_label.text = message


func _on_achievements_description_success(achievements: Array[GameCenterAchievementDescription]) -> void:
	status_label.text = "Achievement descriptions received"
	for achievement in achievements:
		status_label.text = "%s - %s - %s" % [achievement.identifier, achievement.title, achievement.unachievedDescription]
		_achievementDescriptions[achievement.identifier] = achievement


func _on_achievements_report_fail(error: int, message: String) -> void:
	status_label.text = message


func _on_achievements_report_success() -> void:
	status_label.text = "Achievements progresses reported"


func _on_achievements_load_fail(error: int, message: String) -> void:
	status_label.text = message


func _on_achievements_load_success(achievements: Array[GameCenterAchievement]) -> void:
	status_label.text = "Achievements received"
	for achievement in achievements:
		status_label.text = "%s - %s - %d" % [achievement.identifier, str(achievement.isCompleted), achievement.percentComplete]
		_achievements[achievement.identifier] = achievement


func _on_achievements_reset_fail(error: int, message: String) -> void:
	status_label.text = message


func _on_achievements_reset_success() -> void:
	status_label.text = "Achievements progresses reset"


func _on_leaderboard_score_fail(error: int, message: String) -> void:
	status_label.text = message


func _on_leaderboard_score_success() -> void:
	status_label.text = "Score %d reported" % score


func _on_leaderboard_fail(error: int, message: String) -> void:
	status_label.text = message


func _on_leaderboard_dismissed() -> void:
	status_label.text = "Leaderboard dismissed"


func _on_leaderboard_success() -> void:
	status_label.text = "Leaderboard shown"


func _on_connect_button_pressed() -> void:
	_gamecenter.authenticate()


func _on_achievement_list_button_pressed() -> void:
	_gamecenter.loadAchievementDescriptions()


func _on_achievement_progress_button_pressed() -> void:
	var achievements: Array[GameCenterAchievement] = []
	for achievementIdentifier in _achievementDescriptions:
		var achievement: GameCenterAchievement = GameCenterAchievement.new()
		achievement.identifier = achievementIdentifier
		achievement.percentComplete = 100.0
		achievement.showsCompletionBanner = true
		achievements.append(achievement)
	_gamecenter.reportAchievements(achievements)


func _on_achievement_load_button_pressed() -> void:
	_gamecenter.loadAchievements()


func _on_achievement_reset_button_pressed() -> void:
	_gamecenter.resetAchievements()


func _on_leaderboard_submit_button_pressed() -> void:
	score += 1
	var leaderboardIds : Array[String] = []
	leaderboardIds.append(leaderboardId)
	_gamecenter.submitScore(score, leaderboardIds, 0)


func _on_achievement_show_button_pressed() -> void:
	_gamecenter.showAchievements()


func _on_leaderboard_show_button_pressed() -> void:
	_gamecenter.showLeaderboards()
