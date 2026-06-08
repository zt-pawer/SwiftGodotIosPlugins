import Foundation
import FirebaseCore
import SwiftGodot

#initSwiftExtension(
    cdecl: "firebase",
    types: [
        GodotFirebase.self,
        GodotFirebaseAuth.self,
        GodotFirebaseAppCheck.self
    ]
)

@Godot
class GodotFirebase: RefCounted {
    static var shared: GodotFirebase?
    private static var isFirebaseConfigured = false
    
    /// @Callable
    /// Configures the default Firebase app.
    @Callable
    func configure() {
        GodotFirebase.shared = self
        
        let mainBundle = Bundle.main
        let plistInMain = mainBundle.path(forResource: "GoogleService-Info", ofType: "plist")
        
        let frameworkBundle = Bundle(for: GodotFirebase.self)
        let plistInFramework = frameworkBundle.path(forResource: "GoogleService-Info", ofType: "plist")
        
        if !GodotFirebase.isFirebaseConfigured {
            if let plistPath = plistInMain ?? plistInFramework,
               let options = FirebaseOptions(contentsOfFile: plistPath) {
                FirebaseApp.configure(options: options)
                GodotFirebase.isFirebaseConfigured = true
            } else {
                FirebaseApp.configure()
                GodotFirebase.isFirebaseConfigured = true
            }
        }
    }
    
    /// @Callable
    /// Returns true if the default Firebase app is already configured.
    @Callable
    func isConfigured() -> Bool {
        return GodotFirebase.isFirebaseConfigured
    }
}
