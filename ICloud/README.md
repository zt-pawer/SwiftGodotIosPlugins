[![Godot](https://img.shields.io/badge/Godot%20Engine-4.3-blue.svg)](https://github.com/godotengine/godot/)
[![SwiftGodot](https://img.shields.io/badge/SwiftGodot-main-blue.svg)](https://github.com/migueldeicaza/SwiftGodot/)
![Platforms](https://img.shields.io/badge/platforms-iOS-333333.svg?style=flat)
![iOS](https://img.shields.io/badge/iOS-17+-green.svg?style=flat)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg?maxAge=2592000)](https://github.com/zt-pawer/SwiftGodotGameCenter/blob/main/LICENSE)

# Development status
Initial effort focused on bringing this GDExtension implementation to parity with [Godot iCloud Ios Plugin](https://github.com/godot-sdk-integrations/godot-ios-plugins/tree/master/plugins/icloud).
More functionality may be added based on needs.

# How to use it
See Godot demo project for an end to end implementation.
Register all the signals required, this can be done in the ``_ready()`` method and connect each signal to the relative method.

```
func _ready() -> void:
	if _icloud == null && ClassDB.class_exists("ICloud"):
		_icloud = ClassDB.instantiate("ICloud")
		_icloud.setAutoSync(true)
		_icloud.notification_change.connect(_on_notification_change)
```

The Godot method signature required

```
func _on_notification_change(code:int, keyValues:Dictionary) -> void:
```

# Technical details

## Signals
- `notification_change` SignalWithArguments<Int,Dictionary>

## Methods

- `setAutoSync()` - Set auto sync.
- `getAutoSync()` - Get auto sync.
- `synchronize()` - Synchronize.

- `setStringValue()` - Write a Godot string equivalent value to iCloud.
- `getStringValue()` - Read a Godot string equivalent value from iCloud.
- `setIntValue()` - Write a Godot in equivalent value to iCloud.
- `getIntValue()` - Read a Godot int equivalent value from iCloud.
- `setDoubleValue()` - Write a Godot float equivalent value to iCloud.
- `getDoubleValue()` - Read a Godot float equivalent value from iCloud.
- `setBoolValue()` - Write a Godot bool equivalent value to iCloud.
- `getBoolValue()` - Read a Godot bool equivalent value from iCloud.