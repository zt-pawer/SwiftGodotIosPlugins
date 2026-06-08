import Foundation
import FirebaseAuth
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

    /// @Callable
    /// Signs in the user anonymously.
    @Callable
    func signInAnonymously() {
        Auth.auth().signInAnonymously { authResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.signInFailed.emit(error.localizedDescription)
                    return
                }
                if let user = authResult?.user {
                    self.signInSuccess.emit(user.uid)
                } else {
                    self.signInFailed.emit("Unknown authentication error.")
                }
            }
        }
    }

    /// @Callable
    /// Signs out the currently signed-in user.
    @Callable
    func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.signOutSuccess.emit()
            }
        } catch let error {
            DispatchQueue.main.async {
                self.signOutFailed.emit(error.localizedDescription)
            }
        }
    }

    /// @Callable
    /// Returns true if a user is currently signed in.
    @Callable
    func isUserSignedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }

    /// @Callable
    /// Returns the current user's UID or an empty string if not signed in.
    @Callable
    func getCurrentUserUid() -> String {
        return Auth.auth().currentUser?.uid ?? ""
    }
}
