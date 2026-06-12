import Foundation
import FirebaseCore
import FirebaseAuth

// 1. Protocol wrapping the Firebase Auth SDK
public protocol FirebaseAuthProvider {
    var currentUserUid: String? { get }
    func signInAnonymously(completion: @escaping (String?, Error?) -> Void)
    func signOut() throws
    
    func signInWithApple(idToken: String, rawNonce: String, completion: @escaping (String?, Error?) -> Void)
    func linkWithApple(idToken: String, rawNonce: String, completion: @escaping (String?, Error?) -> Void)
    
    func signInWithGoogle(idToken: String, accessToken: String, completion: @escaping (String?, Error?) -> Void)
    func linkWithGoogle(idToken: String, accessToken: String, completion: @escaping (String?, Error?) -> Void)
    
    func signInWithFacebook(accessToken: String, completion: @escaping (String?, Error?) -> Void)
    func linkWithFacebook(accessToken: String, completion: @escaping (String?, Error?) -> Void)
    
    func signInWithGameCenter(completion: @escaping (String?, Error?) -> Void)
    func linkWithGameCenter(completion: @escaping (String?, Error?) -> Void)
}

// 2. Default provider that accesses Firebase Auth dynamically to prevent initialization exceptions in tests
public struct DefaultFirebaseAuthProvider: FirebaseAuthProvider {
    public init() {}

    public var currentUserUid: String? {
        guard FirebaseApp.app() != nil else { return nil }
        return Auth.auth().currentUser?.uid
    }
    
    public func signInAnonymously(completion: @escaping (String?, Error?) -> Void) {
        guard FirebaseApp.app() != nil else {
            let error = NSError(domain: "FirebaseAuthService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Firebase has not been configured."])
            completion(nil, error)
            return
        }
        Auth.auth().signInAnonymously { result, error in
            completion(result?.user.uid, error)
        }
    }
    
    public func signOut() throws {
        guard FirebaseApp.app() != nil else {
            throw NSError(domain: "FirebaseAuthService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Firebase has not been configured."])
        }
        try Auth.auth().signOut()
    }
    
    public func signInWithApple(idToken: String, rawNonce: String, completion: @escaping (String?, Error?) -> Void) {
        guard FirebaseApp.app() != nil else {
            completion(nil, firebaseNotConfiguredError())
            return
        }
        let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idToken, rawNonce: rawNonce)
        Auth.auth().signIn(with: credential) { result, error in
            completion(result?.user.uid, error)
        }
    }
    
    public func linkWithApple(idToken: String, rawNonce: String, completion: @escaping (String?, Error?) -> Void) {
        guard FirebaseApp.app() != nil else {
            completion(nil, firebaseNotConfiguredError())
            return
        }
        guard let currentUser = Auth.auth().currentUser else {
            completion(nil, noUserSignedInError())
            return
        }
        let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idToken, rawNonce: rawNonce)
        currentUser.link(with: credential) { result, error in
            completion(result?.user.uid, error)
        }
    }
    
    public func signInWithGoogle(idToken: String, accessToken: String, completion: @escaping (String?, Error?) -> Void) {
        guard FirebaseApp.app() != nil else {
            completion(nil, firebaseNotConfiguredError())
            return
        }
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        Auth.auth().signIn(with: credential) { result, error in
            completion(result?.user.uid, error)
        }
    }
    
    public func linkWithGoogle(idToken: String, accessToken: String, completion: @escaping (String?, Error?) -> Void) {
        guard FirebaseApp.app() != nil else {
            completion(nil, firebaseNotConfiguredError())
            return
        }
        guard let currentUser = Auth.auth().currentUser else {
            completion(nil, noUserSignedInError())
            return
        }
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        currentUser.link(with: credential) { result, error in
            completion(result?.user.uid, error)
        }
    }
    
    public func signInWithFacebook(accessToken: String, completion: @escaping (String?, Error?) -> Void) {
        guard FirebaseApp.app() != nil else {
            completion(nil, firebaseNotConfiguredError())
            return
        }
        let credential = FacebookAuthProvider.credential(withAccessToken: accessToken)
        Auth.auth().signIn(with: credential) { result, error in
            completion(result?.user.uid, error)
        }
    }
    
    public func linkWithFacebook(accessToken: String, completion: @escaping (String?, Error?) -> Void) {
        guard FirebaseApp.app() != nil else {
            completion(nil, firebaseNotConfiguredError())
            return
        }
        guard let currentUser = Auth.auth().currentUser else {
            completion(nil, noUserSignedInError())
            return
        }
        let credential = FacebookAuthProvider.credential(withAccessToken: accessToken)
        currentUser.link(with: credential) { result, error in
            completion(result?.user.uid, error)
        }
    }
    
    public func signInWithGameCenter(completion: @escaping (String?, Error?) -> Void) {
        guard FirebaseApp.app() != nil else {
            completion(nil, firebaseNotConfiguredError())
            return
        }
        GameCenterAuthProvider.getCredential { credential, error in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let credential = credential else {
                completion(nil, NSError(domain: "FirebaseAuthService", code: -5, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve Game Center credential."]))
                return
            }
            Auth.auth().signIn(with: credential) { result, error in
                completion(result?.user.uid, error)
            }
        }
    }
    
    public func linkWithGameCenter(completion: @escaping (String?, Error?) -> Void) {
        guard FirebaseApp.app() != nil else {
            completion(nil, firebaseNotConfiguredError())
            return
        }
        guard let currentUser = Auth.auth().currentUser else {
            completion(nil, noUserSignedInError())
            return
        }
        GameCenterAuthProvider.getCredential { credential, error in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let credential = credential else {
                completion(nil, NSError(domain: "FirebaseAuthService", code: -5, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve Game Center credential."]))
                return
            }
            currentUser.link(with: credential) { result, error in
                completion(result?.user.uid, error)
            }
        }
    }
    
    private func firebaseNotConfiguredError() -> Error {
        return NSError(domain: "FirebaseAuthService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Firebase has not been configured."])
    }
    
    private func noUserSignedInError() -> Error {
        return NSError(domain: "FirebaseAuthService", code: -3, userInfo: [NSLocalizedDescriptionKey: "No user currently signed in to link account."])
    }
}

// 3. Protocol wrapping the FirebaseAuthService itself
public protocol FirebaseAuthServiceProtocol {
    func signInAnonymously(completion: @escaping (Result<String, Error>) -> Void)
    func signOut(completion: @escaping (Error?) -> Void)
    func isUserSignedIn() -> Bool
    func getCurrentUserUid() -> String
    
    func signInWithApple(idToken: String, rawNonce: String, completion: @escaping (Result<String, Error>) -> Void)
    func linkWithApple(idToken: String, rawNonce: String, completion: @escaping (Result<String, Error>) -> Void)
    
    func signInWithGoogle(idToken: String, accessToken: String, completion: @escaping (Result<String, Error>) -> Void)
    func linkWithGoogle(idToken: String, accessToken: String, completion: @escaping (Result<String, Error>) -> Void)
    
    func signInWithFacebook(accessToken: String, completion: @escaping (Result<String, Error>) -> Void)
    func linkWithFacebook(accessToken: String, completion: @escaping (Result<String, Error>) -> Void)
    
    func signInWithGameCenter(completion: @escaping (Result<String, Error>) -> Void)
    func linkWithGameCenter(completion: @escaping (Result<String, Error>) -> Void)
}

public final class FirebaseAuthService: FirebaseAuthServiceProtocol {
    private let authProvider: FirebaseAuthProvider
    
    public init(authProvider: FirebaseAuthProvider = DefaultFirebaseAuthProvider()) {
        self.authProvider = authProvider
    }
    
    public func signInAnonymously(completion: @escaping (Result<String, Error>) -> Void) {
        authProvider.signInAnonymously { uid, error in
            self.handleCompletion(uid: uid, error: error, completion: completion)
        }
    }
    
    public func signOut(completion: @escaping (Error?) -> Void) {
        do {
            try authProvider.signOut()
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    public func isUserSignedIn() -> Bool {
        return authProvider.currentUserUid != nil
    }
    
    public func getCurrentUserUid() -> String {
        return authProvider.currentUserUid ?? ""
    }
    
    public func signInWithApple(idToken: String, rawNonce: String, completion: @escaping (Result<String, Error>) -> Void) {
        authProvider.signInWithApple(idToken: idToken, rawNonce: rawNonce) { uid, error in
            self.handleCompletion(uid: uid, error: error, completion: completion)
        }
    }
    
    public func linkWithApple(idToken: String, rawNonce: String, completion: @escaping (Result<String, Error>) -> Void) {
        authProvider.linkWithApple(idToken: idToken, rawNonce: rawNonce) { uid, error in
            self.handleCompletion(uid: uid, error: error, completion: completion)
        }
    }
    
    public func signInWithGoogle(idToken: String, accessToken: String, completion: @escaping (Result<String, Error>) -> Void) {
        authProvider.signInWithGoogle(idToken: idToken, accessToken: accessToken) { uid, error in
            self.handleCompletion(uid: uid, error: error, completion: completion)
        }
    }
    
    public func linkWithGoogle(idToken: String, accessToken: String, completion: @escaping (Result<String, Error>) -> Void) {
        authProvider.linkWithGoogle(idToken: idToken, accessToken: accessToken) { uid, error in
            self.handleCompletion(uid: uid, error: error, completion: completion)
        }
    }
    
    public func signInWithFacebook(accessToken: String, completion: @escaping (Result<String, Error>) -> Void) {
        authProvider.signInWithFacebook(accessToken: accessToken) { uid, error in
            self.handleCompletion(uid: uid, error: error, completion: completion)
        }
    }
    
    public func linkWithFacebook(accessToken: String, completion: @escaping (Result<String, Error>) -> Void) {
        authProvider.linkWithFacebook(accessToken: accessToken) { uid, error in
            self.handleCompletion(uid: uid, error: error, completion: completion)
        }
    }
    
    public func signInWithGameCenter(completion: @escaping (Result<String, Error>) -> Void) {
        authProvider.signInWithGameCenter { uid, error in
            self.handleCompletion(uid: uid, error: error, completion: completion)
        }
    }
    
    public func linkWithGameCenter(completion: @escaping (Result<String, Error>) -> Void) {
        authProvider.linkWithGameCenter { uid, error in
            self.handleCompletion(uid: uid, error: error, completion: completion)
        }
    }
    
    private func handleCompletion(uid: String?, error: Error?, completion: @escaping (Result<String, Error>) -> Void) {
        if let error = error {
            completion(.failure(error))
            return
        }
        if let uid = uid {
            completion(.success(uid))
        } else {
            let unknownError = NSError(
                domain: "FirebaseAuthService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Unknown authentication error."]
            )
            completion(.failure(unknownError))
        }
    }
}
