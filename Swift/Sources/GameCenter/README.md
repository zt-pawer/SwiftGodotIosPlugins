[![Godot](https://img.shields.io/badge/Godot%20Engine-4.3-blue.svg)](https://github.com/godotengine/godot/)
[![SwiftGodot](https://img.shields.io/badge/SwiftGodot-main-blue.svg)](https://github.com/migueldeicaza/SwiftGodot/)
![Platforms](https://img.shields.io/badge/platforms-iOS-333333.svg?style=flat)
![iOS](https://img.shields.io/badge/iOS-17+-green.svg?style=flat)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg?maxAge=2592000)](https://github.com/zt-pawer/SwiftGodotGameCenter/blob/main/LICENSE)

# Development status
[TODO]

# How to use it
[TODO]

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
- `achievements_reset_success` SimpleSignal
- `achievements_reset_fail` SignalWithArguments<Int,String>
## Methods

### Authorization
- `authenticate()` - Performs user authentication.  
- `is_authenticated()` - Returns authentication state.  
### Achievements
- `loadAchievementaDescription()` - Load all achievement descriptions.
- `reportAchievements()` - Report an array of achievements to the server.
- `resetAchievements()` - Reset the achievements progress for the local player.
