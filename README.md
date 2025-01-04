# SwiftGodotIosPlugins

This is a Swift implementation using the [SwiftGodot](https://github.com/migueldeicaza/SwiftGodot/) framework of some the plugins for Godot.

[![Godot](https://img.shields.io/badge/Godot%20Engine-4.3-blue.svg)](https://github.com/godotengine/godot/)
[![SwiftGodot](https://img.shields.io/badge/SwiftGodot-main-blue.svg)](https://github.com/migueldeicaza/SwiftGodot/)
![Platforms](https://img.shields.io/badge/platforms-iOS-333333.svg?style=flat)
![iOS](https://img.shields.io/badge/iOS-17+-green.svg?style=flat)
[![Swift](https://img.shields.io/badge/Swift-5.9.1-blue.svg)](https://www.swift.org/)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg?maxAge=2592000)](https://github.com/zt-pawer/SwiftGodotGameCenter/blob/main/LICENSE)

## Benefits

There are few major benefits with this version of the plugins compared to the classical [godot-ios-plugins](https://github.com/godot-sdk-integrations/godot-ios-plugins) plugins:
- Completely written in Swift
- Leverage new Apple SDKs (no deprecated APIs)
- Conform to Godot signals 

# Supported Plugins

Currently, SwiftGodotIosPlugins implements the Ios **GameCenter**, **ICloud** and **InAppPurchase** integration.

Other iOS integrations (camera, arkit, apn, photo_picker) are under consideration.

# Supported Platforms

Currently, SwiftGodotIosPlugins can be used in projects targeting the iOS platforms. 
- **macOS** is not scope at the moment.
- **Android**, **Windows** and **Linux** N/A.


# Development Status

SwiftGodotIosPlugins is built on the GDExtension framework, which is still in an [experimental](https://docs.godotengine.org/en/stable/tutorials/scripting/gdextension/what_is_gdextension.html#differences-between-gdextension-and-c-modules) state, and consequently SwiftGodotIosPlugins is still in an experimental state. **Any use on production application is at your own risk.**

# How to use it

Register the signals as indicated for each plugin and implement the methods that you need to handle. A demo application is provided for each of the plugin.

# Technical details
- [GameCenter](GameCenter/README.md)
- [ICloud](ICloud/README.md)
- [InAppPurchase](InAppPurchase/README.md)

# Contributing

Have a bug fix or feature request you'd like to see added? Consider contributing! See the issue list for help requests.

[How to contribute](https://docs.github.com/en/get-started/exploring-projects-on-github/contributing-to-a-project)

# Donate and support

[![Buy me a coffee](.github/bmc-button.png)](https://buymeacoffee.com/ztpawer)

[![Become a patreon](.github/patreon-button.png)](https://patreon.com/ztpawer)

# Games using it
[![Pang in Time](https://www.ztpawer.com/wp-content/uploads/2025/01/pit.webp|width=100px)](https://apps.apple.com/us/app/pang-in-time/id6499503406)

[![Jupiter Escape](https://www.ztpawer.com/wp-content/uploads/2025/01/je.webp|width=100px)](https://apps.apple.com/us/app/jupiter-escape/id6476010007)
