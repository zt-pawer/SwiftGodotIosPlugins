import Foundation
#if canImport(UIKit)
import UIKit
import GoogleMobileAds
#endif

extension AdMobService {
    public func loadBanner(adUnitID: String, position: String, completion: @escaping (Result<Void, Error>) -> Void) {
        #if canImport(UIKit)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let root = self.rootViewController else {
                let err = NSError(domain: "AdMobService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No root view controller found."])
                completion(.failure(err))
                self.onBannerFailedToLoad?(err.localizedDescription)
                return
            }
            guard let window = self.keyWindow else {
                let err = NSError(domain: "AdMobService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No key window found."])
                completion(.failure(err))
                self.onBannerFailedToLoad?(err.localizedDescription)
                return
            }
            
            self._destroyBanner()
            
            let banner = GADBannerView(adSize: GADAdSizeBanner)
            banner.adUnitID = adUnitID
            banner.rootViewController = root
            banner.delegate = self
            banner.isHidden = true // Keep hidden until showBanner() is explicitly called
            
            self.bannerView = banner
            self.bannerPosition = position
            self.bannerLoadCompletion = completion
            
            // Add to the keyWindow to avoid UIHostingController view hierarchy limitations
            window.addSubview(banner)
            banner.translatesAutoresizingMaskIntoConstraints = false
            
            let layoutGuide = window.safeAreaLayoutGuide
            var constraints: [NSLayoutConstraint] = [
                banner.centerXAnchor.constraint(equalTo: window.centerXAnchor)
            ]
            
            if position == "top" {
                constraints.append(banner.topAnchor.constraint(equalTo: layoutGuide.topAnchor))
            } else {
                constraints.append(banner.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor))
            }
            
            NSLayoutConstraint.activate(constraints)
            
            banner.load(GADRequest())
        }
        #else
        completion(.failure(NSError(domain: "AdMobService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Not supported on this platform."])))
        #endif
    }
    
    public func showBanner() {
        #if canImport(UIKit)
        DispatchQueue.main.async { [weak self] in
            self?.bannerView?.isHidden = false
        }
        #endif
    }
    
    public func hideBanner() {
        #if canImport(UIKit)
        DispatchQueue.main.async { [weak self] in
            self?.bannerView?.isHidden = true
        }
        #endif
    }
    
    private func _destroyBanner() {
        #if canImport(UIKit)
        self.bannerView?.removeFromSuperview()
        self.bannerView = nil
        self.bannerLoadCompletion = nil
        #endif
    }
    
    public func destroyBanner() {
        #if canImport(UIKit)
        DispatchQueue.main.async { [weak self] in
            self?._destroyBanner()
        }
        #endif
    }
}

#if canImport(UIKit)
extension AdMobService: GADBannerViewDelegate {
    public func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("[AdMobService] bannerViewDidReceiveAd called successfully")
        bannerLoadCompletion?(.success(()))
        bannerLoadCompletion = nil
        onBannerLoaded?()
    }
    
    public func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("[AdMobService] didFailToReceiveAdWithError called: \(error.localizedDescription)")
        bannerLoadCompletion?(.failure(error))
        bannerLoadCompletion = nil
        onBannerFailedToLoad?(error.localizedDescription)
    }
}
#endif
