import Foundation
#if canImport(UIKit)
import GoogleMobileAds
import UserMessagingPlatform
#endif

extension AdMobService {
    public func canRequestAds() -> Bool {
        #if canImport(UIKit)
        return UMPConsentInformation.sharedInstance.canRequestAds
        #else
        return false
        #endif
    }
    
    public func resetConsent() {
        #if canImport(UIKit)
        UMPConsentInformation.sharedInstance.reset()
        #endif
    }
    
    public func setTestDeviceIDs(_ ids: [String]) {
        self.testDeviceIDs = ids
        #if canImport(UIKit)
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ids
        #endif
    }
    
    public func setChildDirectedTreatment(_ tag: Bool) {
        #if canImport(UIKit)
        GADMobileAds.sharedInstance().requestConfiguration.tagForChildDirectedTreatment = NSNumber(value: tag)
        #endif
    }
    
    public func setMaxAdContentRating(_ rating: String) {
        #if canImport(UIKit)
        let ratingValue: GADMaxAdContentRating
        switch rating.lowercased() {
        case "g": ratingValue = .general
        case "pg": ratingValue = .parentalGuidance
        case "t": ratingValue = .teen
        case "ma": ratingValue = .matureAudience
        default: return
        }
        GADMobileAds.sharedInstance().requestConfiguration.maxAdContentRating = ratingValue
        #endif
    }
    
    public func setMuted(_ muted: Bool) {
        #if canImport(UIKit)
        GADMobileAds.sharedInstance().applicationMuted = muted
        #endif
    }
}
