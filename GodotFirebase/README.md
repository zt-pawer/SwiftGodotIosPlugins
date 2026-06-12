[![Godot](https://img.shields.io/badge/Godot%20Engine-4.6-blue.svg)](https://github.com/godotengine/godot/)
[![SwiftGodot](https://img.shields.io/badge/SwiftGodot-main-blue.svg)](https://github.com/migueldeicaza/SwiftGodot/)
![Platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20macOS-333333.svg?style=flat)
![iOS](https://img.shields.io/badge/iOS-17+-green.svg?style=flat)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg?maxAge=2592000)](https://github.com/zt-pawer/SwiftGodotGameCenter/blob/main/LICENSE)

# Development status
Initial GDExtension plugin for Firebase Core, Authentication, and App Check. This plugin is built with SwiftGodot and supports both iOS and macOS (editor/type validation).

# How to use it
See the Godot demo project in `GodotFirebase/Godot` for a complete implementation.
Register all required signals in the `_ready()` method and connect them.

```gdscript
extends Node

var _firebase: GodotFirebase
var _auth: GodotFirebaseAuth
var _app_check: GodotFirebaseAppCheck

func _ready() -> void:
	if ClassDB.class_exists("GodotFirebase") and ClassDB.class_exists("GodotFirebaseAuth") and ClassDB.class_exists("GodotFirebaseAppCheck"):
		_firebase = ClassDB.instantiate("GodotFirebase")
		_auth = ClassDB.instantiate("GodotFirebaseAuth")
		_app_check = ClassDB.instantiate("GodotFirebaseAppCheck")
		
		# Connect Auth signals
		_auth.signInSuccess.connect(_on_sign_in_success)
		_auth.signInFailed.connect(_on_sign_in_failed)
		_auth.signOutSuccess.connect(_on_sign_out_success)
		_auth.signOutFailed.connect(_on_sign_out_failed)
		
		# Connect App Check signals
		_app_check.tokenSuccess.connect(_on_app_check_token_success)
		_app_check.tokenFailed.connect(_on_app_check_token_failed)
```

The Godot method signatures required:

```gdscript
func _on_sign_in_success(uid: String) -> void:
func _on_sign_in_failed(error_message: String) -> void:
func _on_sign_out_success() -> void:
func _on_sign_out_failed(error_message: String) -> void:
func _on_app_check_token_success(token: String) -> void:
func _on_app_check_token_failed(error_message: String) -> void:
```

---

# Technical details

## 1. Firebase Core (`GodotFirebase`)

### Methods
- `configure()` - Initializes the default Firebase application using settings from `GoogleService-Info.plist` located in the main bundle.
- `isConfigured()` -> `Bool` - Returns `true` if the default Firebase app is configured.

---

## 2. Firebase Auth (`GodotFirebaseAuth`)

### Signals
- `signInSuccess(uid: String)` - Emitted when sign-in succeeds (applies to both anonymous and federated sign-ins).
- `signInFailed(error_message: String)` - Emitted when sign-in fails.
- `signOutSuccess()` - Emitted when signing out succeeds.
- `signOutFailed(error_message: String)` - Emitted when signing out fails.
- `linkSuccess(uid: String)` - Emitted when a platform account is successfully linked/merged.
- `linkFailed(error_message: String)` - Emitted when account linking fails.

### Methods
- `signInAnonymously()` - Initiates anonymous user authentication.
- `signOut()` - Signs out the currently active user.
- `isUserSignedIn()` -> `Bool` - Returns `true` if a user is currently logged in.
- `getCurrentUserUid()` -> `String` - Returns the current user's UID or an empty string if not authenticated.
- `signInWithApple(idToken: String, rawNonce: String)` - Signs in using Apple credentials.
- `linkWithApple(idToken: String, rawNonce: String)` - Links Apple credentials to the active user profile.
- `signInWithGoogle(idToken: String, accessToken: String)` - Signs in using Google credentials.
- `linkWithGoogle(idToken: String, accessToken: String)` - Links Google credentials to the active user profile.
- `signInWithFacebook(accessToken: String)` - Signs in using Facebook credentials.
- `linkWithFacebook(accessToken: String)` - Links Facebook credentials to the active user profile.
- `signInWithGameCenter()` - Signs in using Game Center credentials (auto-retrieved from local player session).
- `linkWithGameCenter()` - Links Game Center credentials to the active user profile.


---

## 3. Firebase App Check (`GodotFirebaseAppCheck`)

### Signals
- `tokenSuccess(token: String)` - Emitted when App Check token is successfully retrieved.
- `tokenFailed(error_message: String)` - Emitted when App Check fails to fetch a token.

### Methods
- `configureAppCheck(providerType: String)` - Configures the App Check provider factory. Supported provider types: `"debug"`, `"devicecheck"`, and `"appattest"`. **Must be called BEFORE calling `GodotFirebase.configure()`**.
- `getAppCheckToken(forceRefresh: Bool)` - Requests the current App Check token, optionally forcing a refresh.
