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
}
