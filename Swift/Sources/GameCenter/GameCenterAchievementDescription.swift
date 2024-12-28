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
    @Export var identifier: String = ""
    @Export var title: String = ""

    @Export var unachievedDescription: String = ""
    @Export var achievedDescription: String = ""

    @Export var maximumPoints: Int = 0

    @Export var isHidden: Bool = false
    @Export var isReplayable: Bool = false

    @Export var rarityPercent: Double = 0
    
    convenience init(_ description: GKAchievementDescription) {
        self.init()

        self.identifier = description.identifier
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
