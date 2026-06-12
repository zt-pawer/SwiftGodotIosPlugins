//
//  AdMob.swift
//  SwiftGodotIosPlugins
//
//  AdMob plugin for Godot using SwiftGodot
//

import Foundation
import SwiftGodot

#initSwiftExtension(
    cdecl: "admob",
    types: [
        AdMob.self,
    ]
)

@Godot
class AdMob: Object {
    // MARK: - Signals
    
    @Signal var bannerLoaded: SimpleSignal
    @Signal var bannerFailed: SignalWithArguments<String>
    
    @Signal var interstitialLoaded: SimpleSignal
    @Signal var interstitialFailed: SignalWithArguments<String>
    @Signal var interstitialClosed: SimpleSignal
    
    @Signal var rewardedLoaded: SimpleSignal
    @Signal var rewardedFailed: SignalWithArguments<String>
    @Signal var rewardedUser: SignalWithArguments<String, Int>
    @Signal var rewardedClosed: SimpleSignal
    
    @Signal var consentInfoUpdated: SimpleSignal
    @Signal var consentInfoFailed: SignalWithArguments<String>
    @Signal var consentFormPresented: SimpleSignal
    @Signal var consentFormFailed: SignalWithArguments<String>
    
    @Signal var appOpenLoaded: SimpleSignal
    @Signal var appOpenFailed: SignalWithArguments<String>
    @Signal var appOpenClosed: SimpleSignal
    
    @Signal var rewardedInterstitialLoaded: SimpleSignal
    @Signal var rewardedInterstitialFailed: SignalWithArguments<String>
    @Signal var rewardedInterstitialUser: SignalWithArguments<String, Int>
    @Signal var rewardedInterstitialClosed: SimpleSignal
    
    // MARK: - Properties
    
    static var shared: AdMob?
    private var service: AdMobServiceProtocol
    
    // MARK: - Initialization
    
    required init(_ context: InitContext) {
        self.service = AdMobService()
        super.init(context)
        
        setupCallbacks()
        AdMob.shared = self
        GD.print("[AdMob] Plugin initialized")
    }
    
    func setServiceForTesting(_ service: AdMobServiceProtocol) {
        self.service = service
        setupCallbacks()
    }
    
    private func setupCallbacks() {
        service.onBannerLoaded = { [weak self] in
            guard let self = self else { return }
            self.bannerLoaded.emit()
        }
        
        service.onBannerFailedToLoad = { [weak self] errorMsg in
            guard let self = self else { return }
            self.bannerFailed.emit(errorMsg)
        }
        
        service.onRewardedDismissed = { [weak self] in
            guard let self = self else { return }
            self.rewardedClosed.emit()
        }
        
        service.onRewardedInterstitialDismissed = { [weak self] in
            guard let self = self else { return }
            self.rewardedInterstitialClosed.emit()
        }
        
        service.onAppOpenDismissed = { [weak self] in
            guard let self = self else { return }
            self.appOpenClosed.emit()
        }
    }
    
    // MARK: - Public Methods
    
    @Callable
    func initialize() {
        GD.print("[AdMob] initialize() called")
        service.initialize()
    }
    
    @Callable
    func loadBanner(adUnitID: String, position: String) {
        GD.print("[AdMob] loadBanner() called with ID: \(adUnitID), position: \(position)")
        service.loadBanner(adUnitID: adUnitID, position: position) { _ in
            // Handled via delegates / callbacks
        }
    }
    
    @Callable
    func showBanner() {
        GD.print("[AdMob] showBanner() called")
        service.showBanner()
    }
    
    @Callable
    func hideBanner() {
        GD.print("[AdMob] hideBanner() called")
        service.hideBanner()
    }
    
    @Callable
    func destroyBanner() {
        GD.print("[AdMob] destroyBanner() called")
        service.destroyBanner()
    }
    
    @Callable
    func loadInterstitial(adUnitID: String) {
        GD.print("[AdMob] loadInterstitial() called with ID: \(adUnitID)")
        service.loadInterstitial(adUnitID: adUnitID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.interstitialLoaded.emit()
            case .failure(let error):
                self.interstitialFailed.emit(error.localizedDescription)
            }
        }
    }
    
    @Callable
    func showInterstitial() {
        GD.print("[AdMob] showInterstitial() called")
        service.showInterstitial { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.interstitialClosed.emit()
            case .failure(let error):
                self.interstitialFailed.emit(error.localizedDescription)
            }
        }
    }
    
    @Callable
    func loadRewarded(adUnitID: String) {
        GD.print("[AdMob] loadRewarded() called with ID: \(adUnitID)")
        service.loadRewarded(adUnitID: adUnitID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.rewardedLoaded.emit()
            case .failure(let error):
                self.rewardedFailed.emit(error.localizedDescription)
            }
        }
    }
    
    @Callable
    func showRewarded() {
        GD.print("[AdMob] showRewarded() called")
        service.showRewarded { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let (rewardType, rewardAmount)):
                self.rewardedUser.emit(rewardType, rewardAmount)
            case .failure(let error):
                self.rewardedFailed.emit(error.localizedDescription)
            }
        }
    }
    
    @Callable
    func requestConsentInfoUpdate(underAgeOfConsent: Bool) {
        GD.print("[AdMob] requestConsentInfoUpdate() called")
        service.requestConsentInfoUpdate(underAgeOfConsent: underAgeOfConsent) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.consentInfoUpdated.emit()
            case .failure(let error):
                self.consentInfoFailed.emit(error.localizedDescription)
            }
        }
    }
    
    @Callable
    func loadAndPresentConsentForm() {
        GD.print("[AdMob] loadAndPresentConsentForm() called")
        service.loadAndPresentConsentForm { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.consentFormPresented.emit()
            case .failure(let error):
                self.consentFormFailed.emit(error.localizedDescription)
            }
        }
    }
    
    @Callable
    func canRequestAds() -> Bool {
        let allowed = service.canRequestAds()
        GD.print("[AdMob] canRequestAds() returning \(allowed)")
        return allowed
    }
    
    @Callable
    func resetConsent() {
        GD.print("[AdMob] resetConsent() called")
        service.resetConsent()
    }
    
    @Callable
    func loadAppOpen(adUnitID: String) {
        GD.print("[AdMob] loadAppOpen() called with ID: \(adUnitID)")
        service.loadAppOpen(adUnitID: adUnitID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.appOpenLoaded.emit()
            case .failure(let error):
                self.appOpenFailed.emit(error.localizedDescription)
            }
        }
    }
    
    @Callable
    func showAppOpen() {
        GD.print("[AdMob] showAppOpen() called")
        service.showAppOpen { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                // Emitted via onAppOpenDismissed delegate handler
                break
            case .failure(let error):
                self.appOpenFailed.emit(error.localizedDescription)
            }
        }
    }
    
    @Callable
    func loadRewardedInterstitial(adUnitID: String) {
        GD.print("[AdMob] loadRewardedInterstitial() called with ID: \(adUnitID)")
        service.loadRewardedInterstitial(adUnitID: adUnitID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.rewardedInterstitialLoaded.emit()
            case .failure(let error):
                self.rewardedInterstitialFailed.emit(error.localizedDescription)
            }
        }
    }
    
    @Callable
    func showRewardedInterstitial() {
        GD.print("[AdMob] showRewardedInterstitial() called")
        service.showRewardedInterstitial { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let (rewardType, rewardAmount)):
                self.rewardedInterstitialUser.emit(rewardType, rewardAmount)
            case .failure(let error):
                self.rewardedInterstitialFailed.emit(error.localizedDescription)
            }
        }
    }
    
    @Callable
    func setTestDeviceIDs(deviceIDs: PackedStringArray) {
        let ids = deviceIDs.map { String($0) }
        GD.print("[AdMob] setTestDeviceIDs() called with: \(ids)")
        service.setTestDeviceIDs(ids)
    }
    
    @Callable
    func setChildDirectedTreatment(tag: Bool) {
        GD.print("[AdMob] setChildDirectedTreatment() called with tag: \(tag)")
        service.setChildDirectedTreatment(tag)
    }
    
    @Callable
    func setMaxAdContentRating(rating: String) {
        GD.print("[AdMob] setMaxAdContentRating() called with rating: \(rating)")
        service.setMaxAdContentRating(rating)
    }
    
    @Callable
    func setMuted(muted: Bool) {
        GD.print("[AdMob] setMuted() called with: \(muted)")
        service.setMuted(muted)
    }
}
