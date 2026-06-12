import XCTest
@testable import GodotFirebase

// 1. Mock implementation of the FirebaseAuthProvider (Option A Mock)
class MockFirebaseAuthProvider: FirebaseAuthProvider {
    var mockUid: String? = nil
    var mockError: Error? = nil
    var signOutCalled = false
    
    var currentUserUid: String? {
        return mockUid
    }
    
    func signInAnonymously(completion: @escaping (String?, Error?) -> Void) {
        completion(mockUid, mockError)
    }
    
    func signOut() throws {
        signOutCalled = true
        if let mockError = mockError {
            throw mockError
        }
        mockUid = nil
    }
}

final class GodotFirebaseTests: XCTestCase {
    func testFirebaseServiceDefaultState() {
        let service = FirebaseService.shared
        XCTAssertFalse(service.isConfigured(), "Firebase should not be configured by default in unit tests.")
    }
    
    func testFirebaseAuthServiceDefaultState() {
        let authService = FirebaseAuthService()
        XCTAssertFalse(authService.isUserSignedIn(), "User should not be signed in by default in unit tests.")
        XCTAssertEqual(authService.getCurrentUserUid(), "", "Current user UID should be empty by default.")
    }
    
    func testFirebaseAuthServiceSignInSuccess() {
        // Arrange
        let mockProvider = MockFirebaseAuthProvider()
        mockProvider.mockUid = "happy_player_999"
        let authService = FirebaseAuthService(authProvider: mockProvider)
        
        let expectation = self.expectation(description: "Sign in success expectation")
        
        // Act
        authService.signInAnonymously { result in
            // Assert
            switch result {
            case .success(let uid):
                XCTAssertEqual(uid, "happy_player_999")
            case .failure(let error):
                XCTFail("Should not fail: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        XCTAssertTrue(authService.isUserSignedIn())
        XCTAssertEqual(authService.getCurrentUserUid(), "happy_player_999")
    }
    
    func testFirebaseAuthServiceSignInFailure() {
        // Arrange
        let mockProvider = MockFirebaseAuthProvider()
        let expectedError = NSError(domain: "test", code: 42, userInfo: [NSLocalizedDescriptionKey: "Network failure"])
        mockProvider.mockError = expectedError
        let authService = FirebaseAuthService(authProvider: mockProvider)
        
        let expectation = self.expectation(description: "Sign in failure expectation")
        
        // Act
        authService.signInAnonymously { result in
            // Assert
            switch result {
            case .success:
                XCTFail("Should not succeed on error")
            case .failure(let error):
                XCTAssertEqual((error as NSError).code, 42)
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        XCTAssertFalse(authService.isUserSignedIn())
    }
    
    func testFirebaseAuthServiceSignOut() {
        // Arrange
        let mockProvider = MockFirebaseAuthProvider()
        mockProvider.mockUid = "active_user"
        let authService = FirebaseAuthService(authProvider: mockProvider)
        XCTAssertTrue(authService.isUserSignedIn())
        
        let expectation = self.expectation(description: "Sign out expectation")
        
        // Act
        authService.signOut { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        XCTAssertTrue(mockProvider.signOutCalled)
        XCTAssertFalse(authService.isUserSignedIn())
    }
}
