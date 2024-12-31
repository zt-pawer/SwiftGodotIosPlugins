//
//  GameCenter+Achievements.swift
//  GameCenter
//
//  Created by ZT Pawer on 12/26/24.
//

import GameKit
import SwiftGodot

extension GameCenter {

    func loadAchievementDescriptionsInternal() {
        GKAchievementDescription.loadAchievementDescriptions(
            completionHandler: { descriptions, error in
                guard error == nil else {
                    self.achievementsDescriptionFail.emit(
                        (error! as NSError).code,
                        "Error while loading achievement descriptions")
                    return
                }
                GD.printDebug("Loading achievements")
                var achievementDestriptions = ObjectCollection<
                    GameCenterAchievementDescription
                >()
                for description in descriptions! {
                    achievementDestriptions.append(
                        GameCenterAchievementDescription(description))
                }
                GD.printDebug(
                    "Loaded \(achievementDestriptions.count) achievement descriptions")
                self.achievementsDescriptionSuccess.emit(
                    achievementDestriptions)

            })
    }
}
