import Foundation
#if canImport(UIKit)
import UIKit
import UserMessagingPlatform
#endif

extension AdMobService {
    public func requestConsentInfoUpdate(underAgeOfConsent: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        #if canImport(UIKit)
        let parameters = UMPRequestParameters()
        parameters.tagForUnderAgeOfConsent = underAgeOfConsent
        
        if !testDeviceIDs.isEmpty {
            let debugSettings = UMPDebugSettings()
            debugSettings.testDeviceIdentifiers = testDeviceIDs
            debugSettings.geography = .EEA // Force EEA geography to display the GDPR consent form during testing
            parameters.debugSettings = debugSettings
        }
        
        UMPConsentInformation.sharedInstance.requestConsentInfoUpdate(with: parameters) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
        #else
        completion(.failure(NSError(domain: "AdMobService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Not supported on this platform."])))
        #endif
    }
    
    public func loadAndPresentConsentForm(completion: @escaping (Result<Void, Error>) -> Void) {
        #if canImport(UIKit)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let root = self.rootViewController else {
                completion(.failure(NSError(domain: "AdMobService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No root view controller found."])))
                return
            }
            
            UMPConsentForm.loadAndPresentIfRequired(from: root) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
        #else
        completion(.failure(NSError(domain: "AdMobService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Not supported on this platform."])))
        #endif
    }
}
