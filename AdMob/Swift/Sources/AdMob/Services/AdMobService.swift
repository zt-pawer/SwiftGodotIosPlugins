import Foundation

#if canImport(UIKit)
import UIKit
import GoogleMobileAds
import UserMessagingPlatform
#endif

public protocol AdMobServiceProtocol {
    func initialize()
    
    func loadBanner(adUnitID: String, position: String, completion: @escaping (Result<Void, Error>) -> Void)
    func showBanner()
    func hideBanner()
    func destroyBanner()
    
    func loadInterstitial(adUnitID: String, completion: @escaping (Result<Void, Error>) -> Void)
    func showInterstitial(completion: @escaping (Result<Void, Error>) -> Void)
    
    func loadRewarded(adUnitID: String, completion: @escaping (Result<Void, Error>) -> Void)
    func showRewarded(completion: @escaping (Result<(String, Int), Error>) -> Void)
    
    func loadAppOpen(adUnitID: String, completion: @escaping (Result<Void, Error>) -> Void)
    func showAppOpen(completion: @escaping (Result<Void, Error>) -> Void)
    
    func loadRewardedInterstitial(adUnitID: String, completion: @escaping (Result<Void, Error>) -> Void)
    func showRewardedInterstitial(completion: @escaping (Result<(String, Int), Error>) -> Void)
    
    func requestConsentInfoUpdate(underAgeOfConsent: Bool, completion: @escaping (Result<Void, Error>) -> Void)
    func loadAndPresentConsentForm(completion: @escaping (Result<Void, Error>) -> Void)
    func canRequestAds() -> Bool
    func resetConsent()
    
    func setTestDeviceIDs(_ ids: [String])
    func setChildDirectedTreatment(_ tag: Bool)
    func setMaxAdContentRating(_ rating: String)
    func setMuted(_ muted: Bool)
    
    var onBannerLoaded: (() -> Void)? { get set }
    var onBannerFailedToLoad: ((String) -> Void)? { get set }
    
    var onRewardedDismissed: (() -> Void)? { get set }
    var onRewardedInterstitialDismissed: (() -> Void)? { get set }
    var onAppOpenDismissed: (() -> Void)? { get set }
}

public final class AdMobService: NSObject, AdMobServiceProtocol {
    public var onBannerLoaded: (() -> Void)?
    public var onBannerFailedToLoad: ((String) -> Void)?
    public var onRewardedDismissed: (() -> Void)?
    public var onRewardedInterstitialDismissed: (() -> Void)?
    public var onAppOpenDismissed: (() -> Void)?
    
    var testDeviceIDs: [String] = []
    
    #if canImport(UIKit)
    var bannerView: GADBannerView?
    var bannerPosition: String = "bottom"
    var bannerLoadCompletion: ((Result<Void, Error>) -> Void)?
    
    var interstitialAd: GADInterstitialAd?
    var interstitialDismissCompletion: ((Result<Void, Error>) -> Void)?
    
    var rewardedAd: GADRewardedAd?
    var rewardedShowCompletion: ((Result<(String, Int), Error>) -> Void)?
    var rewardedDismissCompletion: (() -> Void)?
    
    var appOpenAd: GADAppOpenAd?
    var appOpenDismissCompletion: ((Result<Void, Error>) -> Void)?
    
    var rewardedInterstitialAd: GADRewardedInterstitialAd?
    var rewardedInterstitialShowCompletion: ((Result<(String, Int), Error>) -> Void)?
    var rewardedInterstitialDismissCompletion: (() -> Void)?
    
    var rootViewController: UIViewController? {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            return scene.windows.first(where: { $0.isKeyWindow })?.rootViewController ?? scene.windows.first?.rootViewController
        }
        return UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController ?? UIApplication.shared.windows.first?.rootViewController
    }
    
    var keyWindow: UIWindow? {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let window = scene.windows.first(where: { $0.isKeyWindow }) ?? scene.windows.first {
            return window
        }
        return UIApplication.shared.windows.first(where: { $0.isKeyWindow }) ?? UIApplication.shared.windows.first
    }
    #endif
    
    public override init() {
        super.init()
    }
    
    public func initialize() {
        #if canImport(UIKit)
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        #endif
    }
}

#if canImport(UIKit)
extension AdMobService: GADFullScreenContentDelegate {
    public func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        if ad is GADInterstitialAd {
            interstitialDismissCompletion?(.success(()))
            interstitialDismissCompletion = nil
            interstitialAd = nil
        } else if ad is GADRewardedAd {
            rewardedDismissCompletion?()
            rewardedAd = nil
        } else if ad is GADAppOpenAd {
            appOpenDismissCompletion?(.success(()))
            appOpenDismissCompletion = nil
            onAppOpenDismissed?()
            appOpenAd = nil
        } else if ad is GADRewardedInterstitialAd {
            rewardedInterstitialDismissCompletion?()
            rewardedInterstitialAd = nil
        }
    }
    
    public func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        if ad is GADInterstitialAd {
            interstitialDismissCompletion?(.failure(error))
            interstitialDismissCompletion = nil
            interstitialAd = nil
        } else if ad is GADRewardedAd {
            rewardedShowCompletion?(.failure(error))
            rewardedShowCompletion = nil
            rewardedAd = nil
        } else if ad is GADAppOpenAd {
            appOpenDismissCompletion?(.failure(error))
            appOpenDismissCompletion = nil
            appOpenAd = nil
        } else if ad is GADRewardedInterstitialAd {
            rewardedInterstitialShowCompletion?(.failure(error))
            rewardedInterstitialShowCompletion = nil
            rewardedInterstitialAd = nil
        }
    }
}
#endif
