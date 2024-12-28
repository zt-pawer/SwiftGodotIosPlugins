# SwiftGodotGameCenter

This is a Swift implementation using the [SwiftGodot](https://github.com/migueldeicaza/SwiftGodot/) framework of the GameCenter plugin for Godot

[![Godot](https://img.shields.io/badge/Godot%20Engine-4.3-blue.svg)](https://github.com/godotengine/godot/)

# Supported Platforms

Currently, SwiftGodotGameCenter can be used in projects targeting the iOS platforms. 
macOS is in scope, but not a priority.

# Development Status

SwiftGodotGameCenter is built on the GDExtension framework, which is still in an [experimental](https://docs.godotengine.org/en/stable/tutorials/scripting/gdextension/what_is_gdextension.html#differences-between-gdextension-and-c-modules) state, and consequently SwiftGodotGameCenter is still in an experimental state. Compatibility may break in order to fix major bugs or include critical features.

# Technical details

## Signal
### Authorization
`signin_success` SignalWithArguments<GameCenterPlayerLocal>
`signin_fail` SignalWithArguments<Int,String>
### Achievements
`achievements_description_success` SignalWithArguments<[GameCenterAchievementDescription]>
`achievements_description_fail` SignalWithArguments<Int,String>
`achievements_report_success` SimpleSignal
`achievements_report_fail` SignalWithArguments<Int,String>
`achievements_reset_success` SimpleSignal
`achievements_reset_fail` SignalWithArguments<Int,String>
## Methods

### Authorization
`authenticate()` - Performs user authentication.  
`is_authenticated()` - Returns authentication state.  
### Achievements
`loadAchievementaDescription()` - Load all achievement descriptions.
`reportAchievements()` - Report an array of achievements to the server.
`resetAchievements()` - Reset the achievements progress for the local player.