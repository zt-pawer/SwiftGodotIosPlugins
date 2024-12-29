//
//  GameCenter+Leaderboards.swift
//  GameCenter
//
//  Created by ZT Pawer on 12/28/24.
//

import GameKit
import SwiftGodot

extension GameCenter {

    func submitScoreInternal(
        _ score: Int, context: Int, player: GKPlayer,
        leaderboardIDs: [String]
    ) {
        guard GKLocalPlayer.local.isAuthenticated == true else {
            self.leaderboardScoreFail.emit(
                GameCenterError.notAuthenticated.rawValue,
                "Player is not authenticated")
            return
        }
        
        GKLeaderboard.submitScore(
            score, context: context, player: player,
            leaderboardIDs: leaderboardIDs,
            completionHandler: { error in
                guard error == nil else {
                    self.leaderboardScoreFail.emit(
                        (error! as NSError).code,
                        "Error while resetting achievements")
                    return
                }
                self.leaderboardScoreSuccess.emit()
            })
    }

    func showLeaderboardsInternal() {
        #if canImport(UIKit)
            viewController.showUIController(
                GKGameCenterViewController(state: .leaderboards),
                completitionHandler: { status in
                    switch status {
                    case GameCenterUIState.success.rawValue:
                        self.leaderboardSuccess.emit()
                    case GameCenterUIState.dismissed.rawValue:
                        self.leaderboardDismissed.emit()
                    default:
                        self.leaderboardFail.emit(GameCenterError.unknownError.rawValue, "Unknown error")
                    }
                })
        #endif
    }

    func showLeaderboardInternal(leaderboardID: String) {
        #if canImport(UIKit)
            viewController.showUIController(
                GKGameCenterViewController(
                    leaderboardID: leaderboardID,
                    playerScope: .global,
                    timeScope: .allTime
                ),
                completitionHandler: { status in
                    switch status {
                    case GameCenterUIState.success.rawValue:
                        self.leaderboardSuccess.emit()
                    case GameCenterUIState.dismissed.rawValue:
                        self.leaderboardDismissed.emit()
                    default:
                        self.leaderboardFail.emit(GameCenterError.unknownError.rawValue, "Unknown error")
                    }
                })
        #else
            leaderboardFail.emit(
                GameCenterError.notAvailable.rawValue,
                "Leaderboard not available")
        #endif
    }
}
