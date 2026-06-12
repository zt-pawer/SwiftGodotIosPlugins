import Foundation
import FirebaseCore

public final class FirebaseService {
    public static let shared = FirebaseService()
    private var isFirebaseConfigured = false
    
    private init() {}
    
    public func configure() {
        guard !isFirebaseConfigured else { return }
        
        let mainBundle = Bundle.main
        let plistInMain = mainBundle.path(forResource: "GoogleService-Info", ofType: "plist")
        
        let frameworkBundle = Bundle(for: FirebaseService.self)
        let plistInFramework = frameworkBundle.path(forResource: "GoogleService-Info", ofType: "plist")
        
        if let plistPath = plistInMain ?? plistInFramework,
           let options = FirebaseOptions(contentsOfFile: plistPath) {
            FirebaseApp.configure(options: options)
            isFirebaseConfigured = true
        } else {
            FirebaseApp.configure()
            isFirebaseConfigured = true
        }
    }
    
    public func isConfigured() -> Bool {
        return isFirebaseConfigured
    }
}
