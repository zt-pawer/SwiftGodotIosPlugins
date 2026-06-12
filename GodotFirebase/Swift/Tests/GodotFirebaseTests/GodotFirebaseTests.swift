import XCTest
@testable import GodotFirebase

// Mock implementation of the FirebaseAuthProvider
class MockFirebaseAuthProvider: FirebaseAuthProvider {
    var mockUid: String? = nil
    var mockError: Error? = nil
    var signOutCalled = false
    
    var lastAppleIdToken: String?
    var lastAppleNonce: String?
    var lastGoogleIdToken: String?
    var lastGoogleAccessToken: String?
    var lastFacebookAccessToken: String?
    
    var linkAppleCalled = false
    var linkGoogleCalled = false
    var linkFacebookCalled = false
    
    var signInGameCenterCalled = false
    var linkGameCenterCalled = false
    
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
    
    func signInWithApple(idToken: String, rawNonce: String, completion: @escaping (String?, Error?) -> Void) {
        lastAppleIdToken = idToken
        lastAppleNonce = rawNonce
        completion(mockUid, mockError)
    }
    
    func linkWithApple(idToken: String, rawNonce: String, completion: @escaping (String?, Error?) -> Void) {
        linkAppleCalled = true
        lastAppleIdToken = idToken
        lastAppleNonce = rawNonce
        completion(mockUid, mockError)
    }
    
    func signInWithGoogle(idToken: String, accessToken: String, completion: @escaping (String?, Error?) -> Void) {
        lastGoogleIdToken = idToken
        lastGoogleAccessToken = accessToken
        completion(mockUid, mockError)
    }
    
    func linkWithGoogle(idToken: String, accessToken: String, completion: @escaping (String?, Error?) -> Void) {
        linkGoogleCalled = true
        lastGoogleIdToken = idToken
        lastGoogleAccessToken = accessToken
        completion(mockUid, mockError)
    }
    
    func signInWithFacebook(accessToken: String, completion: @escaping (String?, Error?) -> Void) {
        lastFacebookAccessToken = accessToken
        completion(mockUid, mockError)
    }
    
    func linkWithFacebook(accessToken: String, completion: @escaping (String?, Error?) -> Void) {
        linkFacebookCalled = true
        lastFacebookAccessToken = accessToken
        completion(mockUid, mockError)
    }
    
    func signInWithGameCenter(completion: @escaping (String?, Error?) -> Void) {
        signInGameCenterCalled = true
        completion(mockUid, mockError)
    }
    
    func linkWithGameCenter(completion: @escaping (String?, Error?) -> Void) {
        linkGameCenterCalled = true
        completion(mockUid, mockError)
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
        let mockProvider = MockFirebaseAuthProvider()
        mockProvider.mockUid = "happy_player_999"
        let authService = FirebaseAuthService(authProvider: mockProvider)
        
        let expectation = self.expectation(description: "Sign in success expectation")
        
        authService.signInAnonymously { result in
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
        let mockProvider = MockFirebaseAuthProvider()
        let expectedError = NSError(domain: "test", code: 42, userInfo: [NSLocalizedDescriptionKey: "Network failure"])
        mockProvider.mockError = expectedError
        let authService = FirebaseAuthService(authProvider: mockProvider)
        
        let expectation = self.expectation(description: "Sign in failure expectation")
        
        authService.signInAnonymously { result in
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
        let mockProvider = MockFirebaseAuthProvider()
        mockProvider.mockUid = "active_user"
        let authService = FirebaseAuthService(authProvider: mockProvider)
        XCTAssertTrue(authService.isUserSignedIn())
        
        let expectation = self.expectation(description: "Sign out expectation")
        
        authService.signOut { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        XCTAssertTrue(mockProvider.signOutCalled)
        XCTAssertFalse(authService.isUserSignedIn())
    }
    
    func testFirebaseAuthServiceAppleSignInAndLink() {
        let mockProvider = MockFirebaseAuthProvider()
        mockProvider.mockUid = "apple_user"
        let authService = FirebaseAuthService(authProvider: mockProvider)
        
        let expectation1 = self.expectation(description: "Apple sign in success")
        authService.signInWithApple(idToken: "token123", rawNonce: "nonce456") { result in
            if case .success(let uid) = result {
                XCTAssertEqual(uid, "apple_user")
            } else {
                XCTFail("Sign in with Apple failed")
            }
            expectation1.fulfill()
        }
        
        XCTAssertEqual(mockProvider.lastAppleIdToken, "token123")
        XCTAssertEqual(mockProvider.lastAppleNonce, "nonce456")
        
        let expectation2 = self.expectation(description: "Apple link success")
        authService.linkWithApple(idToken: "token789", rawNonce: "nonce000") { result in
            XCTAssertTrue(mockProvider.linkAppleCalled)
            expectation2.fulfill()
        }
        
        XCTAssertEqual(mockProvider.lastAppleIdToken, "token789")
        XCTAssertEqual(mockProvider.lastAppleNonce, "nonce000")
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testFirebaseAuthServiceGoogleSignInAndLink() {
        let mockProvider = MockFirebaseAuthProvider()
        mockProvider.mockUid = "google_user"
        let authService = FirebaseAuthService(authProvider: mockProvider)
        
        let expectation1 = self.expectation(description: "Google sign in success")
        authService.signInWithGoogle(idToken: "g_id", accessToken: "g_access") { result in
            if case .success(let uid) = result {
                XCTAssertEqual(uid, "google_user")
            } else {
                XCTFail()
            }
            expectation1.fulfill()
        }
        
        XCTAssertEqual(mockProvider.lastGoogleIdToken, "g_id")
        XCTAssertEqual(mockProvider.lastGoogleAccessToken, "g_access")
        
        let expectation2 = self.expectation(description: "Google link success")
        authService.linkWithGoogle(idToken: "g_id_link", accessToken: "g_access_link") { result in
            XCTAssertTrue(mockProvider.linkGoogleCalled)
            expectation2.fulfill()
        }
        
        XCTAssertEqual(mockProvider.lastGoogleIdToken, "g_id_link")
        XCTAssertEqual(mockProvider.lastGoogleAccessToken, "g_access_link")
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testFirebaseAuthServiceFacebookSignInAndLink() {
        let mockProvider = MockFirebaseAuthProvider()
        mockProvider.mockUid = "fb_user"
        let authService = FirebaseAuthService(authProvider: mockProvider)
        
        let expectation1 = self.expectation(description: "Facebook sign in success")
        authService.signInWithFacebook(accessToken: "fb_access") { result in
            if case .success(let uid) = result {
                XCTAssertEqual(uid, "fb_user")
            } else {
                XCTFail()
            }
            expectation1.fulfill()
        }
        
        XCTAssertEqual(mockProvider.lastFacebookAccessToken, "fb_access")
        
        let expectation2 = self.expectation(description: "Facebook link success")
        authService.linkWithFacebook(accessToken: "fb_access_link") { result in
            XCTAssertTrue(mockProvider.linkFacebookCalled)
            expectation2.fulfill()
        }
        
        XCTAssertEqual(mockProvider.lastFacebookAccessToken, "fb_access_link")
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testFirebaseAuthServiceGameCenterSignInAndLink() {
        let mockProvider = MockFirebaseAuthProvider()
        mockProvider.mockUid = "gc_user"
        let authService = FirebaseAuthService(authProvider: mockProvider)
        
        let expectation1 = self.expectation(description: "Game Center sign in success")
        authService.signInWithGameCenter { result in
            if case .success(let uid) = result {
                XCTAssertEqual(uid, "gc_user")
            } else {
                XCTFail()
            }
            expectation1.fulfill()
        }
        
        XCTAssertTrue(mockProvider.signInGameCenterCalled)
        
        let expectation2 = self.expectation(description: "Game Center link success")
        authService.linkWithGameCenter { result in
            XCTAssertTrue(mockProvider.linkGameCenterCalled)
            expectation2.fulfill()
        }
        
        XCTAssertTrue(mockProvider.linkGameCenterCalled)
        
        waitForExpectations(timeout: 1.0)
    }
}
