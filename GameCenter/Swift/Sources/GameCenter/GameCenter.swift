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
        GameCenterLeaderboardEntry.self,
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
        SignalWithArguments<TypedArray<GameCenterAchievement?>>
    /// @Signal
    /// Error loading the achievements
    @Signal var achievementsLoadFail: SignalWithArguments<Int, String>
    /// @Signal
    /// Achievement(s) have been successfully reported
    @Signal var achievementsDescriptionSuccess:
        SignalWithArguments<TypedArray<GameCenterAchievementDescription?>>
    /// @Signal
    /// Error reporting the achievements
    @Signal var achievementsDescriptionFail: SignalWithArguments<Int, String>

    // MARK: Leaderboards
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
    /// @Signal
    /// Score(s) have been successfully reported - includes leaderboard ID for in-game tracking
    @Signal var leaderboardScoreIngameSuccess: SignalWithArguments<String>
    /// @Signal
    /// Error reporting the score - includes leaderboard ID for in-game tracking
    @Signal var leaderboardScoreIngameFail: SignalWithArguments<Int, String, String>
    /// @Signal
    /// Leaderboard entries have been successfully loaded - includes leaderboard ID
    @Signal var leaderboardEntriesLoadSuccess: SignalWithArguments<TypedArray<GameCenterLeaderboardEntry?>, Int, String>
    /// @Signal
    /// Error loading leaderboard entries - includes leaderboard ID
    @Signal var leaderboardEntriesLoadFail: SignalWithArguments<Int, String, String>
    /// @Signal
    /// Player's score and rank have been successfully loaded - includes leaderboard ID
    @Signal var leaderboardPlayerScoreLoadSuccess: SignalWithArguments<GameCenterLeaderboardEntry?, String>
    /// @Signal
    /// Error loading player's score - includes leaderboard ID
    @Signal var leaderboardPlayerScoreLoadFail: SignalWithArguments<Int, String, String>
    
    #if canImport(UIKit)
        var viewController: GameCenterViewController = GameCenterViewController()
    #endif

    static var shared: GameCenter?
    var player: GameCenterPlayerLocal?
    private var service: GameCenterServiceProtocol

    required init(_ context: InitContext) {
        self.service = GameCenterService()
        super.init(context)
        GameCenter.shared = self
    }

    // MARK: Authentication
    /// @Callable
    /// Authenticate with gameCenter.
    @Callable
    public func authenticate() {
        service.authenticate { [weak self] result, presentationVC in
            guard let self = self else { return }
            
            #if os(iOS) && canImport(UIKit)
            if let presentationVC = presentationVC as? UIViewController {
                self.viewController.getRootController()?.present(presentationVC, animated: true)
                return
            }
            #endif
            
            switch result {
            case .success(let data):
                let localPlayer = GameCenterPlayerLocal()
                localPlayer.alias = data.alias
                localPlayer.displayName = data.displayName
                localPlayer.gamePlayerID = data.gamePlayerID
                localPlayer.teamPlayerID = data.teamPlayerID
                localPlayer.isUnderage = data.isUnderage
                localPlayer.isMultiplayerGamingRestricted = data.isMultiplayerGamingRestricted
                localPlayer.isPersonalizedCommunicationRestricted = data.isPersonalizedCommunicationRestricted
                
                self.player = localPlayer
                self.signinSuccess.emit(localPlayer)
                
            case .failure(let error):
                self.signinFail.emit((error as NSError).code, error.localizedDescription)
            }
        }
    }

    /// @Callable
    /// Returns true if a local player has signed in.
    @Callable
    func isAuthenticated() -> Bool {
        return service.isAuthenticated()
    }

    // MARK: Achievements
    /// @Callable
    /// Report an array of achievements.
    @Callable
    func reportAchievements(_ achievements: TypedArray<GameCenterAchievement?>) {
        var ids: [String] = []
        var percents: [Double] = []
        var banners: [Bool] = []
        
        for achOpt in achievements {
            if let ach = achOpt {
                ids.append(ach.identifier)
                percents.append(ach.percentComplete)
                banners.append(ach.showsCompletionBanner)
            }
        }
        
        service.reportAchievements(ids: ids, percentCompletes: percents, showsCompletionBanners: banners) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.achievementsReportFail.emit((error as NSError).code, error.localizedDescription)
            } else {
                self.achievementsReportSuccess.emit()
            }
        }
    }

    /// @Callable
    /// Reset achievements progress.
    @Callable
    func resetAchievements() {
        service.resetAchievements { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.achievementsResetFail.emit((error as NSError).code, error.localizedDescription)
            } else {
                self.achievementsResetSuccess.emit()
            }
        }
    }

    /// @Callable
    /// Load achievements.
    @Callable
    func loadAchievements() {
        service.loadAchievements { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let list):
                var achievements = TypedArray<GameCenterAchievement?>()
                for data in list {
                    let ach = GameCenterAchievement()
                    ach.identifier = data.identifier
                    ach.percentComplete = data.percentComplete
                    ach.showsCompletionBanner = data.showsCompletionBanner
                    ach.isCompleted = data.isCompleted
                    ach.lastReportedDate = data.lastReportedDate
                    
                    let p = GameCenterPlayer()
                    p.alias = data.player.alias
                    p.displayName = data.player.displayName
                    p.gamePlayerID = data.player.gamePlayerID
                    p.teamPlayerID = data.player.teamPlayerID
                    p.isInvitable = data.player.isInvitable
                    ach.player = p
                    
                    achievements.append(ach)
                }
                self.achievementsLoadSuccess.emit(achievements)
            case .failure(let error):
                self.achievementsLoadFail.emit((error as NSError).code, error.localizedDescription)
            }
        }
    }

    /// @Callable
    /// Load achievement descriptions.
    @Callable
    func loadAchievementDescriptions() {
        service.loadAchievementDescriptions { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let list):
                var descriptions = TypedArray<GameCenterAchievementDescription?>()
                for data in list {
                    let desc = GameCenterAchievementDescription()
                    desc.identifier = data.identifier
                    desc.groupIdentifier = data.groupIdentifier
                    desc.title = data.title
                    desc.unachievedDescription = data.unachievedDescription
                    desc.achievedDescription = data.achievedDescription
                    desc.maximumPoints = data.maximumPoints
                    desc.isHidden = data.isHidden
                    desc.isReplayable = data.isReplayable
                    desc.rarityPercent = data.rarityPercent
                    descriptions.append(desc)
                }
                self.achievementsDescriptionSuccess.emit(descriptions)
            case .failure(let error):
                self.achievementsDescriptionFail.emit((error as NSError).code, error.localizedDescription)
            }
        }
    }

    /// Show GameCenter achievements display.
    @Callable
    func showAchievements() {
        #if canImport(UIKit)
        if let root = viewController.getRootController() {
            service.showAchievements(viewController: root) { [weak self] status in
                guard let self = self else { return }
                if status == 1 {
                    self.leaderboardSuccess.emit()
                    self.leaderboardDismissed.emit()
                } else {
                    self.leaderboardFail.emit(GameCenterError.unknownError.rawValue, "Unknown error")
                }
            }
        }
        #endif
    }

    /// Show GameCenter achievement display for a specific achievement.
    @Callable
    func showAchievement(achievementID: String) {
        #if canImport(UIKit)
        if let root = viewController.getRootController() {
            service.showAchievement(achievementID: achievementID, viewController: root) { [weak self] status in
                guard let self = self else { return }
                if status == 1 {
                    self.leaderboardSuccess.emit()
                    self.leaderboardDismissed.emit()
                } else {
                    self.leaderboardFail.emit(GameCenterError.unknownError.rawValue, "Unknown error")
                }
            }
        }
        #endif
    }

    // MARK: Leaderboards
    /// @Callable
    /// Submit a score.
    @Callable
    func submitScore(score: Int, leaderboardIDs: [String], context: Int) {
        service.submitScore(score: score, leaderboardIDs: leaderboardIDs, context: context) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.leaderboardScoreFail.emit((error as NSError).code, error.localizedDescription)
                self.leaderboardScoreIngameFail.emit((error as NSError).code, error.localizedDescription, leaderboardIDs.joined(separator: ","))
            } else {
                self.leaderboardScoreSuccess.emit()
                self.leaderboardScoreIngameSuccess.emit(leaderboardIDs.joined(separator: ","))
            }
        }
    }

    /// Show GameCenter leaderboards display.
    @Callable
    func showLeaderboards() {
        #if canImport(UIKit)
        if let root = viewController.getRootController() {
            service.showLeaderboards(viewController: root) { [weak self] status in
                guard let self = self else { return }
                if status == 1 {
                    self.leaderboardSuccess.emit()
                    self.leaderboardDismissed.emit()
                } else {
                    self.leaderboardFail.emit(GameCenterError.unknownError.rawValue, "Unknown error")
                }
            }
        }
        #endif
    }

    /// Show GameCenter leaderboard for a specific leaderboard.
    @Callable
    func showLeaderboard(leaderboardID: String) {
        #if canImport(UIKit)
        if let root = viewController.getRootController() {
            service.showLeaderboard(leaderboardID: leaderboardID, viewController: root) { [weak self] status in
                guard let self = self else { return }
                if status == 1 {
                    self.leaderboardSuccess.emit()
                    self.leaderboardDismissed.emit()
                } else {
                    self.leaderboardFail.emit(GameCenterError.unknownError.rawValue, "Unknown error")
                }
            }
        }
        #endif
    }
    
    /// @Callable
    /// Load entries from a leaderboard.
    @Callable
    func loadLeaderboardEntries(leaderboardID: String, playerScope: String, timeScope: String, rankMin: Int, rankMax: Int) {
        service.loadLeaderboardEntries(leaderboardID: leaderboardID, playerScope: playerScope, timeScope: timeScope, rankMin: rankMin, rankMax: rankMax) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success((let list, let totalCount)):
                var entries = TypedArray<GameCenterLeaderboardEntry?>()
                for data in list {
                    let entry = GameCenterLeaderboardEntry()
                    entry.score = data.score
                    entry.rank = data.rank
                    entry.context = data.context
                    
                    let p = GameCenterPlayer()
                    p.alias = data.player.alias
                    p.displayName = data.player.displayName
                    p.gamePlayerID = data.player.gamePlayerID
                    p.teamPlayerID = data.player.teamPlayerID
                    p.isInvitable = data.player.isInvitable
                    entry.player = p
                    
                    entries.append(entry)
                }
                self.leaderboardEntriesLoadSuccess.emit(entries, totalCount, leaderboardID)
            case .failure(let error):
                self.leaderboardEntriesLoadFail.emit((error as NSError).code, error.localizedDescription, leaderboardID)
            }
        }
    }

    /// @Callable
    /// Load local player score.
    @Callable
    func loadPlayerScore(leaderboardID: String, timeScope: String) {
        service.loadPlayerScore(leaderboardID: leaderboardID, timeScope: timeScope) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                let entry = GameCenterLeaderboardEntry()
                entry.score = data.score
                entry.rank = data.rank
                entry.context = data.context
                
                let p = GameCenterPlayer()
                p.alias = data.player.alias
                p.displayName = data.player.displayName
                p.gamePlayerID = data.player.gamePlayerID
                p.teamPlayerID = data.player.teamPlayerID
                p.isInvitable = data.player.isInvitable
                entry.player = p
                
                self.leaderboardPlayerScoreLoadSuccess.emit(entry, leaderboardID)
            case .failure(let error):
                self.leaderboardPlayerScoreLoadFail.emit((error as NSError).code, error.localizedDescription, leaderboardID)
            }
        }
    }
}
