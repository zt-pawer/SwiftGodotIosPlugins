# SwiftGodotGameCenter

This is a Swift implementation using the [SwiftGodot](https://github.com/migueldeicaza/SwiftGodot/) framework of the GameCenter plugin for Godot

[![Godot](https://img.shields.io/badge/Godot%20Engine-4.3-blue.svg)](https://github.com/godotengine/godot/)
[![SwiftGodot](https://img.shields.io/badge/SwiftGodot-main-blue.svg)](https://github.com/migueldeicaza/SwiftGodot/)
![Platforms](https://img.shields.io/badge/platforms-iOS-333333.svg?style=flat)
[![Swift](https://img.shields.io/badge/Swift-5.9.1-blue.svg)](https://www.swift.org/)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg?maxAge=2592000)](https://github.com/zt-pawer/SwiftGodotGameCenter/blob/main/LICENSE)

# Supported Platforms

Currently, SwiftGodotGameCenter can be used in projects targeting the iOS platforms. 
macOS is in scope, but not a priority.

# Development Status

SwiftGodotGameCenter is built on the GDExtension framework, which is still in an [experimental](https://docs.godotengine.org/en/stable/tutorials/scripting/gdextension/what_is_gdextension.html#differences-between-gdextension-and-c-modules) state, and consequently SwiftGodotGameCenter is still in an experimental state. 
This plugin compatibility may break.

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

# Contributing

Have a bug fix or feature request you'd like to see added? Consider contributing!
[How to contribute](https://docs.github.com/en/get-started/exploring-projects-on-github/contributing-to-a-project)

# Donate and support

[![Become a patreon](https://github.com/zt-pawer/SwiftGodotGameCenter/blob/main/.github/Become-a-patron-button.png)](https://patreon.com/ztpawer)
