import Foundation
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
    private let service = FirebaseService.shared
    
    /// @Callable
    /// Configures the default Firebase app.
    @Callable
    func configure() {
        GodotFirebase.shared = self
        service.configure()
    }
    
    /// @Callable
    /// Returns true if the default Firebase app is already configured.
    @Callable
    func isConfigured() -> Bool {
        return service.isConfigured()
    }
}
