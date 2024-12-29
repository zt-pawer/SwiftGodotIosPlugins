//
//  GameCenterPlayer.swift
//  GameCenter
//
//  Created by ZT Pawer on 12/26/24.
//

import GameKit
import SwiftGodot

@Godot
class GameCenterPlayer: Object {
    // MARK: Exports
    /// @Export
    ///
    /// The alias property contains the player's nickname. When you need to display the name to the user, consider using displayName instead. The nickname is unique but not invariant: the player may change their nickname. The nickname may be very long, so be sure to use appropriate string truncation API when drawing.
    @Export var alias: String = ""
    /// @Export
    ///
    /// This is player's alias to be displayed. The display name may be very long, so be sure to use appropriate string truncation API when drawing.
    @Export var displayName: String = ""
    /// @Export
    ///
    ///  This is the player's unique and persistent ID that is scoped to this application.
    @Export var gamePlayerID: String = ""
    /// @Export
    ///
    ///  This is the player's unique and persistent ID that is scoped to the Apple Store Connect Team identifier of this application.
    @Export var teamPlayerID: String = ""
    /// @Export
    ///
    @Export var isInvitable: Bool = false
    /// @Export
    ///
    @Export var profilePicture: Image?
    
    convenience init(_ player: GKPlayer) {
        self.init()
        alias = player.alias
        displayName = player.displayName
        gamePlayerID = player.gamePlayerID
        teamPlayerID = player.teamPlayerID
        isInvitable = player.isInvitable
    }
    
}
