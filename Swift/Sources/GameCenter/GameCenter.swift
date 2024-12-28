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

@Godot
class GameCenter: RefCounted {

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

    enum GameCenterError: Int, Error {
        case unknownError = 1
        case notAuthenticated = 2
        case notAvailable = 3
        case failedToAuthenticate = 4
        case failedToLoadPicture = 5
        case missingIdentifier = 6
    }

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
}
