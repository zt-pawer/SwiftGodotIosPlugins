// The Swift Programming Language
// https://docs.swift.org/swift-book
import GameKit
import SwiftGodot

#if canImport(UIKit)
import UIKit
#endif

#initSwiftExtension(
    cdecl: "gamecenter",
    types: [
        GameCenter.self,
        GameCenterPlayer.self,
        GameCenterPlayerLocal.self,
    ]
)

@Godot
class GameCenter: RefCounted {
    enum GameCenterError: Int, Error {
        case ok = 0
        case unknownError = 1
        case notAuthenticated = 2
        case notAvailable = 3
        case failedToAuthenticate = 4
        case failedToLoadPicture = 8
    }
    
    #if canImport(UIKit)
        var viewController: GameCenterViewController =
            GameCenterViewController()
    #endif

    static var instance: GameCenter?
    var player: GameCenterPlayer?

    required init() {
        GameCenter.instance = self
    }

    required init(nativeHandle: UnsafeRawPointer) {
        GameCenter.instance = self
    }
    
    // MARK: Authentication
    /// Authenticate with gameCenter.
    ///
    /// - Parameters:
    ///     - onComplete: Callback with parameter: (error: Variant, data: Variant) -> (error: Int, data: ``GameCenterPlayerLocal``)
    @Callable
    public func authenticate(onComplete: Callable = Callable()) {
        if GKLocalPlayer.local.isAuthenticated && self.player != nil {
            onComplete.call(Variant(GameCenterError.ok.rawValue), Variant(self.player!))
            return
        }

        #if os(iOS)
            GKLocalPlayer.local.authenticateHandler = {
                loginController, error in
                guard loginController == nil else {
                    self.viewController.getRootController()?.present(
                        loginController!, animated: true)
                    return
                }

                guard error == nil else {
                    GD.pushError("Failed to authenticate \(error)")
                    onComplete.callDeferred(
                        Variant(GameCenterError.failedToAuthenticate.rawValue),
                        Variant())
                    return
                }

                var player = GameCenterPlayerLocal(GKLocalPlayer.local)
                onComplete.callDeferred(Variant(GameCenterError.ok.rawValue), Variant(player))
            }
        #else
            GD.pushWarning("GameCenter not available on this platform")
            onComplete.call(Variant(GameCenterError.notAvailable.rawValue))
        #endif
    }

    /// @Callable
    /// A Boolean value that indicates whether a local player has signed in to Game Center.
    func isAuthenticated() -> Bool {
        #if os(iOS)
            return GKLocalPlayer.local.isAuthenticated
        #else
            return false
        #endif
    }

    /// @Callable
    @Callable
    func logOut() {
        GKLocalPlayer.local.logOut()
    }

}
