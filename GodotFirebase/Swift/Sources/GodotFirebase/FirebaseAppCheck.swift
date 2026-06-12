import Foundation
import SwiftGodot

@Godot
class GodotFirebaseAppCheck: RefCounted {
    /// @Signal
    /// Emitted when an App Check token is successfully retrieved.
    @Signal var tokenSuccess: SignalWithArguments<String>
    
    /// @Signal
    /// Emitted when App Check fails to retrieve a token, passing the error description.
    @Signal var tokenFailed: SignalWithArguments<String>

    private let service = FirebaseAppCheckService()

    /// @Callable
    /// Configures the App Check provider factory. Call this BEFORE configure().
    /// Supported provider types: "debug", "devicecheck", "appattest".
    @Callable
    func configureAppCheck(providerType: String) {
        service.configureAppCheck(providerType: providerType)
    }

    /// @Callable
    /// Requests the current App Check token, optionally forcing a refresh.
    @Callable
    func getAppCheckToken(forceRefresh: Bool) {
        service.getAppCheckToken(forceRefresh: forceRefresh) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let token):
                    self.tokenSuccess.emit(token)
                case .failure(let error):
                    self.tokenFailed.emit(error.localizedDescription)
                }
            }
        }
    }
}
