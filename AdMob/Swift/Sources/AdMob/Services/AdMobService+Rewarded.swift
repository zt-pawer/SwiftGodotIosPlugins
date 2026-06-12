import Foundation
#if canImport(UIKit)
import UIKit
import GoogleMobileAds
#endif

extension AdMobService {
    public func loadRewarded(adUnitID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        #if canImport(UIKit)
        DispatchQueue.main.async {
            GADRewardedAd.load(withAdUnitID: adUnitID, request: GADRequest()) { [weak self] ad, error in
                guard let self = self else { return }
                if let error = error {
                    completion(.failure(error))
                    return
                }
                self.rewardedAd = ad
                self.rewardedAd?.fullScreenContentDelegate = self
                completion(.success(()))
            }
        }
        #else
        completion(.failure(NSError(domain: "AdMobService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Not supported on this platform."])))
        #endif
    }
    
    public func showRewarded(completion: @escaping (Result<(String, Int), Error>) -> Void) {
        #if canImport(UIKit)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let ad = self.rewardedAd else {
                completion(.failure(NSError(domain: "AdMobService", code: -3, userInfo: [NSLocalizedDescriptionKey: "No rewarded ad loaded."])))
                return
            }
            guard let root = self.rootViewController else {
                completion(.failure(NSError(domain: "AdMobService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No root view controller found."])))
                return
            }
            
            self.rewardedShowCompletion = completion
            self.rewardedDismissCompletion = self.onRewardedDismissed
            
            ad.present(fromRootViewController: root) {
                let reward = ad.adReward
                completion(.success((reward.type, Int(truncating: reward.amount))))
            }
        }
        #else
        completion(.failure(NSError(domain: "AdMobService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Not supported on this platform."])))
        #endif
    }
    
    public func loadRewardedInterstitial(adUnitID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        #if canImport(UIKit)
        DispatchQueue.main.async {
            GADRewardedInterstitialAd.load(withAdUnitID: adUnitID, request: GADRequest()) { [weak self] ad, error in
                guard let self = self else { return }
                if let error = error {
                    completion(.failure(error))
                    return
                }
                self.rewardedInterstitialAd = ad
                self.rewardedInterstitialAd?.fullScreenContentDelegate = self
                completion(.success(()))
            }
        }
        #else
        completion(.failure(NSError(domain: "AdMobService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Not supported on this platform."])))
        #endif
    }
    
    public func showRewardedInterstitial(completion: @escaping (Result<(String, Int), Error>) -> Void) {
        #if canImport(UIKit)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let ad = self.rewardedInterstitialAd else {
                completion(.failure(NSError(domain: "AdMobService", code: -3, userInfo: [NSLocalizedDescriptionKey: "No rewarded interstitial ad loaded."])))
                return
            }
            guard let root = self.rootViewController else {
                completion(.failure(NSError(domain: "AdMobService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No root view controller found."])))
                return
            }
            
            self.rewardedInterstitialShowCompletion = completion
            self.rewardedInterstitialDismissCompletion = self.onRewardedInterstitialDismissed
            
            ad.present(fromRootViewController: root) {
                let reward = ad.adReward
                completion(.success((reward.type, Int(truncating: reward.amount))))
            }
        }
        #else
        completion(.failure(NSError(domain: "AdMobService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Not supported on this platform."])))
        #endif
    }
}
