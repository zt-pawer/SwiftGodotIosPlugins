//
//  GameCenterViewController.swift
//  SwiftGodotIosPlugins
//
//  Created by ZT Pawer on 12/26/24.
//

import GameKit
import SwiftGodot

#if canImport(UIKit)
    import UIKit
#endif

#initSwiftExtension(
    cdecl: "gamecenter",
    types: [
        GameCenter.self,
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
    
    // MARK: Signals
    /// Player is successfully authenticated on GameCenter
    @Signal var signinSuccess: SignalWithArguments<GameCenterPlayerLocal>
    /// Error suring the signing process
    @Signal var signinFail: SignalWithArguments<String>
    
    #if canImport(UIKit)
        var viewController: GameCenterViewController =
            GameCenterViewController()
    #endif

    static var instance: GameCenter?
    var player: GameCenterPlayerLocal?

    required init() {
        super.init()
        GameCenter.instance = self
    }

    required init(nativeHandle: UnsafeRawPointer) {
        super.init()
        GameCenter.instance = self
    }

    // MARK: Authentication
    /// Authenticate with gameCenter.
    ///
    /// - Signals:
    ///     - signin_success: an instance of the GameCenterPlayerLocal is associated with the signal
    ///     - signin_fail: an error message is associated with the signal
    @Callable
    public func authenticate() {
        if GKLocalPlayer.local.isAuthenticated && self.player != nil {
            signinSuccess.emit(self.player!)
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
                    self.signinFail.emit("Failed to authenticate \(error)")
                    return
                }

                self.player = GameCenterPlayerLocal(GKLocalPlayer.local)
                self.signinSuccess.emit(self.player!)
            }
        #else
            signinFail.emit("GameCenter not available on this platform")
        #endif
    }

    /// @Callable
    ///
    /// - Returns:
    ///     - A Boolean value that indicates whether a local player has signed in to Game Center.
    func isAuthenticated() -> Bool {
        #if os(iOS)
            return GKLocalPlayer.local.isAuthenticated
        #else
            return false
        #endif
    }
}
