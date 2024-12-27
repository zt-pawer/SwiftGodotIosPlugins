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
`signin_success` SignalWithArguments<GameCenterPlayerLocal>
`signin_fail` SignalWithArguments<String>

## Methods

### Authorization

`authenticate()` - Performs user authentication.  
`is_authenticated()` - Returns authentication state.  
