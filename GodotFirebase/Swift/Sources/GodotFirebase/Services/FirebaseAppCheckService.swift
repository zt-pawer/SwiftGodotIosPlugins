import Foundation
import FirebaseAppCheck
#if os(iOS)
import DeviceCheck
#endif

public final class FirebaseAppCheckService {
    public init() {}
    
    public func configureAppCheck(providerType: String) {
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
    
    public func getAppCheckToken(forceRefresh: Bool, completion: @escaping (Result<String, Error>) -> Void) {
        AppCheck.appCheck().token(forcingRefresh: forceRefresh) { token, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let token = token {
                completion(.success(token.token))
            } else {
                let unknownError = NSError(
                    domain: "FirebaseAppCheckService",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Unknown App Check error."]
                )
                completion(.failure(unknownError))
            }
        }
    }
}
