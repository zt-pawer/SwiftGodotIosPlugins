import XCTest
@testable import GameCenter

class MockGameCenterService: GameCenterServiceProtocol {
    var isAuthenticatedValue = false
    var shouldSucceed = true
    
    var mockPlayerData = GameCenterLocalPlayerData(
        alias: "SwiftGamer",
        displayName: "SwiftGamer99",
        gamePlayerID: "game_id_123",
        teamPlayerID: "team_id_123",
        isUnderage: false,
        isMultiplayerGamingRestricted: false,
        isPersonalizedCommunicationRestricted: false
    )
    
    func authenticate(completion: @escaping (Result<GameCenterLocalPlayerData, Error>, AnyObject?) -> Void) {
        if shouldSucceed {
            isAuthenticatedValue = true
            completion(.success(mockPlayerData), nil)
        } else {
            let error = NSError(domain: "GameCenter", code: 4, userInfo: [NSLocalizedDescriptionKey: "Authentication failed"])
            completion(.failure(error), nil)
        }
    }
    
    func isAuthenticated() -> Bool {
        return isAuthenticatedValue
    }
    
    func reportAchievements(ids: [String], percentCompletes: [Double], showsCompletionBanners: [Bool], completion: @escaping (Error?) -> Void) {
        if shouldSucceed {
            completion(nil)
        } else {
            completion(NSError(domain: "GameCenter", code: 6, userInfo: nil))
        }
    }
    
    func resetAchievements(completion: @escaping (Error?) -> Void) {
        if shouldSucceed {
            completion(nil)
        } else {
            completion(NSError(domain: "GameCenter", code: 1, userInfo: nil))
        }
    }
    
    func loadAchievements(completion: @escaping (Result<[GameCenterAchievementData], Error>) -> Void) {
        if shouldSucceed {
            let player = GameCenterPlayerData(alias: "SwiftGamer", displayName: "SwiftGamer99", gamePlayerID: "game_id_123", teamPlayerID: "team_id_123", isInvitable: true)
            let achievement = GameCenterAchievementData(identifier: "ach_1", player: player, isCompleted: true, percentComplete: 100.0, showsCompletionBanner: true, lastReportedDate: 0.0)
            completion(.success([achievement]))
        } else {
            completion(.failure(NSError(domain: "GameCenter", code: 1, userInfo: nil)))
        }
    }
    
    func loadAchievementDescriptions(completion: @escaping (Result<[GameCenterAchievementDescriptionData], Error>) -> Void) {
        if shouldSucceed {
            let desc = GameCenterAchievementDescriptionData(identifier: "ach_1", groupIdentifier: "", title: "First Steps", unachievedDescription: "Take a step", achievedDescription: "You took a step", maximumPoints: 10, isHidden: false, isReplayable: false, rarityPercent: 95.0)
            completion(.success([desc]))
        } else {
            completion(.failure(NSError(domain: "GameCenter", code: 1, userInfo: nil)))
        }
    }
    
    func submitScore(score: Int, leaderboardIDs: [String], context: Int, completion: @escaping (Error?) -> Void) {
        if shouldSucceed {
            completion(nil)
        } else {
            completion(NSError(domain: "GameCenter", code: 1, userInfo: nil))
        }
    }
    
    func loadLeaderboardEntries(leaderboardID: String, playerScope: String, timeScope: String, rankMin: Int, rankMax: Int, completion: @escaping (Result<([GameCenterLeaderboardEntryData], Int), Error>) -> Void) {
        if shouldSucceed {
            let player = GameCenterPlayerData(alias: "SwiftGamer", displayName: "SwiftGamer99", gamePlayerID: "game_id_123", teamPlayerID: "team_id_123", isInvitable: true)
            let entry = GameCenterLeaderboardEntryData(player: player, score: 9999, rank: 1, context: 0)
            completion(.success(([entry], 1)))
        } else {
            completion(.failure(NSError(domain: "GameCenter", code: 1, userInfo: nil)))
        }
    }
    
    func loadPlayerScore(leaderboardID: String, timeScope: String, completion: @escaping (Result<GameCenterLeaderboardEntryData, Error>) -> Void) {
        if shouldSucceed {
            let player = GameCenterPlayerData(alias: "SwiftGamer", displayName: "SwiftGamer99", gamePlayerID: "game_id_123", teamPlayerID: "team_id_123", isInvitable: true)
            let entry = GameCenterLeaderboardEntryData(player: player, score: 9999, rank: 1, context: 0)
            completion(.success(entry))
        } else {
            completion(.failure(NSError(domain: "GameCenter", code: 1, userInfo: nil)))
        }
    }
}

final class GameCenterTests: XCTestCase {
    func testGameCenterErrorEnum() {
        XCTAssertEqual(GameCenterError.unknownError.rawValue, 1)
        XCTAssertEqual(GameCenterError.notAuthenticated.rawValue, 2)
        XCTAssertEqual(GameCenterError.notAvailable.rawValue, 3)
        XCTAssertEqual(GameCenterError.failedToAuthenticate.rawValue, 4)
        XCTAssertEqual(GameCenterError.failedToLoadPicture.rawValue, 5)
        XCTAssertEqual(GameCenterError.missingIdentifier.rawValue, 6)
    }
    
    func testGameCenterServiceAuthSuccess() {
        let service = MockGameCenterService()
        XCTAssertFalse(service.isAuthenticated())
        
        let expectation = self.expectation(description: "Auth success expectation")
        service.authenticate { result, _ in
            switch result {
            case .success(let data):
                XCTAssertEqual(data.alias, "SwiftGamer")
                XCTAssertEqual(data.gamePlayerID, "game_id_123")
            case .failure(let error):
                XCTFail("Should not fail: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        XCTAssertTrue(service.isAuthenticated())
    }
    
    func testGameCenterServiceAuthFailure() {
        let service = MockGameCenterService()
        service.shouldSucceed = false
        
        let expectation = self.expectation(description: "Auth failure expectation")
        service.authenticate { result, _ in
            switch result {
            case .success:
                XCTFail("Should not succeed")
            case .failure(let error):
                XCTAssertEqual((error as NSError).code, 4)
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        XCTAssertFalse(service.isAuthenticated())
    }
}
