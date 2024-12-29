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
        GameCenterAchievement.self,
        GameCenterAchievementDescription.self,
        GameCenterPlayer.self,
        GameCenterPlayerLocal.self,
    ]
)

enum GameCenterError: Int, Error {
    case unknownError = 1
    case notAuthenticated = 2
    case notAvailable = 3
    case failedToAuthenticate = 4
    case failedToLoadPicture = 5
    case missingIdentifier = 6
}

@Godot
class GameCenter: Object {

    @Signal var debugger: SignalWithArguments<String>

    // MARK: Authentication
    /// @Signal
    /// Player is successfully authenticated on GameCenter
    @Signal var signinSuccess: SignalWithArguments<GameCenterPlayerLocal>
    /// @Signal
    /// Error suring the signing process
    @Signal var signinFail: SignalWithArguments<Int, String>

    // MARK: Achievements
    /// @Signal
    /// Achievement(s) have been successfully reported
    @Signal var achievementsReportSuccess: SimpleSignal
    /// @Signal
    /// Error reporting the achievements
    @Signal var achievementsReportFail: SignalWithArguments<Int, String>
    /// @Signal
    /// Achievement(s) have been successfully reported
    @Signal var achievementsResetSuccess: SimpleSignal
    /// @Signal
    /// Error reporting the achievements
    @Signal var achievementsResetFail: SignalWithArguments<Int, String>
    /// @Signal
    /// Achievements have been successfully loaded
    @Signal var achievementsLoadSuccess:
        SignalWithArguments<ObjectCollection<GameCenterAchievement>>
    /// @Signal
    /// Error loading the achievements
    @Signal var achievementsLoadFail: SignalWithArguments<Int, String>
    /// @Signal
    /// Achievement(s) have been successfully reported
    @Signal var achievementsDescriptionSuccess:
        SignalWithArguments<ObjectCollection<GameCenterAchievementDescription>>
    /// @Signal
    /// Error reporting the achievements
    @Signal var achievementsDescriptionFail: SignalWithArguments<Int, String>
    /// @Signal
    /// Score(s) have been successfully reported
    @Signal var leaderboardScoreSuccess: SimpleSignal
    /// @Signal
    /// Error reporting the score
    @Signal var leaderboardScoreFail: SignalWithArguments<Int, String>
    /// @Signal
    /// Leaderboard has been shown
    @Signal var leaderboardSuccess: SimpleSignal
    /// @Signal
    /// Leaderboard had been dismissed
    @Signal var leaderboardDismissed: SimpleSignal
    /// @Signal
    /// Error showing the leaderboard
    @Signal var leaderboardFail: SignalWithArguments<Int, String>

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
    /// @Callable
    ///
    /// Authenticate with gameCenter.
    ///
    /// - Signals:
    ///     - signin_success: an instance of the GameCenterPlayerLocal is associated with the signal
    ///     - signin_fail: an error message is associated with the signal
    @Callable
    public func authenticate() {
        authenticateInternal()
    }

    /// @Callable
    ///
    /// - Returns:
    ///     - A Boolean value that indicates whether a local player has signed in to Game Center.
    @Callable
    func isAuthenticated() -> Bool {
        return isAuthenticatedInternal()
    }

    // MARK: Achievements
    /// @Callable
    ///
    /// Report an array of achievements to the server. Percent complete is required. Points, completed state are set based on percentComplete. isHidden is set to NO anytime this method is invoked. Date is optional. Error will be nil on success.
    /// Possible reasons for error:
    /// 1. Local player not authenticated
    /// 2. Communications failure
    /// 3. Reported Achievement does not exist
    ///
    /// - Signals:
    ///     - achievements_report_success: a signal with no parameters is raised
    ///     - achievements_report_fail: an error message is associated with the signal
    @Callable
    func reportAchievements(
        _ achievements: [GameCenterAchievement]
    ) {
        reportAchievementsInternal(achievements)
    }

    /// @Callable
    /// Reset the achievements progress for the local player. All the entries for the local player are removed from the server. Error will be nil on success.
    /// Possible reasons for error:
    /// 1. Local player not authenticated
    /// 2. Communications failure
    ///
    /// - Signals:
    ///     - achievements_reset_success: a signal with no parameters is raised
    ///     - achievements_reset_fail: an error message is associated with the signal
    @Callable
    func resetAchievements() {
        resetAchievementsInternal()
    }

    /// @Callable
    ///
    /// Load all achievements for the local player
    ///
    /// - Signals:
    ///     - achievements_load_success: the list of achievements for the local player with the signal
    ///     - achievements_load_fail: an error message is associated with the signal
    @Callable
    func loadAchievements() {
        loadAchievementsInternal()
    }

    /// @Callable
    /// Load all achievement descriptions
    ///
    /// - Signals:
    ///     - achievements_description_success: the list of description is associated with the signal
    ///     - achievements_descritpion_fail: an error message is associated with the signal
    @Callable
    func loadAchievementDescriptions() {
        loadAchievementDescriptionsInternal()
    }

    /// Show GameCenter leaderboard display.
    ///
    /// - Signals:
    ///     - leaderboard_shown: a signal with no parameters is raised
    ///     - leaderboard_dismissed: a signal with no parameters is raised
    ///     - leaderboard_fail: an error message is associated with the signal
    @Callable
    func showAchievements() {
        showAchievementsInternal()
    }

    /// Show GameCenter leaderboard for a specific achievement.
    ///
    /// - Parameters:
    ///     - leaderboardID: The identifier for the leaderboard that you enter in App Store Connect.
    ///
    /// - Signals:
    ///     - leaderboard_shown: a signal with no parameters is raised
    ///     - leaderboard_dismissed: a signal with no parameters is raised
    ///     - leaderboard_fail: an error message is associated with the signal
    @Callable
    func showAchievement(achievementID: String) {
        showAchievementInternal(achievementID: achievementID)
    }

    // MARK: Leaderboards
    /// @Callable
    ///
    /// Instance method to submit a single score to the leaderboard associated with this instance
    ///   score - earned by the player
    ///   leaderboardIds - to which the score should be submitted
    ///   context - developer supplied metadata associated with the player's score
    ///
    /// - Signals:
    ///     - achievements_report_success: a signal with no parameters is raised
    ///     - achievements_report_fail: an error message is associated with the signal
    @Callable
    func submitScore(
        score: Int, leaderboardIDs: [String], context: Int
    ) {
        submitScoreInternal(
            score, context: context,
            player: GKLocalPlayer.local,
            leaderboardIDs: leaderboardIDs)
    }

    /// Show GameCenter leaderboards display.
    ///
    /// - Signals:
    ///     - leaderboard_shown: a signal with no parameters is raised
    ///     - leaderboard_dismissed: a signal with no parameters is raised
    ///     - leaderboard_fail: an error message is associated with the signal
    @Callable
    func showLeaderboards() {
        showLeaderboardsInternal()
    }

    /// Show GameCenter leaderboard for a specific leaderboard.
    ///
    /// - Parameters:
    ///     - leaderboardID: The identifier for the leaderboard that you enter in App Store Connect.
    ///
    /// - Signals:
    ///     - leaderboard_shown: a signal with no parameters is raised
    ///     - leaderboard_dismissed: a signal with no parameters is raised
    ///     - leaderboard_fail: an error message is associated with the signal
    @Callable
    func showLeaderboard(leaderboardID: String) {
        showLeaderboardInternal(leaderboardID: leaderboardID)
    }
}
