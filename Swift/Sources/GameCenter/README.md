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
