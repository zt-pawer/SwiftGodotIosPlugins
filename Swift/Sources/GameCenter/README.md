[![Godot](https://img.shields.io/badge/Godot%20Engine-4.3-blue.svg)](https://github.com/godotengine/godot/)
[![SwiftGodot](https://img.shields.io/badge/SwiftGodot-main-blue.svg)](https://github.com/migueldeicaza/SwiftGodot/)
![Platforms](https://img.shields.io/badge/platforms-iOS-333333.svg?style=flat)
![iOS](https://img.shields.io/badge/iOS-17+-green.svg?style=flat)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg?maxAge=2592000)](https://github.com/zt-pawer/SwiftGodotGameCenter/blob/main/LICENSE)

# Development status
Initial effort focused on bringing this GDExtension implementation to parity with [Godot Gamecenter Ios Plugin](https://github.com/godot-sdk-integrations/godot-ios-plugins/tree/master/plugins/gamecenter).
More functionality may be added based on needs.

# How to use it
See Godot demo project for an end to end implementation.
Register all the signals required, this can be done in the ``_ready()`` method and connect each signal to the relative method.
``debugger`` signal might be removed anytime.

```
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
		_gamecenter.debugger.connect(_on_debugger)
```

The Godot method signature required

```
func _on_signin_fail(error: int, message: String) -> void:
func _on_signin_success(player: GameCenterPlayerLocal) -> void:
func _on_achievements_description_fail(error: int, message: String) -> void:
func _on_achievements_description_success(achievements: Array[GameCenterAchievementDescription]) -> void:
func _on_achievements_report_fail(error: int, message: String) -> void:
func _on_achievements_report_success() -> void:
func _on_achievements_load_fail(error: int, message: String) -> void:
func _on_achievements_load_success(achievements: Array[GameCenterAchievement]) -> void:
func _on_achievements_reset_fail(error: int, message: String) -> void:
func _on_achievements_reset_success() -> void:
func _on_leaderboard_score_fail(error: int, message: String) -> void:
func _on_leaderboard_dismissed() -> void:
func _on_leaderboard_success() -> void:
func _on_debugger(message:String) ->void:
```

# Technical details

## Signals
### Authorization
- `signin_success` SignalWithArguments<GameCenterPlayerLocal>
- `signin_fail` SignalWithArguments<Int,String>
### Achievements
- `achievements_description_success` SignalWithArguments<[GameCenterAchievementDescription]>
- `achievements_description_fail` SignalWithArguments<Int,String>
- `achievements_report_success` SimpleSignal
- `achievements_report_fail` SignalWithArguments<Int,String>
- `achievements_load_success` SignalWithArguments<[GameCenterAchievement]>
- `achievements_load_fail` SignalWithArguments<Int,String>
- `achievements_reset_success` SimpleSignal
- `achievements_reset_fail` SignalWithArguments<Int,String>
### Leaderboards
- `leaderboard_score_success` SimpleSignal
- `leaderboard_score_fail` SignalWithArguments<Int,String>
- `leaderboard_success` SimpleSignal
- `leaderboard_dismissed` SimpleSignal
- `leaderboard_fail` SignalWithArguments<Int,String>
## Methods

### Authorization
- `authenticate()` - Performs user authentication.  
- `is_authenticated()` - Returns authentication state.  
### Achievements
- `loadAchievementDescriptions()` - Load all achievement descriptions.
- `reportAchievements()` - Report an array of achievements.
- `loadAchievements()` - Update the progress of achievements.
- `resetAchievements()` - Reset the achievements progress for the local player.
- `showAchievements()` - Open GameCenter Achievements.
- `showAchievement()` - Open GameCenter Achievements.
### Leaderboards
- `submitScore()` - Update the progress of achievements.
- `showLeaderboards()` - Open GameCenter Leaderboards.
- `showLeaderboard()` - Open GameCenter Leaderboard.