import Foundation
import GameKit

#if canImport(UIKit)
import UIKit
#endif

// MARK: - GameCenter Struct Data Models (Pure Swift)

public struct GameCenterPlayerData {
    public let alias: String
    public let displayName: String
    public let gamePlayerID: String
    public let teamPlayerID: String
    public let isInvitable: Bool
    
    public init(alias: String, displayName: String, gamePlayerID: String, teamPlayerID: String, isInvitable: Bool) {
        self.alias = alias
        self.displayName = displayName
        self.gamePlayerID = gamePlayerID
        self.teamPlayerID = teamPlayerID
        self.isInvitable = isInvitable
    }
}

public struct GameCenterLocalPlayerData {
    public let alias: String
    public let displayName: String
    public let gamePlayerID: String
    public let teamPlayerID: String
    public let isUnderage: Bool
    public let isMultiplayerGamingRestricted: Bool
    public let isPersonalizedCommunicationRestricted: Bool
    
    public init(alias: String, displayName: String, gamePlayerID: String, teamPlayerID: String, isUnderage: Bool, isMultiplayerGamingRestricted: Bool, isPersonalizedCommunicationRestricted: Bool) {
        self.alias = alias
        self.displayName = displayName
        self.gamePlayerID = gamePlayerID
        self.teamPlayerID = teamPlayerID
        self.isUnderage = isUnderage
        self.isMultiplayerGamingRestricted = isMultiplayerGamingRestricted
        self.isPersonalizedCommunicationRestricted = isPersonalizedCommunicationRestricted
    }
}

public struct GameCenterAchievementData {
    public let identifier: String
    public let player: GameCenterPlayerData
    public let isCompleted: Bool
    public let percentComplete: Double
    public let showsCompletionBanner: Bool
    public let lastReportedDate: Double
    
    public init(identifier: String, player: GameCenterPlayerData, isCompleted: Bool, percentComplete: Double, showsCompletionBanner: Bool, lastReportedDate: Double) {
        self.identifier = identifier
        self.player = player
        self.isCompleted = isCompleted
        self.percentComplete = percentComplete
        self.showsCompletionBanner = showsCompletionBanner
        self.lastReportedDate = lastReportedDate
    }
}

public struct GameCenterAchievementDescriptionData {
    public let identifier: String
    public let groupIdentifier: String
    public let title: String
    public let unachievedDescription: String
    public let achievedDescription: String
    public let maximumPoints: Int
    public let isHidden: Bool
    public let isReplayable: Bool
    public let rarityPercent: Double
    
    public init(identifier: String, groupIdentifier: String, title: String, unachievedDescription: String, achievedDescription: String, maximumPoints: Int, isHidden: Bool, isReplayable: Bool, rarityPercent: Double) {
        self.identifier = identifier
        self.groupIdentifier = groupIdentifier
        self.title = title
        self.unachievedDescription = unachievedDescription
        self.achievedDescription = achievedDescription
        self.maximumPoints = maximumPoints
        self.isHidden = isHidden
        self.isReplayable = isReplayable
        self.rarityPercent = rarityPercent
    }
}

public struct GameCenterLeaderboardEntryData {
    public let player: GameCenterPlayerData
    public let score: Int
    public let rank: Int
    public let context: Int
    
    public init(player: GameCenterPlayerData, score: Int, rank: Int, context: Int) {
        self.player = player
        self.score = score
        self.rank = rank
        self.context = context
    }
}

// MARK: - GameCenterService Protocol

public protocol GameCenterServiceProtocol {
    func authenticate(completion: @escaping (Result<GameCenterLocalPlayerData, Error>, AnyObject?) -> Void)
    func isAuthenticated() -> Bool
    func reportAchievements(ids: [String], percentCompletes: [Double], showsCompletionBanners: [Bool], completion: @escaping (Error?) -> Void)
    func resetAchievements(completion: @escaping (Error?) -> Void)
    func loadAchievements(completion: @escaping (Result<[GameCenterAchievementData], Error>) -> Void)
    func loadAchievementDescriptions(completion: @escaping (Result<[GameCenterAchievementDescriptionData], Error>) -> Void)
    func submitScore(score: Int, leaderboardIDs: [String], context: Int, completion: @escaping (Error?) -> Void)
    func loadLeaderboardEntries(leaderboardID: String, playerScope: String, timeScope: String, rankMin: Int, rankMax: Int, completion: @escaping (Result<([GameCenterLeaderboardEntryData], Int), Error>) -> Void)
    func loadPlayerScore(leaderboardID: String, timeScope: String, completion: @escaping (Result<GameCenterLeaderboardEntryData, Error>) -> Void)
    
    #if canImport(UIKit)
    func showAchievements(viewController: UIViewController, completion: @escaping (Int) -> Void)
    func showAchievement(achievementID: String, viewController: UIViewController, completion: @escaping (Int) -> Void)
    func showLeaderboards(viewController: UIViewController, completion: @escaping (Int) -> Void)
    func showLeaderboard(leaderboardID: String, viewController: UIViewController, completion: @escaping (Int) -> Void)
    #endif
}

// MARK: - GameCenterService Concrete Implementation

public final class GameCenterService: NSObject, GameCenterServiceProtocol {
    
    #if canImport(UIKit)
    private var uiCompletion: ((Int) -> Void)?
    #endif
    
    public func authenticate(completion: @escaping (Result<GameCenterLocalPlayerData, Error>, AnyObject?) -> Void) {
        if GKLocalPlayer.local.isAuthenticated {
            let player = GKLocalPlayer.local
            let localData = GameCenterLocalPlayerData(
                alias: player.alias,
                displayName: player.displayName,
                gamePlayerID: player.gamePlayerID,
                teamPlayerID: player.teamPlayerID,
                isUnderage: player.isUnderage,
                isMultiplayerGamingRestricted: player.isMultiplayerGamingRestricted,
                isPersonalizedCommunicationRestricted: player.isPersonalizedCommunicationRestricted
            )
            completion(.success(localData), nil)
            return
        }
        
        #if os(iOS)
        GKLocalPlayer.local.authenticateHandler = { loginController, error in
            if let loginController = loginController {
                completion(.failure(NSError(domain: "GameCenter", code: -3, userInfo: [NSLocalizedDescriptionKey: "Requires login controller present"])), loginController)
                return
            }
            
            if let error = error {
                completion(.failure(error), nil)
                return
            }
            
            let player = GKLocalPlayer.local
            let localData = GameCenterLocalPlayerData(
                alias: player.alias,
                displayName: player.displayName,
                gamePlayerID: player.gamePlayerID,
                teamPlayerID: player.teamPlayerID,
                isUnderage: player.isUnderage,
                isMultiplayerGamingRestricted: player.isMultiplayerGamingRestricted,
                isPersonalizedCommunicationRestricted: player.isPersonalizedCommunicationRestricted
            )
            completion(.success(localData), nil)
        }
        #else
        let notAvail = NSError(domain: "GameCenter", code: 3, userInfo: [NSLocalizedDescriptionKey: "GameCenter not available on this platform"])
        completion(.failure(notAvail), nil)
        #endif
    }
    
    public func isAuthenticated() -> Bool {
        #if os(iOS)
        return GKLocalPlayer.local.isAuthenticated
        #else
        return false
        #endif
    }
    
    public func reportAchievements(ids: [String], percentCompletes: [Double], showsCompletionBanners: [Bool], completion: @escaping (Error?) -> Void) {
        guard ids.count > 0 else {
            completion(NSError(domain: "GameCenter", code: 6, userInfo: [NSLocalizedDescriptionKey: "No achievements provided"]))
            return
        }
        
        var gkAchievements: [GKAchievement] = []
        for index in 0..<ids.count {
            let identifier = ids[index]
            guard !identifier.isEmpty else {
                completion(NSError(domain: "GameCenter", code: 6, userInfo: [NSLocalizedDescriptionKey: "Achievement without identifier"]))
                return
            }
            let gkAchievement = GKAchievement(identifier: identifier)
            gkAchievement.percentComplete = percentCompletes[index]
            gkAchievement.showsCompletionBanner = showsCompletionBanners[index]
            gkAchievements.append(gkAchievement)
        }
        
        GKAchievement.report(gkAchievements) { error in
            completion(error)
        }
    }
    
    public func resetAchievements(completion: @escaping (Error?) -> Void) {
        GKAchievement.resetAchievements { error in
            completion(error)
        }
    }
    
    public func loadAchievements(completion: @escaping (Result<[GameCenterAchievementData], Error>) -> Void) {
        GKAchievement.loadAchievements { gkAchievements, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            var result: [GameCenterAchievementData] = []
            if let gkAchievements = gkAchievements {
                for gk in gkAchievements {
                    let player = gk.player
                    let playerData = GameCenterPlayerData(
                        alias: player.alias,
                        displayName: player.displayName,
                        gamePlayerID: player.gamePlayerID,
                        teamPlayerID: player.teamPlayerID,
                        isInvitable: player.isInvitable
                    )
                    let data = GameCenterAchievementData(
                        identifier: gk.identifier,
                        player: playerData,
                        isCompleted: gk.isCompleted,
                        percentComplete: gk.percentComplete,
                        showsCompletionBanner: gk.showsCompletionBanner,
                        lastReportedDate: gk.lastReportedDate.timeIntervalSince1970
                    )
                    result.append(data)
                }
            }
            completion(.success(result))
        }
    }
    
    public func loadAchievementDescriptions(completion: @escaping (Result<[GameCenterAchievementDescriptionData], Error>) -> Void) {
        GKAchievementDescription.loadAchievementDescriptions { descriptions, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            var result: [GameCenterAchievementDescriptionData] = []
            if let descriptions = descriptions {
                for desc in descriptions {
                    var rarity: Double = 0.0
                    if #available(iOS 17, macOS 14, *), let rarityPercent = desc.rarityPercent {
                        rarity = rarityPercent
                    }
                    let data = GameCenterAchievementDescriptionData(
                        identifier: desc.identifier,
                        groupIdentifier: desc.groupIdentifier ?? "",
                        title: desc.title,
                        unachievedDescription: desc.unachievedDescription,
                        achievedDescription: desc.achievedDescription,
                        maximumPoints: desc.maximumPoints,
                        isHidden: desc.isHidden,
                        isReplayable: desc.isReplayable,
                        rarityPercent: rarity
                    )
                    result.append(data)
                }
            }
            completion(.success(result))
        }
    }
    
    public func submitScore(score: Int, leaderboardIDs: [String], context: Int, completion: @escaping (Error?) -> Void) {
        #if os(iOS)
        guard GKLocalPlayer.local.isAuthenticated else {
            completion(NSError(domain: "GameCenter", code: 2, userInfo: [NSLocalizedDescriptionKey: "Player is not authenticated"]))
            return
        }
        GKLeaderboard.submitScore(score, context: context, player: GKLocalPlayer.local, leaderboardIDs: leaderboardIDs) { error in
            completion(error)
        }
        #else
        completion(NSError(domain: "GameCenter", code: 3, userInfo: [NSLocalizedDescriptionKey: "Not available"]))
        #endif
    }
    
    public func loadLeaderboardEntries(leaderboardID: String, playerScope: String, timeScope: String, rankMin: Int, rankMax: Int, completion: @escaping (Result<([GameCenterLeaderboardEntryData], Int), Error>) -> Void) {
        #if os(iOS)
        guard GKLocalPlayer.local.isAuthenticated else {
            completion(.failure(NSError(domain: "GameCenter", code: 2, userInfo: [NSLocalizedDescriptionKey: "Player is not authenticated"])))
            return
        }
        
        let gkPlayerScope: GKLeaderboard.PlayerScope = (playerScope == "friendsOnly") ? .friendsOnly : .global
        let gkTimeScope: GKLeaderboard.TimeScope
        switch timeScope {
        case "today": gkTimeScope = .today
        case "week": gkTimeScope = .week
        default: gkTimeScope = .allTime
        }
        
        GKLeaderboard.loadLeaderboards(IDs: [leaderboardID]) { leaderboards, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let leaderboard = leaderboards?.first else {
                completion(.failure(NSError(domain: "GameCenter", code: 6, userInfo: [NSLocalizedDescriptionKey: "Failed to load leaderboard"])))
                return
            }
            
            let range = NSRange(location: rankMin, length: rankMax - rankMin + 1)
            leaderboard.loadEntries(for: gkPlayerScope, timeScope: gkTimeScope, range: range) { _, entries, totalCount, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                var result: [GameCenterLeaderboardEntryData] = []
                if let entries = entries {
                    for entry in entries {
                        let player = entry.player
                        let playerData = GameCenterPlayerData(
                            alias: player.alias,
                            displayName: player.displayName,
                            gamePlayerID: player.gamePlayerID,
                            teamPlayerID: player.teamPlayerID,
                            isInvitable: player.isInvitable
                        )
                        let entryData = GameCenterLeaderboardEntryData(
                            player: playerData,
                            score: entry.score,
                            rank: entry.rank,
                            context: entry.context
                        )
                        result.append(entryData)
                    }
                }
                completion(.success((result, totalCount)))
            }
        }
        #else
        completion(.failure(NSError(domain: "GameCenter", code: 3, userInfo: [NSLocalizedDescriptionKey: "Not available"])))
        #endif
    }
    
    public func loadPlayerScore(leaderboardID: String, timeScope: String, completion: @escaping (Result<GameCenterLeaderboardEntryData, Error>) -> Void) {
        #if os(iOS)
        guard GKLocalPlayer.local.isAuthenticated else {
            completion(.failure(NSError(domain: "GameCenter", code: 2, userInfo: [NSLocalizedDescriptionKey: "Player is not authenticated"])))
            return
        }
        
        let gkTimeScope: GKLeaderboard.TimeScope
        switch timeScope {
        case "today": gkTimeScope = .today
        case "week": gkTimeScope = .week
        default: gkTimeScope = .allTime
        }
        
        GKLeaderboard.loadLeaderboards(IDs: [leaderboardID]) { leaderboards, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let leaderboard = leaderboards?.first else {
                completion(.failure(NSError(domain: "GameCenter", code: 6, userInfo: [NSLocalizedDescriptionKey: "Failed to load leaderboard"])))
                return
            }
            
            leaderboard.loadEntries(for: [GKLocalPlayer.local], timeScope: gkTimeScope) { localEntry, _, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let localEntry = localEntry else {
                    completion(.failure(NSError(domain: "GameCenter", code: 6, userInfo: [NSLocalizedDescriptionKey: "No score found for player"])))
                    return
                }
                
                let player = localEntry.player
                let playerData = GameCenterPlayerData(
                    alias: player.alias,
                    displayName: player.displayName,
                    gamePlayerID: player.gamePlayerID,
                    teamPlayerID: player.teamPlayerID,
                    isInvitable: player.isInvitable
                )
                let entryData = GameCenterLeaderboardEntryData(
                    player: playerData,
                    score: localEntry.score,
                    rank: localEntry.rank,
                    context: localEntry.context
                )
                completion(.success(entryData))
            }
        }
        #else
        completion(.failure(NSError(domain: "GameCenter", code: 3, userInfo: [NSLocalizedDescriptionKey: "Not available"])))
        #endif
    }
    
    #if canImport(UIKit)
    public func showAchievements(viewController: UIViewController, completion: @escaping (Int) -> Void) {
        self.uiCompletion = completion
        let gameCenterVC = GKGameCenterViewController(state: .achievements)
        gameCenterVC.gameCenterDelegate = self
        viewController.present(gameCenterVC, animated: true)
    }
    
    public func showAchievement(achievementID: String, viewController: UIViewController, completion: @escaping (Int) -> Void) {
        self.uiCompletion = completion
        let gameCenterVC = GKGameCenterViewController(achievementID: achievementID)
        gameCenterVC.gameCenterDelegate = self
        viewController.present(gameCenterVC, animated: true)
    }
    
    public func showLeaderboards(viewController: UIViewController, completion: @escaping (Int) -> Void) {
        self.uiCompletion = completion
        let gameCenterVC = GKGameCenterViewController(state: .leaderboards)
        gameCenterVC.gameCenterDelegate = self
        viewController.present(gameCenterVC, animated: true)
    }
    
    public func showLeaderboard(leaderboardID: String, viewController: UIViewController, completion: @escaping (Int) -> Void) {
        self.uiCompletion = completion
        let gameCenterVC = GKGameCenterViewController(leaderboardID: leaderboardID, playerScope: .global, timeScope: .allTime)
        gameCenterVC.gameCenterDelegate = self
        viewController.present(gameCenterVC, animated: true)
    }
    #endif
}

#if canImport(UIKit)
extension GameCenterService: GKGameCenterControllerDelegate {
    public func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true) {
            self.uiCompletion?(1) // 1 = success / dismissed callback status
        }
    }
}
#endif
