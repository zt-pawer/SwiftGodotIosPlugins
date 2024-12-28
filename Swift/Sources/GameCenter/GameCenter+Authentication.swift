//
//  GameCenter+Authentication.swift
//  GameCenter
//
//  Created by ZT Pawer on 12/26/24.
//

import GameKit
import SwiftGodot

// MARK: Authentication

extension GameCenter {
    
    func authenticateInternal() {
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
                    self.signinFail.emit(
                        (error! as NSError).code, "Failed to authenticate \(error)")
                    return
                }

                self.player = GameCenterPlayerLocal(GKLocalPlayer.local)
                self.signinSuccess.emit(self.player!)
            }
        #else
            signinFail.emit(
                GameCenterError.notAvailable.rawValue,
                "GameCenter not available on this platform")
        #endif
    }

    /// @Callable
    ///
    /// - Returns:
    ///     - A Boolean value that indicates whether a local player has signed in to Game Center.
    @Callable
    func isAuthenticatedInternal() -> Bool {
        #if os(iOS)
            return GKLocalPlayer.local.isAuthenticated
        #else
            return false
        #endif
    }
}
