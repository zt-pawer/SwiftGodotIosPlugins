//
//  GameCenterAchievement.swift
//  GameCenter
//
//  Created by ZT Pawer on 12/26/24.
//

import GameKit
import SwiftGodot

#if canImport(Foundation)
    import Foundation
#endif

@Godot
class GameCenterAchievement: Object {
    // MARK: Export
    /// @Export
    /// Achievement identifier
    @Export var identifier: String = ""
    /// @Export
    /// The identifier of the player that earned the achievement.
    @Export var player: GameCenterPlayer?
    /// @Export
    /// Set to false until percentComplete = 100
    @Export var isCompleted: Bool = false
    /// @Export
    /// Required, Percentage of achievement complete.
    @Export var percentComplete: Double = 0
    /// @Export
    /// Required, Percentage of achievement complete.
    @Export var showsCompletionBanner: Bool = false
    /// @Export
    /// Date the achievement was last reported. Read-only. Created at initialization
    @Export var lastReportedDate: Double = 0

    convenience init(_ achievement: GKAchievement) {
        self.init()

        self.identifier = achievement.identifier
        self.player = GameCenterPlayer(achievement.player)
        self.isCompleted = achievement.isCompleted
        self.percentComplete = achievement.percentComplete
        self.showsCompletionBanner = achievement.showsCompletionBanner
        #if canImport(Foundation)
            self.lastReportedDate =
                achievement.lastReportedDate.timeIntervalSince1970
        #endif
    }
}
