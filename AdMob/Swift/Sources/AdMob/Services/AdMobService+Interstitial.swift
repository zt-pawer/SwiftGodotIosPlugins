import Foundation
#if canImport(UIKit)
import UIKit
import GoogleMobileAds
#endif

extension AdMobService {
    public func loadInterstitial(adUnitID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        #if canImport(UIKit)
        DispatchQueue.main.async {
            GADInterstitialAd.load(withAdUnitID: adUnitID, request: GADRequest()) { [weak self] ad, error in
                guard let self = self else { return }
                if let error = error {
                    completion(.failure(error))
                    return
                }
                self.interstitialAd = ad
                self.interstitialAd?.fullScreenContentDelegate = self
                completion(.success(()))
            }
        }
        #else
        completion(.failure(NSError(domain: "AdMobService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Not supported on this platform."])))
        #endif
    }
    
    public func showInterstitial(completion: @escaping (Result<Void, Error>) -> Void) {
        #if canImport(UIKit)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let ad = self.interstitialAd else {
                completion(.failure(NSError(domain: "AdMobService", code: -3, userInfo: [NSLocalizedDescriptionKey: "No interstitial ad loaded."])))
                return
            }
            guard let root = self.rootViewController else {
                completion(.failure(NSError(domain: "AdMobService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No root view controller found."])))
                return
            }
            self.interstitialDismissCompletion = completion
            ad.present(fromRootViewController: root)
        }
        #else
        completion(.failure(NSError(domain: "AdMobService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Not supported on this platform."])))
        #endif
    }
}
