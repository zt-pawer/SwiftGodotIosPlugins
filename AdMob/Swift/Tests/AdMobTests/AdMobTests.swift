import XCTest
@testable import AdMob

class MockAdMobService: AdMobServiceProtocol {
    var onBannerLoaded: (() -> Void)?
    var onBannerFailedToLoad: ((String) -> Void)?
    var onRewardedDismissed: (() -> Void)?
    
    var initializeCalled = false
    var loadBannerCalled = false
    var bannerAdUnitID: String?
    var bannerPosition: String?
    var showBannerCalled = false
    var hideBannerCalled = false
    var destroyBannerCalled = false
    
    var loadInterstitialCalled = false
    var interstitialAdUnitID: String?
    var showInterstitialCalled = false
    
    var loadRewardedCalled = false
    var rewardedAdUnitID: String?
    var showRewardedCalled = false
    
    var loadAppOpenCalled = false
    var appOpenAdUnitID: String?
    var showAppOpenCalled = false
    
    var loadRewardedInterstitialCalled = false
    var rewardedInterstitialAdUnitID: String?
    var showRewardedInterstitialCalled = false
    
    var requestConsentInfoUpdateCalled = false
    var tagForUnderAgeOfConsent: Bool?
    var loadAndPresentConsentFormCalled = false
    var canRequestAdsValue = true
    var resetConsentCalled = false
    
    var testDeviceIDs: [String]?
    var childDirectedTreatment: Bool?
    var maxAdContentRating: String?
    var isMuted: Bool?
    
    var onRewardedInterstitialDismissed: (() -> Void)?
    var onAppOpenDismissed: (() -> Void)?
    
    // Configurable response results
    var bannerResult: Result<Void, Error> = .success(())
    var interstitialLoadResult: Result<Void, Error> = .success(())
    var interstitialShowResult: Result<Void, Error> = .success(())
    var rewardedLoadResult: Result<Void, Error> = .success(())
    var rewardedShowResult: Result<(String, Int), Error> = .success(("coins", 100))
    var appOpenLoadResult: Result<Void, Error> = .success(())
    var appOpenShowResult: Result<Void, Error> = .success(())
    var rewardedInterstitialLoadResult: Result<Void, Error> = .success(())
    var rewardedInterstitialShowResult: Result<(String, Int), Error> = .success(("diamonds", 50))
    var consentUpdateResult: Result<Void, Error> = .success(())
    var consentFormResult: Result<Void, Error> = .success(())
    
    func initialize() {
        initializeCalled = true
    }
    
    func loadBanner(adUnitID: String, position: String, completion: @escaping (Result<Void, Error>) -> Void) {
        loadBannerCalled = true
        bannerAdUnitID = adUnitID
        bannerPosition = position
        completion(bannerResult)
        switch bannerResult {
        case .success:
            onBannerLoaded?()
        case .failure(let error):
            onBannerFailedToLoad?(error.localizedDescription)
        }
    }
    
    func showBanner() {
        showBannerCalled = true
    }
    
    func hideBanner() {
        hideBannerCalled = true
    }
    
    func destroyBanner() {
        destroyBannerCalled = true
    }
    
    func loadInterstitial(adUnitID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        loadInterstitialCalled = true
        interstitialAdUnitID = adUnitID
        completion(interstitialLoadResult)
    }
    
    func showInterstitial(completion: @escaping (Result<Void, Error>) -> Void) {
        showInterstitialCalled = true
        completion(interstitialShowResult)
    }
    
    func loadRewarded(adUnitID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        loadRewardedCalled = true
        rewardedAdUnitID = adUnitID
        completion(rewardedLoadResult)
    }
    
    func showRewarded(completion: @escaping (Result<(String, Int), Error>) -> Void) {
        showRewardedCalled = true
        completion(rewardedShowResult)
    }
    
    func loadAppOpen(adUnitID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        loadAppOpenCalled = true
        appOpenAdUnitID = adUnitID
        completion(appOpenLoadResult)
    }
    
    func showAppOpen(completion: @escaping (Result<Void, Error>) -> Void) {
        showAppOpenCalled = true
        completion(appOpenShowResult)
    }
    
    func loadRewardedInterstitial(adUnitID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        loadRewardedInterstitialCalled = true
        rewardedInterstitialAdUnitID = adUnitID
        completion(rewardedInterstitialLoadResult)
    }
    
    func showRewardedInterstitial(completion: @escaping (Result<(String, Int), Error>) -> Void) {
        showRewardedInterstitialCalled = true
        completion(rewardedInterstitialShowResult)
    }
    
    func requestConsentInfoUpdate(underAgeOfConsent: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        requestConsentInfoUpdateCalled = true
        tagForUnderAgeOfConsent = underAgeOfConsent
        completion(consentUpdateResult)
    }
    
    func loadAndPresentConsentForm(completion: @escaping (Result<Void, Error>) -> Void) {
        loadAndPresentConsentFormCalled = true
        completion(consentFormResult)
    }
    
    func canRequestAds() -> Bool {
        return canRequestAdsValue
    }
    
    func resetConsent() {
        resetConsentCalled = true
    }
    
    func setTestDeviceIDs(_ ids: [String]) {
        testDeviceIDs = ids
    }
    
    func setChildDirectedTreatment(_ tag: Bool) {
        childDirectedTreatment = tag
    }
    
    func setMaxAdContentRating(_ rating: String) {
        maxAdContentRating = rating
    }
    
    func setMuted(_ muted: Bool) {
        isMuted = muted
    }
    
    func triggerRewardedDismiss() {
        onRewardedDismissed?()
    }
}

final class AdMobTests: XCTestCase {
    func testInitialization() {
        let mock = MockAdMobService()
        mock.initialize()
        XCTAssertTrue(mock.initializeCalled)
    }
    
    func testBannerLifecycle() {
        let mock = MockAdMobService()
        
        var bannerLoadedCalled = false
        mock.onBannerLoaded = {
            bannerLoadedCalled = true
        }
        
        var bannerFailedMsg: String?
        mock.onBannerFailedToLoad = { msg in
            bannerFailedMsg = msg
        }
        
        // Success case
        mock.loadBanner(adUnitID: "ca-app-pub-3940256099942544/2934735716", position: "bottom") { result in
            XCTAssertTrue(self.caseOfSuccess(result))
        }
        
        XCTAssertTrue(mock.loadBannerCalled)
        XCTAssertEqual(mock.bannerAdUnitID, "ca-app-pub-3940256099942544/2934735716")
        XCTAssertEqual(mock.bannerPosition, "bottom")
        XCTAssertTrue(bannerLoadedCalled)
        
        mock.showBanner()
        XCTAssertTrue(mock.showBannerCalled)
        
        mock.hideBanner()
        XCTAssertTrue(mock.hideBannerCalled)
        
        mock.destroyBanner()
        XCTAssertTrue(mock.destroyBannerCalled)
        
        // Failure case
        let testError = NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to load"])
        mock.bannerResult = .failure(testError)
        mock.loadBanner(adUnitID: "error_id", position: "top") { result in
            XCTAssertTrue(self.caseOfFailure(result))
        }
        XCTAssertEqual(bannerFailedMsg, "Failed to load")
    }
    
    func testInterstitialLifecycle() {
        let mock = MockAdMobService()
        
        mock.loadInterstitial(adUnitID: "interstitial_id") { result in
            XCTAssertTrue(self.caseOfSuccess(result))
        }
        XCTAssertTrue(mock.loadInterstitialCalled)
        XCTAssertEqual(mock.interstitialAdUnitID, "interstitial_id")
        
        mock.showInterstitial { result in
            XCTAssertTrue(self.caseOfSuccess(result))
        }
        XCTAssertTrue(mock.showInterstitialCalled)
    }
    
    func testRewardedLifecycle() {
        let mock = MockAdMobService()
        
        mock.loadRewarded(adUnitID: "rewarded_id") { result in
            XCTAssertTrue(self.caseOfSuccess(result))
        }
        XCTAssertTrue(mock.loadRewardedCalled)
        XCTAssertEqual(mock.rewardedAdUnitID, "rewarded_id")
        
        mock.showRewarded { result in
            switch result {
            case .success(let (type, amount)):
                XCTAssertEqual(type, "coins")
                XCTAssertEqual(amount, 100)
            case .failure:
                XCTFail("Should succeed")
            }
        }
        XCTAssertTrue(mock.showRewardedCalled)
        
        var dismissCalled = false
        mock.onRewardedDismissed = {
            dismissCalled = true
        }
        mock.triggerRewardedDismiss()
        XCTAssertTrue(dismissCalled)
    }
    
    func testConsentLifecycle() {
        let mock = MockAdMobService()
        
        mock.requestConsentInfoUpdate(underAgeOfConsent: false) { result in
            XCTAssertTrue(self.caseOfSuccess(result))
        }
        XCTAssertTrue(mock.requestConsentInfoUpdateCalled)
        XCTAssertEqual(mock.tagForUnderAgeOfConsent, false)
        
        mock.loadAndPresentConsentForm { result in
            XCTAssertTrue(self.caseOfSuccess(result))
        }
        XCTAssertTrue(mock.loadAndPresentConsentFormCalled)
        
        XCTAssertTrue(mock.canRequestAds())
        
        mock.resetConsent()
        XCTAssertTrue(mock.resetConsentCalled)
    }
    
    func testNewAdsAndConfigurations() {
        let mock = MockAdMobService()
        
        // App Open Ads
        mock.loadAppOpen(adUnitID: "app_open_id") { result in
            XCTAssertTrue(self.caseOfSuccess(result))
        }
        XCTAssertTrue(mock.loadAppOpenCalled)
        XCTAssertEqual(mock.appOpenAdUnitID, "app_open_id")
        
        mock.showAppOpen { result in
            XCTAssertTrue(self.caseOfSuccess(result))
        }
        XCTAssertTrue(mock.showAppOpenCalled)
        
        // Rewarded Interstitial Ads
        mock.loadRewardedInterstitial(adUnitID: "rewarded_interstitial_id") { result in
            XCTAssertTrue(self.caseOfSuccess(result))
        }
        XCTAssertTrue(mock.loadRewardedInterstitialCalled)
        XCTAssertEqual(mock.rewardedInterstitialAdUnitID, "rewarded_interstitial_id")
        
        mock.showRewardedInterstitial { result in
            if case .success(let (type, amount)) = result {
                XCTAssertEqual(type, "diamonds")
                XCTAssertEqual(amount, 50)
            } else {
                XCTFail()
            }
        }
        XCTAssertTrue(mock.showRewardedInterstitialCalled)
        
        // Configurations
        mock.setTestDeviceIDs(["dev_1", "dev_2"])
        XCTAssertEqual(mock.testDeviceIDs, ["dev_1", "dev_2"])
        
        mock.setChildDirectedTreatment(true)
        XCTAssertEqual(mock.childDirectedTreatment, true)
        
        mock.setMaxAdContentRating("PG")
        XCTAssertEqual(mock.maxAdContentRating, "PG")
        
        mock.setMuted(true)
        XCTAssertEqual(mock.isMuted, true)
    }
    
    private func caseOfSuccess<T>(_ result: Result<T, Error>) -> Bool {
        if case .success = result { return true }
        return false
    }
    
    private func caseOfFailure<T>(_ result: Result<T, Error>) -> Bool {
        if case .failure = result { return true }
        return false
    }
}
