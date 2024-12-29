//
//  GameCenterPlayerLocal.swift
//  SwiftGodotIosPlugins
//
//  Created by ZT Pawer on 12/26/24.
//

import GameKit
import SwiftGodot

@Godot
class GameCenterPlayerLocal: GameCenterPlayer {
    // MARK: Exports
    /// @Export
    ///
    /// Indicates if a player is under age
    @Export var isUnderage: Bool = false
    /// @Export
    ///
    /// A Boolean value that declares whether or not multiplayer gaming is restricted on this device.
    @Export var isMultiplayerGamingRestricted: Bool = false
    /// @Export
    ///
    /// A Boolean value that declares whether personalized communication is restricted on this device. If it is restricted, the player will not be able to read or write personalized messages on game invites, challenges, or enable voice communication in multiplayer games.  Note: this value will always be true when isUnderage is true.
    @Export var isPersonalizedCommunicationRestricted: Bool = false

    convenience init(_ player: GKLocalPlayer) {
        self.init()
        alias = player.alias
        displayName = player.displayName
        gamePlayerID = player.gamePlayerID
        teamPlayerID = player.teamPlayerID
        isUnderage = player.isUnderage
        isMultiplayerGamingRestricted = player.isMultiplayerGamingRestricted
        isPersonalizedCommunicationRestricted =
            player.isPersonalizedCommunicationRestricted
    }
}
