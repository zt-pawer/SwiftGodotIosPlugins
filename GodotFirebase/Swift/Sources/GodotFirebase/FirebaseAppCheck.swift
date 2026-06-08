import Foundation
import FirebaseAppCheck
import SwiftGodot
#if os(iOS)
import DeviceCheck
#endif

@Godot
class GodotFirebaseAppCheck: RefCounted {
    /// @Signal
    /// Emitted when an App Check token is successfully retrieved.
    @Signal var tokenSuccess: SignalWithArguments<String>
    
    /// @Signal
    /// Emitted when App Check fails to retrieve a token, passing the error description.
    @Signal var tokenFailed: SignalWithArguments<String>

    /// @Callable
    /// Configures the App Check provider factory. Call this BEFORE configure().
    /// Supported provider types: "debug", "devicecheck", "appattest".
    @Callable
    func configureAppCheck(providerType: String) {
        #if os(iOS)
        var factory: AppCheckProviderFactory? = nil
        let type = providerType.lowercased()
        
        if type == "debug" {
            factory = AppCheckDebugProviderFactory()
        } else if type == "devicecheck" {
            factory = DeviceCheckProviderFactory()
        } else if type == "appattest" {
            #if !targetEnvironment(simulator)
            if let factoryClass = NSClassFromString("FIRAppAttestProviderFactory") as? NSObject.Type {
                factory = factoryClass.init() as? AppCheckProviderFactory
            }
            #endif
        }
        
        if let factory = factory {
            AppCheck.setAppCheckProviderFactory(factory)
        }
        #endif
    }

    /// @Callable
    /// Requests the current App Check token, optionally forcing a refresh.
    @Callable
    func getAppCheckToken(forceRefresh: Bool) {
        AppCheck.appCheck().token(forcingRefresh: forceRefresh) { token, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.tokenFailed.emit(error.localizedDescription)
                    return
                }
                if let token = token {
                    self.tokenSuccess.emit(token.token)
                } else {
                    self.tokenFailed.emit("Unknown App Check error.")
                }
            }
        }
    }
}
