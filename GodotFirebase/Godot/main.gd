extends Control

var _firebase: GodotFirebase
var _auth: GodotFirebaseAuth
var _app_check: GodotFirebaseAppCheck

@onready var status_label: Label = $VBoxContainer/StatusLabel

func _ready() -> void:
	# Check if the GDExtension classes exist and instantiate them
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
		
		status_label.text = "Firebase plugin classes successfully loaded."
	else:
		status_label.text = "Error: Firebase GDExtension classes not found. Make sure the plugin is compiled and loaded."

# --- Callbacks ---

func _on_configure_pressed() -> void:
	if _firebase:
		status_label.text = "Configuring Firebase..."
		_firebase.configure()
		if _firebase.isConfigured():
			status_label.text = "Firebase configured successfully!"
		else:
			status_label.text = "Firebase configuration failed."

func _on_check_configured_pressed() -> void:
	if _firebase:
		if _firebase.isConfigured():
			status_label.text = "Firebase is configured."
		else:
			status_label.text = "Firebase is NOT configured."

func _on_config_app_check_debug_pressed() -> void:
	if _app_check:
		status_label.text = "Configuring App Check (Debug)..."
		_app_check.configureAppCheck("debug")
		status_label.text = "App Check (Debug) configured. Remember to call this before Firebase configure."

func _on_config_app_check_device_pressed() -> void:
	if _app_check:
		status_label.text = "Configuring App Check (DeviceCheck)..."
		_app_check.configureAppCheck("devicecheck")
		status_label.text = "App Check (DeviceCheck) configured. Remember to call this before Firebase configure."

func _on_config_app_check_attest_pressed() -> void:
	if _app_check:
		status_label.text = "Configuring App Check (AppAttest)..."
		_app_check.configureAppCheck("appattest")
		status_label.text = "App Check (AppAttest) configured. Remember to call this before Firebase configure."

func _on_get_token_pressed() -> void:
	if _app_check:
		status_label.text = "Requesting App Check Token..."
		_app_check.getAppCheckToken(false)

func _on_get_token_force_pressed() -> void:
	if _app_check:
		status_label.text = "Force refreshing App Check Token..."
		_app_check.getAppCheckToken(true)

func _on_sign_in_pressed() -> void:
	if _auth:
		status_label.text = "Signing in anonymously..."
		_auth.signInAnonymously()

func _on_sign_out_pressed() -> void:
	if _auth:
		status_label.text = "Signing out..."
		_auth.signOut()

func _on_check_signed_in_pressed() -> void:
	if _auth:
		if _auth.isUserSignedIn():
			status_label.text = "Signed in. UID: " + _auth.getCurrentUserUid()
		else:
			status_label.text = "Not signed in."

# --- Signal Handlers ---

func _on_sign_in_success(uid: String) -> void:
	status_label.text = "Sign-in Success! UID: " + uid
	print("Auth: Sign-in Success. UID: ", uid)

func _on_sign_in_failed(error_message: String) -> void:
	status_label.text = "Sign-in Failed: " + error_message
	print("Auth: Sign-in Failed: ", error_message)

func _on_sign_out_success() -> void:
	status_label.text = "Sign-out Success!"
	print("Auth: Sign-out Success.")

func _on_sign_out_failed(error_message: String) -> void:
	status_label.text = "Sign-out Failed: " + error_message
	print("Auth: Sign-out Failed: ", error_message)

func _on_app_check_token_success(token: String) -> void:
	status_label.text = "App Check Token Success! Token length: " + str(token.length())
	print("AppCheck: Token Success. Token: ", token)

func _on_app_check_token_failed(error_message: String) -> void:
	status_label.text = "App Check Token Failed: " + error_message
	print("AppCheck: Token Failed: ", error_message)
