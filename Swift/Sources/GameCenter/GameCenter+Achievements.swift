//
//  GameCenter+Achievements.swift
//  GameCenter
//
//  Created by ZT Pawer on 12/26/24.
//

import GameKit
import SwiftGodot

extension GameCenter {

    func reportAchievementsInternal(
        _ achievements: [GameCenterAchievement]
    ) {
        guard achievements.count > 0 else {
            achievementsReportFail.emit(
                GameCenterError.missingIdentifier.rawValue,
                "No achievements provided")
            return
        }
        var gkAchievements: [GKAchievement] = []
        for achievement in achievements {
            guard achievement.identifier != "" else {
                achievementsReportFail.emit(
                    GameCenterError.missingIdentifier.rawValue,
                    "Achievement without identifier")
                return
            }
            var gkAchievement = GKAchievement(
                identifier: achievement.identifier)
            gkAchievement.percentComplete = achievement.percentComplete ?? 0
            gkAchievement.showsCompletionBanner =
                achievement.showsCompletionBanner
            gkAchievements.append(gkAchievement)
        }
        debugger.emit("Reporting achievements")
        GKAchievement.report(
            gkAchievements,
            withCompletionHandler: {
                error in
                guard error == nil else {
                    self.achievementsReportFail.emit(
                        (error! as NSError).code,
                        "Error while reporting achievements")
                    return
                }

                self.achievementsReportSuccess.emit()
            })
    }

    func resetAchievementsInternal() {
        debugger.emit("Resetting achievements")
        GKAchievement.resetAchievements(completionHandler: { error in
            guard error == nil else {
                self.achievementsResetFail.emit(
                    (error! as NSError).code,
                    "Error while resetting achievements")
                return
            }
            self.achievementsResetSuccess.emit()

        })
    }

    func loadAchievementsInternal() {
        debugger.emit("Loading achievements")
        GKAchievement.loadAchievements(completionHandler: {
            gkAchievements, error in
            guard error == nil else {
                self.achievementsLoadFail.emit(
                    (error! as NSError).code,
                    "Error while loading achievements")
                return
            }
            var achievements = ObjectCollection<GameCenterAchievement>()
            guard let gkAchievements else {
                self.debugger.emit(
                    "Loaded 0 achievements")
                self.achievementsLoadSuccess.emit(
                    achievements)
                return
            }
            self.debugger.emit(
                "Loaded \(gkAchievements.count) achievements")
            for gkAchievement in gkAchievements {
                achievements.append(GameCenterAchievement(gkAchievement))
            }

            self.achievementsLoadSuccess.emit(
                achievements)
        })
    }

}
