import Foundation
import AuthenticationServices

#if canImport(UIKit)
import UIKit
#endif

public struct AppleCredential {
    public let userIdentifier: String
    public let identityToken: String
    public let authorizationCode: String
    public let email: String
    public let fullName: String
    
    public init(userIdentifier: String, identityToken: String, authorizationCode: String, email: String, fullName: String) {
        self.userIdentifier = userIdentifier
        self.identityToken = identityToken
        self.authorizationCode = authorizationCode
        self.email = email
        self.fullName = fullName
    }
}

public protocol AppleSignInServiceProtocol {
    func isAvailable() -> Bool
    func signIn(requestEmail: Bool, requestFullName: Bool)
    func checkCredentialState(userIdentifier: String, completion: @escaping (Bool) -> Void)
    
    var onSignInSuccess: ((AppleCredential) -> Void)? { get set }
    var onSignInFailed: ((Int, String) -> Void)? { get set }
    var onSignInCancelled: (() -> Void)? { get set }
}

public final class AppleSignInService: NSObject, AppleSignInServiceProtocol {
    public var onSignInSuccess: ((AppleCredential) -> Void)?
    public var onSignInFailed: ((Int, String) -> Void)?
    public var onSignInCancelled: (() -> Void)?
    
    private var currentController: ASAuthorizationController?
    
    public func isAvailable() -> Bool {
        #if canImport(UIKit)
        if #available(iOS 13.0, *) {
            return true
        }
        #elseif os(macOS)
        if #available(macOS 10.15, *) {
            return true
        }
        #endif
        return false
    }
    
    public func signIn(requestEmail: Bool, requestFullName: Bool) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        
        var scopes: [ASAuthorization.Scope] = []
        if requestEmail {
            scopes.append(.email)
        }
        if requestFullName {
            scopes.append(.fullName)
        }
        request.requestedScopes = scopes
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        self.currentController = authorizationController
        
        authorizationController.delegate = self
        #if canImport(UIKit)
        authorizationController.presentationContextProvider = self
        #endif
        
        authorizationController.performRequests()
    }
    
    public func checkCredentialState(userIdentifier: String, completion: @escaping (Bool) -> Void) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: userIdentifier) { credentialState, error in
            if let error = error {
                completion(false)
                return
            }
            switch credentialState {
            case .authorized:
                completion(true)
            default:
                completion(false)
            }
        }
    }
}

extension AppleSignInService: ASAuthorizationControllerDelegate {
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            let identityToken = appleIDCredential.identityToken.flatMap { String(data: $0, encoding: .utf8) } ?? ""
            let authorizationCode = appleIDCredential.authorizationCode.flatMap { String(data: $0, encoding: .utf8) } ?? ""
            let email = appleIDCredential.email ?? ""
            
            var fullName = ""
            if let nameComponents = appleIDCredential.fullName {
                fullName = PersonNameComponentsFormatter().string(from: nameComponents)
            }
            
            let credential = AppleCredential(
                userIdentifier: userIdentifier,
                identityToken: identityToken,
                authorizationCode: authorizationCode,
                email: email,
                fullName: fullName
            )
            onSignInSuccess?(credential)
        } else {
            onSignInFailed?(3, "Invalid credential type")
        }
        currentController = nil
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        if let authError = error as? ASAuthorizationError {
            switch authError.code {
            case .canceled:
                onSignInCancelled?()
            case .invalidResponse:
                onSignInFailed?(3, "Invalid response from Apple")
            case .notHandled:
                onSignInFailed?(4, "Request not handled")
            case .failed:
                onSignInFailed?(5, "Authorization failed: \(authError.localizedDescription)")
            case .notInteractive:
                onSignInFailed?(7, "Not interactive")
            default:
                onSignInFailed?(1, "Unknown error: \(authError.localizedDescription)")
            }
        } else {
            onSignInFailed?(1, "Error: \(error.localizedDescription)")
        }
        currentController = nil
    }
}

#if canImport(UIKit)
extension AppleSignInService: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
            return UIWindow()
        }
        return scene.windows.first(where: { $0.isKeyWindow }) ?? scene.windows.first ?? UIWindow()
    }
}
#endif
