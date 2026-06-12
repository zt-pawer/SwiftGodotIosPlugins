# SwiftGodotIosPlugins

This is a Swift implementation using the [SwiftGodot](https://github.com/migueldeicaza/SwiftGodot/) framework of some the plugins for Godot.

[![Godot](https://img.shields.io/badge/Godot%20Engine-4.6.3-blue.svg)](https://github.com/godotengine/godot/)
[![SwiftGodot](https://img.shields.io/badge/SwiftGodot-main-blue.svg)](https://github.com/migueldeicaza/SwiftGodot/)
![Platforms](https://img.shields.io/badge/platforms-iOS-333333.svg?style=flat)
![iOS](https://img.shields.io/badge/iOS-17+-green.svg?style=flat)
[![Swift](https://img.shields.io/badge/Swift-6.3-blue.svg)](https://www.swift.org/)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg?maxAge=2592000)](https://github.com/zt-pawer/SwiftGodotIosPlugins/blob/main/LICENSE)

## Benefits

There are few major benefits with this version of the plugins compared to the classical [godot-ios-plugins](https://github.com/godot-sdk-integrations/godot-ios-plugins) plugins:
- Completely written in Swift
- Leverage new Apple SDKs (no deprecated APIs)
- Conform to Godot signals
- No need to recompile if the Godot version changes

# Supported Plugins

Currently, SwiftGodotIosPlugins implements the iOS **AdMob**, **AppleSignIn**, **GameCenter**, **GodotFirebase** (Firebase Core, Anonymous Auth, App Check), **ICloud**, and **InAppPurchase** integrations.

Other iOS integrations (camera, arkit, apn, photo_picker) are under consideration.

# Supported Platforms

Currently, SwiftGodotIosPlugins can be used in projects targeting the iOS platforms. 
- **macOS** is supported where necessary for GDExtension type-parsing / design-time validation inside the Godot Editor.

# Development Status

SwiftGodotIosPlugins is built on the GDExtension framework, which is still in an [experimental](https://docs.godotengine.org/en/stable/tutorials/scripting/gdextension/what_is_gdextension.html#differences-between-gdextension-and-c-modules) state, and consequently SwiftGodotIosPlugins is still in an experimental state. **Any use on production application is at your own risk.**

# How to use it

Register the signals as indicated for each plugin and implement the methods that you need to handle. A demo application is provided for each of the plugins.
[YouTube tutorial](https://www.youtube.com/watch?v=RcisM4x9cTo)

# Technical details
- [AdMob](AdMob/README.md)
- [AppleSignIn](AppleSignIn/README.md)
- [GameCenter](GameCenter/README.md)
- [GodotFirebase](GodotFirebase/README.md)
- [ICloud](ICloud/README.md)
- [InAppPurchase](InAppPurchase/README.md)

# Architecture & Unit Testing

All plugins in this repository are designed with a **decoupled service architecture**. We separate the Godot engine bindings (`@Godot` wrappers) from the core business logic (pure Swift services):

```
+-----------------------------------+
|      Godot Engine (Runtime)       |
+-----------------+-----------------+
                  |
                  v (Signals / @Callable)
+-----------------+-----------------+
|   @Godot Wrapper Class (ICloud)   |
+-----------------+-----------------+
                  |
                  v (Delegates / Native Swift Types)
+-----------------+-----------------+
|  Pure Swift Service (ICloudService) |
+-----------------+-----------------+
                  |
                  v
       Apple Core SDKs / API
```

### Why this design?
SwiftGodot relies on a global GDExtension function pointer table (`gi`). Outside of a running Godot engine process, any call to instantiate a `@Godot` subclass or use Godot types (like `Variant`) crashes. By separating the logic into pure Swift services that deal only with native Swift types, we can:
1. Run local unit tests headlessly via `swift test` without crashing.
2. Mock Apple SDKs and live network environments during testing.
3. Test your game manager and UI logic in your game codebase by using mock interfaces.

### Mocking in Game Code
Every service implements a corresponding Protocol interface (e.g. `FirebaseAuthServiceProtocol`, `ICloudServiceProtocol`, etc.). Instead of hardcoding concrete services, your game client can depend on these protocols, allowing you to inject mock objects during game simulations or tests.


# Contributing

Have a bug fix or feature request you'd like to see added? Consider contributing! See the issue list for help requests.

[How to contribute](https://docs.github.com/en/get-started/exploring-projects-on-github/contributing-to-a-project)

# Donate and support

[![Buy me a coffee](.github/bmc-button.png)](https://buymeacoffee.com/ztpawer)

[![Become a patreon](.github/patreon-button.png)](https://patreon.com/ztpawer)

# Games using it
[![Pang in Time](.github/pit.webp)](https://apps.apple.com/us/app/pang-in-time/id6499503406)

[![Jupiter Escape](.github/je.webp)](https://apps.apple.com/us/app/jupiter-escape/id6476010007)
