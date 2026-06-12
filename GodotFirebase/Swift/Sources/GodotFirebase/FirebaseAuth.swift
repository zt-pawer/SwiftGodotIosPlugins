import Foundation
import SwiftGodot

@Godot
class GodotFirebaseAuth: RefCounted {
    /// @Signal
    /// Emitted on successful authentication, passing the user's UID.
    @Signal var signInSuccess: SignalWithArguments<String>
    
    /// @Signal
    /// Emitted when authentication fails, passing the error description.
    @Signal var signInFailed: SignalWithArguments<String>
    
    /// @Signal
    /// Emitted on successful sign out.
    @Signal var signOutSuccess: SimpleSignal
    
    /// @Signal
    /// Emitted when sign out fails, passing the error description.
    @Signal var signOutFailed: SignalWithArguments<String>
    
    /// @Signal
    /// Emitted when a platform account (Apple, Google, Facebook, Game Center) is successfully linked to the active profile.
    @Signal var linkSuccess: SignalWithArguments<String>
    
    /// @Signal
    /// Emitted when linking a platform account fails.
    @Signal var linkFailed: SignalWithArguments<String>

    private let service = FirebaseAuthService()

    /// @Callable
    /// Signs in the user anonymously.
    @Callable
    func signInAnonymously() {
        service.signInAnonymously { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let uid):
                    self.signInSuccess.emit(uid)
                case .failure(let error):
                    self.signInFailed.emit(error.localizedDescription)
                }
            }
        }
    }

    /// @Callable
    /// Signs out the currently signed-in user.
    @Callable
    func signOut() {
        service.signOut { [weak self] error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let error = error {
                    self.signOutFailed.emit(error.localizedDescription)
                } else {
                    self.signOutSuccess.emit()
                }
            }
        }
    }

    /// @Callable
    /// Returns true if a user is currently signed in.
    @Callable
    func isUserSignedIn() -> Bool {
        return service.isUserSignedIn()
    }

    /// @Callable
    /// Returns the current user's UID or an empty string if not signed in.
    @Callable
    func getCurrentUserUid() -> String {
        return service.getCurrentUserUid()
    }
    
    /// @Callable
    /// Authenticates with Firebase using Apple Sign-In credentials.
    @Callable
    func signInWithApple(idToken: String, rawNonce: String) {
        service.signInWithApple(idToken: idToken, rawNonce: rawNonce) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let uid):
                    self.signInSuccess.emit(uid)
                case .failure(let error):
                    self.signInFailed.emit(error.localizedDescription)
                }
            }
        }
    }
    
    /// @Callable
    /// Links Apple Sign-In credentials to the currently signed-in Firebase user.
    @Callable
    func linkWithApple(idToken: String, rawNonce: String) {
        service.linkWithApple(idToken: idToken, rawNonce: rawNonce) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let uid):
                    self.linkSuccess.emit(uid)
                case .failure(let error):
                    self.linkFailed.emit(error.localizedDescription)
                }
            }
        }
    }
    
    /// @Callable
    /// Authenticates with Firebase using Google Sign-In credentials.
    @Callable
    func signInWithGoogle(idToken: String, accessToken: String) {
        service.signInWithGoogle(idToken: idToken, accessToken: accessToken) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let uid):
                    self.signInSuccess.emit(uid)
                case .failure(let error):
                    self.signInFailed.emit(error.localizedDescription)
                }
            }
        }
    }
    
    /// @Callable
    /// Links Google Sign-In credentials to the currently signed-in Firebase user.
    @Callable
    func linkWithGoogle(idToken: String, accessToken: String) {
        service.linkWithGoogle(idToken: idToken, accessToken: accessToken) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let uid):
                    self.linkSuccess.emit(uid)
                case .failure(let error):
                    self.linkFailed.emit(error.localizedDescription)
                }
            }
        }
    }
    
    /// @Callable
    /// Authenticates with Firebase using Facebook Sign-In credentials.
    @Callable
    func signInWithFacebook(accessToken: String) {
        service.signInWithFacebook(accessToken: accessToken) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let uid):
                    self.signInSuccess.emit(uid)
                case .failure(let error):
                    self.signInFailed.emit(error.localizedDescription)
                }
            }
        }
    }
    
    /// @Callable
    /// Links Facebook Sign-In credentials to the currently signed-in Firebase user.
    @Callable
    func linkWithFacebook(accessToken: String) {
        service.linkWithFacebook(accessToken: accessToken) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let uid):
                    self.linkSuccess.emit(uid)
                case .failure(let error):
                    self.linkFailed.emit(error.localizedDescription)
                }
            }
        }
    }
    
    /// @Callable
    /// Authenticates with Firebase using Game Center credentials.
    @Callable
    func signInWithGameCenter() {
        service.signInWithGameCenter { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let uid):
                    self.signInSuccess.emit(uid)
                case .failure(let error):
                    self.signInFailed.emit(error.localizedDescription)
                }
            }
        }
    }
    
    /// @Callable
    /// Links Game Center credentials to the currently signed-in Firebase user.
    @Callable
    func linkWithGameCenter() {
        service.linkWithGameCenter { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let uid):
                    self.linkSuccess.emit(uid)
                case .failure(let error):
                    self.linkFailed.emit(error.localizedDescription)
                }
            }
        }
    }
}
