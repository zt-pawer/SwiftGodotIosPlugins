extends Control

var _firebase: GodotFirebase
var _auth: GodotFirebaseAuth
var _app_check: GodotFirebaseAppCheck
var _apple_signin: Object

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
		_auth.linkSuccess.connect(_on_link_success)
		_auth.linkFailed.connect(_on_link_failed)
		
		# Connect App Check signals
		_app_check.tokenSuccess.connect(_on_app_check_token_success)
		_app_check.tokenFailed.connect(_on_app_check_token_failed)
		
		status_label.text = "Firebase GDExtension classes loaded successfully."
	else:
		status_label.text = "Error: Firebase GDExtension classes not found. Make sure the plugin is compiled."

	# Load Apple Sign-In if available
	if ClassDB.class_exists("AppleSignIn"):
		_apple_signin = ClassDB.instantiate("AppleSignIn")
		_apple_signin.signInSuccess.connect(_on_apple_sign_in_success)
		_apple_signin.signInFailed.connect(_on_apple_sign_in_failed)
		_apple_signin.signInCancelled.connect(_on_apple_sign_in_cancelled)

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
		status_label.text = "Configuring App Check (Debug/DeviceCheck)..."
		_app_check.configureAppCheck("devicecheck")
		status_label.text = "App Check (DeviceCheck) configured."

func _on_config_app_check_attest_pressed() -> void:
	if _app_check:
		status_label.text = "Configuring App Check (AppAttest)..."
		_app_check.configureAppCheck("appattest")

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

func _on_apple_auth_pressed() -> void:
	if _apple_signin:
		status_label.text = "Requesting Apple Sign-In..."
		_apple_signin.signIn()
	else:
		status_label.text = "AppleSignIn class is not registered/available."

func _on_game_center_auth_pressed() -> void:
	if _auth:
		if _auth.isUserSignedIn():
			status_label.text = "Linking Game Center account to Firebase..."
			_auth.linkWithGameCenter()
		else:
			status_label.text = "Signing in with Game Center..."
			_auth.signInWithGameCenter()

func _on_google_auth_pressed() -> void:
	if _auth:
		# Since there is no GoogleSignIn plugin yet, we demonstrate with mock tokens
		if _auth.isUserSignedIn():
			status_label.text = "Linking Google account (mock tokens)..."
			_auth.linkWithGoogle("mock_google_id_token", "mock_google_access_token")
		else:
			status_label.text = "Signing in with Google (mock tokens)..."
			_auth.signInWithGoogle("mock_google_id_token", "mock_google_access_token")

func _on_facebook_auth_pressed() -> void:
	if _auth:
		# Since there is no FacebookSignIn plugin yet, we demonstrate with a mock token
		if _auth.isUserSignedIn():
			status_label.text = "Linking Facebook account (mock token)..."
			_auth.linkWithFacebook("mock_facebook_access_token")
		else:
			status_label.text = "Signing in with Facebook (mock token)..."
			_auth.signInWithFacebook("mock_facebook_access_token")


# --- Signal Handlers ---

func _on_sign_in_success(uid: String) -> void:
	status_label.text = "Firebase Sign-in Success! UID: " + uid
	print("Auth: Sign-in Success. UID: ", uid)

func _on_sign_in_failed(error_message: String) -> void:
	status_label.text = "Firebase Sign-in Failed: " + error_message
	print("Auth: Sign-in Failed: ", error_message)

func _on_sign_out_success() -> void:
	status_label.text = "Firebase Sign-out Success!"
	print("Auth: Sign-out Success.")

func _on_sign_out_failed(error_message: String) -> void:
	status_label.text = "Firebase Sign-out Failed: " + error_message

func _on_link_success(uid: String) -> void:
	status_label.text = "Firebase Account Link Success! UID: " + uid
	print("Auth: Account Link Success. UID: ", uid)

func _on_link_failed(error_message: String) -> void:
	status_label.text = "Firebase Account Link Failed: " + error_message
	print("Auth: Account Link Failed: ", error_message)

# --- Apple Sign-In Plugin Signal Handlers ---

func _on_apple_sign_in_success(identity_token: String, _auth_code: String, _user_id: String, _email: String, _name: String) -> void:
	if _auth:
		if _auth.isUserSignedIn():
			status_label.text = "Apple credential acquired. Linking account..."
			_auth.linkWithApple(identity_token, "")
		else:
			status_label.text = "Apple credential acquired. Signing in..."
			_auth.signInWithApple(identity_token, "")

func _on_apple_sign_in_failed(error_code: int, error_message: String) -> void:
	status_label.text = "Apple Sign-In Plugin Error (" + str(error_code) + "): " + error_message

func _on_apple_sign_in_cancelled() -> void:
	status_label.text = "Apple Sign-In cancelled by user."

# --- App Check Signal Handlers ---

func _on_app_check_token_success(token: String) -> void:
	status_label.text = "App Check Token Success! Token length: " + str(token.length())

func _on_app_check_token_failed(error_message: String) -> void:
	status_label.text = "App Check Token Failed: " + error_message
