[![Godot](https://img.shields.io/badge/Godot%20Engine-4.6-blue.svg)](https://github.com/godotengine/godot/)
[![SwiftGodot](https://img.shields.io/badge/SwiftGodot-main-blue.svg)](https://github.com/migueldeicaza/SwiftGodot/)
![Platforms](https://img.shields.io/badge/platforms-iOS-333333.svg?style=flat)
![iOS](https://img.shields.io/badge/iOS-17+-green.svg?style=flat)

# Development status
GDExtension plugin for Google Mobile Ads (AdMob) on iOS. This plugin is built with SwiftGodot and supports Banners (with Auto Layout safe area constraints), Interstitial ads, Rewarded ads, and UMP Consent Forms (GDPR compliance).

# How to use it
Register all required signals in your `_ready()` method and connect them.

```gdscript
extends Node

var _admob: AdMob

func _ready() -> void:
	if ClassDB.class_exists("AdMob"):
		_admob = ClassDB.instantiate("AdMob")
		
		# Connect Consent signals
		_admob.consentInfoUpdated.connect(_on_consent_info_updated)
		_admob.consentInfoFailed.connect(_on_consent_info_failed)
		_admob.consentFormPresented.connect(_on_consent_form_presented)
		_admob.consentFormFailed.connect(_on_consent_form_failed)
		
		# Connect Banner signals
		_admob.bannerLoaded.connect(_on_banner_loaded)
		_admob.bannerFailed.connect(_on_banner_failed)
		
		# Connect Interstitial signals
		_admob.interstitialLoaded.connect(_on_interstitial_loaded)
		_admob.interstitialFailed.connect(_on_interstitial_failed)
		_admob.interstitialClosed.connect(_on_interstitial_closed)
		
		# Connect Rewarded signals
		_admob.rewardedLoaded.connect(_on_rewarded_loaded)
		_admob.rewardedFailed.connect(_on_rewarded_failed)
		_admob.rewardedUser.connect(_on_rewarded_user)
		_admob.rewardedClosed.connect(_on_rewarded_closed)
		
		# 1. Request consent status
		_admob.requestConsentInfoUpdate(false)
```

The Godot method signatures required:

```gdscript
# Consent callbacks
func _on_consent_info_updated() -> void:
	print("Consent info updated. Can request ads: ", _admob.canRequestAds())
	if _admob.canRequestAds():
		_admob.initialize()
	else:
		# Present consent form to user
		_admob.loadAndPresentConsentForm()

func _on_consent_info_failed(error_message: String) -> void:
	print("Consent update failed: ", error_message)
	# Fallback initialization
	_admob.initialize()

func _on_consent_form_presented() -> void:
	print("Consent form finished. Can request ads: ", _admob.canRequestAds())
	if _admob.canRequestAds():
		_admob.initialize()

func _on_consent_form_failed(error_message: String) -> void:
	print("Consent form presenting failed: ", error_message)
	# Fallback initialization
	_admob.initialize()

# Banner callbacks
func _on_banner_loaded() -> void:
	print("Banner loaded!")

func _on_banner_failed(error_message: String) -> void:
	print("Banner failed to load: ", error_message)

# Interstitial callbacks
func _on_interstitial_loaded() -> void:
	print("Interstitial loaded, showing now...")
	_admob.showInterstitial()

func _on_interstitial_failed(error_message: String) -> void:
	print("Interstitial failed to load: ", error_message)

func _on_interstitial_closed() -> void:
	print("Interstitial ad dismissed.")

# Rewarded callbacks
func _on_rewarded_loaded() -> void:
	print("Rewarded ad loaded, showing now...")
	_admob.showRewarded()

func _on_rewarded_failed(error_message: String) -> void:
	print("Rewarded ad failed to load: ", error_message)

func _on_rewarded_user(reward_type: String, reward_amount: int) -> void:
	print("User rewarded: ", reward_amount, " of ", reward_type)

func _on_rewarded_closed() -> void:
	print("Rewarded ad dismissed.")
```

---

# Technical details

## AdMob Interface (`AdMob`)

### Signals
- `consentInfoUpdated()` - Emitted when consent information is updated successfully.
- `consentInfoFailed(error_message: String)` - Emitted when consent information update fails.
- `consentFormPresented()` - Emitted when a consent form is successfully loaded and presented.
- `consentFormFailed(error_message: String)` - Emitted when loading/presenting a consent form fails.
- `bannerLoaded()` - Emitted when a banner ad is successfully loaded.
- `bannerFailed(error_message: String)` - Emitted when a banner ad fails to load.
- `interstitialLoaded()` - Emitted when an interstitial ad is successfully loaded.
- `interstitialFailed(error_message: String)` - Emitted when an interstitial ad fails to load.
- `interstitialClosed()` - Emitted when an interstitial ad is dismissed.
- `rewardedLoaded()` - Emitted when a rewarded ad is successfully loaded.
- `rewardedFailed(error_message: String)` - Emitted when a rewarded ad fails to load.
- `rewardedUser(reward_type: String, reward_amount: int)` - Emitted when a user completes watching a rewarded ad and should be rewarded.
- `rewardedClosed()` - Emitted when a rewarded ad is dismissed.

### Methods
- `initialize()` - Initializes the Google Mobile Ads SDK.
- `requestConsentInfoUpdate(underAgeOfConsent: bool)` - Requests user consent information status. Set `underAgeOfConsent` to `true` to request consent under the COPPA/GDPR child protection terms.
- `loadAndPresentConsentForm()` - Loads and displays the UMP consent form if needed.
- `canRequestAds() -> bool` - Returns `true` if consent information allows requesting ads.
- `resetConsent()` - Resets consent status (useful for testing).
- `loadBanner(adUnitID: String, position: String)` - Loads a banner ad. `position` can be `"top"` or `"bottom"`. It anchors the banner using iOS Safe Area constraints.
- `showBanner()` - Displays the loaded banner ad.
- `hideBanner()` - Hides the banner ad.
- `destroyBanner()` - Removes the banner ad from the view hierarchy and deallocates it.
- `loadInterstitial(adUnitID: String)` - Loads an interstitial ad.
- `showInterstitial()` - Presents the loaded interstitial ad from the root view controller.
- `loadRewarded(adUnitID: String)` - Loads a rewarded ad.
- `showRewarded()` - Presents the loaded rewarded ad from the root view controller.
