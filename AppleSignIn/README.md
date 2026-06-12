# Apple Sign-In Plugin for Godot (SwiftGodot)

A SwiftGodot plugin that enables Apple Sign-In authentication for iOS apps built with Godot Engine.

## Overview

This plugin provides native Apple Sign-In functionality using Apple's `AuthenticationServices` framework. It returns the identity token (JWT) needed for server-side authentication with backends like Nakama.

## Requirements

- iOS 17.0+
- macOS 14.0+ (for development/testing)
- Godot Engine 4.2+
- SwiftGodot
- Apple Developer account with Sign In with Apple capability

## Building the Plugin

### Prerequisites

1. Xcode 15+ installed
2. SwiftGodot dependency configured

### Build Commands

```bash
cd AppleSignIn/Swift

# Build for iOS
swift build -c release --arch arm64 --sdk iphoneos

# Build for macOS (for testing)
swift build -c release
```

### Create Framework

After building, create the framework structure for iOS:

```bash
# The build output will be in .build/release/
# Copy libAppleSignIn.dylib to the appropriate framework structure
```

## Installation in Godot Project

1. Copy `applesignin.gdextension` to `res://addons/iosplugins/`
2. Copy the built `AppleSignIn.framework` to `res://addons/iosplugins/ios/`
3. Ensure `SwiftGodot.framework` is also present in `res://addons/iosplugins/ios/`

## iOS Configuration (Required)

### 1. App Store Connect Configuration

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Navigate to your app > **App Information**
3. Under **Sign In with Apple**, click **Configure**
4. Enable **Sign In with Apple** for your app

### 2. Apple Developer Portal Configuration

1. Go to [Apple Developer Portal](https://developer.apple.com)
2. Navigate to **Certificates, Identifiers & Profiles**
3. Select **Identifiers** > Your App ID
4. Enable **Sign In with Apple** capability
5. Click **Configure** if server-to-server notifications are needed

### 3. Xcode Project Configuration

When exporting from Godot, the Xcode project needs:

1. **Signing & Capabilities**:
   - Add "Sign In with Apple" capability
   - Ensure proper provisioning profile with Sign In with Apple enabled

2. **Info.plist** (usually automatic with capability):
   ```xml
   <key>com.apple.developer.applesignin</key>
   <array>
       <string>Default</string>
   </array>
   ```

### 4. Nakama Backend Configuration

Nakama supports Apple Sign-In out of the box. The identity token returned by this plugin is a JWT that Nakama validates using Apple's public keys.

No additional backend configuration is needed - just call `authenticate_apple_async()` with the identity token.

## Usage in GDScript

```gdscript
var apple_plugin = null

func _ready():
    if Engine.has_singleton("AppleSignIn"):
        apple_plugin = Engine.get_singleton("AppleSignIn")

        # Connect signals
        apple_plugin.sign_in_success.connect(_on_apple_sign_in_success)
        apple_plugin.sign_in_failed.connect(_on_apple_sign_in_failed)
        apple_plugin.sign_in_cancelled.connect(_on_apple_sign_in_cancelled)

func _on_apple_button_pressed():
    if apple_plugin and apple_plugin.isAvailable():
        apple_plugin.signIn()

func _on_apple_sign_in_success(identity_token: String, auth_code: String, user_id: String, email: String, full_name: String):
    print("Apple Sign-In successful!")
    print("User ID: ", user_id)
    print("Email: ", email)  # May be empty on subsequent sign-ins
    print("Name: ", full_name)  # May be empty on subsequent sign-ins

    # Authenticate with Nakama using the identity token
    var session = await nakama_client.authenticate_apple_async(identity_token)

func _on_apple_sign_in_failed(error_code: int, message: String):
    print("Apple Sign-In failed: ", message)

func _on_apple_sign_in_cancelled():
    print("Apple Sign-In cancelled by user")
```

## API Reference

### Methods

#### `isAvailable() -> Bool`
Returns `true` if Apple Sign-In is available on the current device.

#### `signIn()`
Starts the Apple Sign-In flow requesting email and full name.

#### `signInWithScopes(requestEmail: Bool, requestFullName: Bool)`
Starts Apple Sign-In with custom scope options.

#### `checkCredentialState(userIdentifier: String)`
Verifies if the user's Apple ID credentials are still valid.

### Signals

#### `sign_in_success(identity_token, authorization_code, user_identifier, email, full_name)`
Emitted when authentication succeeds.

**Parameters:**
- `identity_token` (String): JWT for server authentication
- `authorization_code` (String): Code for server-to-server validation
- `user_identifier` (String): Unique Apple user ID
- `email` (String): User's email (only on first sign-in, empty otherwise)
- `full_name` (String): User's name (only on first sign-in, empty otherwise)

#### `sign_in_failed(error_code, error_message)`
Emitted when authentication fails.

**Error Codes:**
- `1`: Unknown error
- `2`: Canceled
- `3`: Invalid response
- `4`: Not handled
- `5`: Failed
- `6`: Not available
- `7`: Not interactive

#### `sign_in_cancelled`
Emitted when user cancels the authentication flow.

#### `credential_state_checked(user_identifier, is_authorized)`
Emitted when credential state check completes.

## Important Notes

### Email and Name Privacy

Apple only provides the user's email and name on the **first** sign-in. Subsequent sign-ins will return empty strings for these fields. Store these values after the first sign-in if needed.

### Testing

- Apple Sign-In requires a real iOS device for testing
- Cannot be tested in iOS Simulator
- Ensure test devices are signed in with an Apple ID

### App Store Review

Apps using Apple Sign-In must:
1. Provide Sign In with Apple as an option if offering other third-party sign-in options
2. Follow Apple's Human Interface Guidelines for the button design

## Troubleshooting

### "Sign In with Apple" not appearing

- Verify capability is enabled in Xcode
- Check provisioning profile has the capability
- Ensure App ID has Sign In with Apple enabled

### Invalid response error

- Verify your app's bundle ID matches the configured App ID
- Check that all certificates and profiles are valid

### Token validation fails on backend

- Ensure server time is synchronized
- Verify the bundle ID matches between app and backend configuration
