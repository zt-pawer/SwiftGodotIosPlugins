extends Node

var _admob: Object # Using Object type since AdMob is registered dynamically from GDExtension

@onready var status_label: Label = $VBoxContainer/StatusLabel
@onready var consent_status: Label = $VBoxContainer/ConsentStatus
@onready var banner_status: Label = $VBoxContainer/BannerStatus
@onready var interstitial_status: Label = $VBoxContainer/InterstitialStatus
@onready var rewarded_status: Label = $VBoxContainer/RewardedStatus

@onready var show_banner_btn: Button = $VBoxContainer/HBoxBanner/ShowBanner
@onready var show_interstitial_btn: Button = $VBoxContainer/HBoxInterstitial/ShowInterstitial
@onready var show_rewarded_btn: Button = $VBoxContainer/HBoxRewarded/ShowRewarded

# Test Ad Unit IDs provided by Google AdMob
const BANNER_AD_UNIT_ID = "ca-app-pub-3940256099942544/2934735716"
const INTERSTITIAL_AD_UNIT_ID = "ca-app-pub-3940256099942544/4411468910"
const REWARDED_AD_UNIT_ID = "ca-app-pub-3940256099942544/1712485313"

func _ready() -> void:
	# Disable show buttons by default until confirming they are loaded
	show_banner_btn.disabled = true
	show_interstitial_btn.disabled = true
	show_rewarded_btn.disabled = true

	if ClassDB.class_exists("AdMob"):
		_admob = ClassDB.instantiate("AdMob")
		
		# Connect Consent signals
		_admob.connect("consent_info_updated", _on_consent_info_updated)
		_admob.connect("consent_info_failed", _on_consent_info_failed)
		_admob.connect("consent_form_presented", _on_consent_form_presented)
		_admob.connect("consent_form_failed", _on_consent_form_failed)
		
		# Connect Banner signals
		_admob.connect("banner_loaded", _on_banner_loaded)
		_admob.connect("banner_failed", _on_banner_failed)
		
		# Connect Interstitial signals
		_admob.connect("interstitial_loaded", _on_interstitial_loaded)
		_admob.connect("interstitial_failed", _on_interstitial_failed)
		_admob.connect("interstitial_closed", _on_interstitial_closed)
		
		# Connect Rewarded signals
		_admob.connect("rewarded_loaded", _on_rewarded_loaded)
		_admob.connect("rewarded_failed", _on_rewarded_failed)
		_admob.connect("rewarded_user", _on_rewarded_user)
		_admob.connect("rewarded_closed", _on_rewarded_closed)
		
		_admob.setTestDeviceIDs(PackedStringArray(["375D24F7-0F1E-49EF-B9FD-F27781E0FD0C", "810daa634a87353ef83162cd8beb8833"]))
		_admob.initialize()
		status_label.text = "AdMob Initialized"
	else:
		status_label.text = "AdMob plugin not found (iOS/macOS only)"
		printerr("AdMob Class not found")

# Consent callbacks
func _on_consent_info_updated() -> void:
	consent_status.text = "Consent Info Updated. Can Request Ads: " + str(_admob.canRequestAds())

func _on_consent_info_failed(error_message: String) -> void:
	consent_status.text = "Consent Info Failed: " + error_message

func _on_consent_form_presented() -> void:
	consent_status.text = "Consent Form Finished. Can Request Ads: " + str(_admob.canRequestAds())

func _on_consent_form_failed(error_message: String) -> void:
	consent_status.text = "Consent Form Failed: " + error_message

# Banner callbacks
func _on_banner_loaded() -> void:
	banner_status.text = "Banner: Loaded"
	show_banner_btn.disabled = false

func _on_banner_failed(error_message: String) -> void:
	banner_status.text = "Banner Failed: " + error_message
	show_banner_btn.disabled = true

# Interstitial callbacks
func _on_interstitial_loaded() -> void:
	interstitial_status.text = "Interstitial: Loaded"
	show_interstitial_btn.disabled = false

func _on_interstitial_failed(error_message: String) -> void:
	interstitial_status.text = "Interstitial Failed: " + error_message
	show_interstitial_btn.disabled = true

func _on_interstitial_closed() -> void:
	interstitial_status.text = "Interstitial: Closed"
	show_interstitial_btn.disabled = true

# Rewarded callbacks
func _on_rewarded_loaded() -> void:
	rewarded_status.text = "Rewarded: Loaded"
	show_rewarded_btn.disabled = false

func _on_rewarded_failed(error_message: String) -> void:
	rewarded_status.text = "Rewarded Failed: " + error_message
	show_rewarded_btn.disabled = true

func _on_rewarded_user(reward_type: String, reward_amount: int) -> void:
	rewarded_status.text = "Rewarded user: %d %s" % [reward_amount, reward_type]

func _on_rewarded_closed() -> void:
	rewarded_status.text = "Rewarded: Closed"
	show_rewarded_btn.disabled = true

# Button actions
func _on_request_consent_pressed() -> void:
	if _admob:
		consent_status.text = "Requesting Consent..."
		_admob.requestConsentInfoUpdate(false)

func _on_show_consent_form_pressed() -> void:
	if _admob:
		consent_status.text = "Loading Consent Form..."
		_admob.loadAndPresentConsentForm()

func _on_reset_consent_pressed() -> void:
	if _admob:
		_admob.resetConsent()
		consent_status.text = "Consent Reset"

func _on_load_banner_pressed() -> void:
	if _admob:
		banner_status.text = "Banner: Loading..."
		_admob.loadBanner(BANNER_AD_UNIT_ID, "bottom")

func _on_show_banner_pressed() -> void:
	if _admob:
		_admob.showBanner()

func _on_hide_banner_pressed() -> void:
	if _admob:
		_admob.hideBanner()

func _on_destroy_banner_pressed() -> void:
	if _admob:
		_admob.destroyBanner()
		banner_status.text = "Banner: Destroyed"

func _on_load_interstitial_pressed() -> void:
	if _admob:
		interstitial_status.text = "Interstitial: Loading..."
		_admob.loadInterstitial(INTERSTITIAL_AD_UNIT_ID)

func _on_show_interstitial_pressed() -> void:
	if _admob:
		_admob.showInterstitial()

func _on_load_rewarded_pressed() -> void:
	if _admob:
		rewarded_status.text = "Rewarded: Loading..."
		_admob.loadRewarded(REWARDED_AD_UNIT_ID)

func _on_show_rewarded_pressed() -> void:
	if _admob:
		_admob.showRewarded()
