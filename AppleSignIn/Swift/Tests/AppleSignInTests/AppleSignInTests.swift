import XCTest
@testable import AppleSignIn

class MockAppleSignInService: AppleSignInServiceProtocol {
    var onSignInSuccess: ((AppleCredential) -> Void)?
    var onSignInFailed: ((Int, String) -> Void)?
    var onSignInCancelled: (() -> Void)?
    
    var isAvailableValue = true
    var checkCredentialStateResult = true
    var checkedUserIdentifier: String?
    
    var signInCalled = false
    var requestedEmail = false
    var requestedFullName = false
    
    func isAvailable() -> Bool {
        return isAvailableValue
    }
    
    func signIn(requestEmail: Bool, requestFullName: Bool) {
        signInCalled = true
        requestedEmail = requestEmail
        requestedFullName = requestFullName
    }
    
    func checkCredentialState(userIdentifier: String, completion: @escaping (Bool) -> Void) {
        checkedUserIdentifier = userIdentifier
        completion(checkCredentialStateResult)
    }
    
    // Test helper methods to trigger callbacks
    func triggerSuccess(userIdentifier: String, email: String, fullName: String) {
        let credential = AppleCredential(
            userIdentifier: userIdentifier,
            identityToken: "mock_jwt_token",
            authorizationCode: "mock_auth_code",
            email: email,
            fullName: fullName
        )
        onSignInSuccess?(credential)
    }
    
    func triggerFailed(code: Int, message: String) {
        onSignInFailed?(code, message)
    }
    
    func triggerCancelled() {
        onSignInCancelled?()
    }
}

final class AppleSignInTests: XCTestCase {
    
    func testAppleSignInErrorEnum() {
        XCTAssertEqual(AppleSignInError.unknownError.rawValue, 1)
        XCTAssertEqual(AppleSignInError.canceled.rawValue, 2)
        XCTAssertEqual(AppleSignInError.invalidResponse.rawValue, 3)
        XCTAssertEqual(AppleSignInError.notHandled.rawValue, 4)
        XCTAssertEqual(AppleSignInError.failed.rawValue, 5)
        XCTAssertEqual(AppleSignInError.notAvailable.rawValue, 6)
        XCTAssertEqual(AppleSignInError.notInteractive.rawValue, 7)
    }
    
    func testAppleSignInServiceMockSuccess() {
        let mockService = MockAppleSignInService()
        
        var successCredential: AppleCredential?
        mockService.onSignInSuccess = { credential in
            successCredential = credential
        }
        
        XCTAssertTrue(mockService.isAvailable())
        mockService.signIn(requestEmail: true, requestFullName: true)
        XCTAssertTrue(mockService.signInCalled)
        XCTAssertTrue(mockService.requestedEmail)
        XCTAssertTrue(mockService.requestedFullName)
        
        mockService.triggerSuccess(userIdentifier: "user123", email: "test@example.com", fullName: "John Doe")
        
        XCTAssertNotNil(successCredential)
        XCTAssertEqual(successCredential?.userIdentifier, "user123")
        XCTAssertEqual(successCredential?.email, "test@example.com")
        XCTAssertEqual(successCredential?.fullName, "John Doe")
        XCTAssertEqual(successCredential?.identityToken, "mock_jwt_token")
        XCTAssertEqual(successCredential?.authorizationCode, "mock_auth_code")
    }
    
    func testAppleSignInServiceMockCancelled() {
        let mockService = MockAppleSignInService()
        
        var cancelledCalled = false
        mockService.onSignInCancelled = {
            cancelledCalled = true
        }
        
        mockService.triggerCancelled()
        XCTAssertTrue(cancelledCalled)
    }
    
    func testAppleSignInServiceMockFailed() {
        let mockService = MockAppleSignInService()
        
        var failedCode: Int?
        var failedMessage: String?
        mockService.onSignInFailed = { code, message in
            failedCode = code
            failedMessage = message
        }
        
        mockService.triggerFailed(code: 5, message: "Authorization failed")
        
        XCTAssertEqual(failedCode, 5)
        XCTAssertEqual(failedMessage, "Authorization failed")
    }
    
    func testAppleSignInServiceCheckCredentialState() {
        let mockService = MockAppleSignInService()
        
        let expectation = self.expectation(description: "Credential state check completion")
        
        mockService.checkCredentialState(userIdentifier: "user456") { isAuthorized in
            XCTAssertTrue(isAuthorized)
            expectation.fulfill()
        }
        
        XCTAssertEqual(mockService.checkedUserIdentifier, "user456")
        waitForExpectations(timeout: 1.0, handler: nil)
    }
}
