//
//  AppleSignIn.swift
//  SwiftGodotIosPlugins
//
//  Apple Sign-In authentication plugin for Godot using SwiftGodot
//

import AuthenticationServices
import SwiftGodot

#initSwiftExtension(
    cdecl: "applesignin",
    types: [
        AppleSignIn.self,
    ]
)

enum AppleSignInError: Int, Error {
    case unknownError = 1
    case canceled = 2
    case invalidResponse = 3
    case notHandled = 4
    case failed = 5
    case notAvailable = 6
    case notInteractive = 7
}

@Godot
class AppleSignIn: Object {

    // MARK: - Signals

    /// Emitted when Apple Sign-In completes successfully
    /// Parameters: identityToken (String), authorizationCode (String), userIdentifier (String), email (String), fullName (String)
    @Signal var signInSuccess: SignalWithArguments<String, String, String, String, String>

    /// Emitted when Apple Sign-In fails
    /// Parameters: errorCode (Int), errorMessage (String)
    @Signal var signInFailed: SignalWithArguments<Int, String>

    /// Emitted when Apple Sign-In is cancelled by user
    @Signal var signInCancelled: SimpleSignal

    /// Emitted when credential state check completes
    /// Parameters: userIdentifier (String), isAuthorized (Bool)
    @Signal var credentialStateChecked: SignalWithArguments<String, Bool>

    // MARK: - Properties

    static var shared: AppleSignIn?
    private var service: AppleSignInServiceProtocol

    // MARK: - Initialization

    required init(_ context: InitContext) {
        let defaultService = AppleSignInService()
        self.service = defaultService
        super.init(context)
        
        setupCallbacks()
        AppleSignIn.shared = self
        GD.print("[AppleSignIn] Plugin initialized")
    }

    private func setupCallbacks() {
        service.onSignInSuccess = { [weak self] credential in
            guard let self = self else { return }
            self.signInSuccess.emit(
                credential.identityToken,
                credential.authorizationCode,
                credential.userIdentifier,
                credential.email,
                credential.fullName
            )
        }
        
        service.onSignInFailed = { [weak self] errorCode, errorMessage in
            guard let self = self else { return }
            self.signInFailed.emit(errorCode, errorMessage)
        }
        
        service.onSignInCancelled = { [weak self] in
            guard let self = self else { return }
            self.signInCancelled.emit()
        }
    }

    // MARK: - Public Methods

    /// Check if Apple Sign-In is available on this device
    /// Returns true if Apple Sign-In is available
    @Callable
    func isAvailable() -> Bool {
        let available = service.isAvailable()
        GD.print("[AppleSignIn] isAvailable() returning \(available)")
        return available
    }

    /// Start Apple Sign-In flow
    /// Requests full name and email scopes
    @Callable
    func signIn() {
        GD.print("[AppleSignIn] signIn() called")
        if !service.isAvailable() {
            signInFailed.emit(AppleSignInError.notAvailable.rawValue, "Apple Sign-In is not available on this platform")
            return
        }
        service.signIn(requestEmail: true, requestFullName: true)
    }

    /// Start Apple Sign-In flow with custom scopes
    @Callable
    func signInWithScopes(requestEmail: Bool, requestFullName: Bool) {
        GD.print("[AppleSignIn] signInWithScopes() called - email: \(requestEmail), fullName: \(requestFullName)")
        if !service.isAvailable() {
            signInFailed.emit(AppleSignInError.notAvailable.rawValue, "Apple Sign-In is not available on this platform")
            return
        }
        service.signIn(requestEmail: requestEmail, requestFullName: requestFullName)
    }

    /// Check the credential state for a user identifier
    @Callable
    func checkCredentialState(userIdentifier: String) {
        GD.print("[AppleSignIn] checkCredentialState() called for user: \(userIdentifier)")
        service.checkCredentialState(userIdentifier: userIdentifier) { [weak self] isAuthorized in
            guard let self = self else { return }
            self.credentialStateChecked.emit(userIdentifier, isAuthorized)
        }
    }
}
