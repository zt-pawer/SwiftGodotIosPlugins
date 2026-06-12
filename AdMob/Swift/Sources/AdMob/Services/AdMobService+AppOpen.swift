import Foundation
#if canImport(UIKit)
import UIKit
import GoogleMobileAds
#endif

extension AdMobService {
    public func loadAppOpen(adUnitID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        #if canImport(UIKit)
        DispatchQueue.main.async {
            GADAppOpenAd.load(withAdUnitID: adUnitID, request: GADRequest()) { [weak self] ad, error in
                guard let self = self else { return }
                if let error = error {
                    completion(.failure(error))
                    return
                }
                self.appOpenAd = ad
                self.appOpenAd?.fullScreenContentDelegate = self
                completion(.success(()))
            }
        }
        #else
        completion(.failure(NSError(domain: "AdMobService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Not supported on this platform."])))
        #endif
    }
    
    public func showAppOpen(completion: @escaping (Result<Void, Error>) -> Void) {
        #if canImport(UIKit)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let ad = self.appOpenAd else {
                completion(.failure(NSError(domain: "AdMobService", code: -3, userInfo: [NSLocalizedDescriptionKey: "No app open ad loaded."])))
                return
            }
            guard let root = self.rootViewController else {
                completion(.failure(NSError(domain: "AdMobService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No root view controller found."])))
                return
            }
            self.appOpenDismissCompletion = completion
            ad.present(fromRootViewController: root)
        }
        #else
        completion(.failure(NSError(domain: "AdMobService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Not supported on this platform."])))
        #endif
    }
}
