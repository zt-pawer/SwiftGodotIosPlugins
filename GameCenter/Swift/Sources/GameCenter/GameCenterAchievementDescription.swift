//
//  GameCenterAchievementDescription.swift
//  GameCenter
//
//  Created by ZT Pawer on 12/27/24.
//

import GameKit
import SwiftGodot

@Godot
class GameCenterAchievementDescription: Object {
    // MARK: Export
    /// @Export
    /// Achievement identifier
    @Export var identifier: String = ""
    /// @Export
    ///The group identifier for the achievement, if one exists.
    @Export var groupIdentifier: String = ""
    /// @Export
    /// The title of the achievement.
    @Export var title: String = ""
    /// @Export
    /// The description for an unachieved achievement.
    @Export var unachievedDescription: String = ""
    /// @Export
    /// The description for an achieved achievement.
    @Export var achievedDescription: String = ""
    /// @Export
    /// Maximum points available for completing this achievement.
    @Export var maximumPoints: Int = 0
    /// @Export
    /// Whether or not the achievement should be listed or displayed if not yet unhidden by the game.
    @Export var isHidden: Bool = false
    /// @Export
    /// Whether or not the achievement will be reported by the game when the user earns it again. This allows the achievement to be used for challenges when the recipient has previously earned it.
    @Export var isReplayable: Bool = false
    /// @Export
    /// Achievement identifier
    @Export var rarityPercent: Double = 0
    
    convenience init(_ description: GKAchievementDescription) {
        self.init()
        self.identifier = description.identifier
        self.groupIdentifier = description.groupIdentifier ?? ""
        self.title = description.title
        self.unachievedDescription = description.unachievedDescription
        self.achievedDescription = description.achievedDescription
        self.maximumPoints = description.maximumPoints
        self.isHidden = description.isHidden
        self.isReplayable = description.isReplayable
        if #available(iOS 17, macOS 14, *), let rarityPercent = description.rarityPercent {
            self.rarityPercent = rarityPercent
        }
    }
}
