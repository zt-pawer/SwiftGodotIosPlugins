import Foundation
import FirebaseCore
import FirebaseAuth

// 1. Protocol wrapping the Firebase Auth SDK (Option A)
public protocol FirebaseAuthProvider {
    var currentUserUid: String? { get }
    func signInAnonymously(completion: @escaping (String?, Error?) -> Void)
    func signOut() throws
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
}

// 3. Protocol wrapping the FirebaseAuthService itself (Option B)
public protocol FirebaseAuthServiceProtocol {
    func signInAnonymously(completion: @escaping (Result<String, Error>) -> Void)
    func signOut(completion: @escaping (Error?) -> Void)
    func isUserSignedIn() -> Bool
    func getCurrentUserUid() -> String
}

public final class FirebaseAuthService: FirebaseAuthServiceProtocol {
    private let authProvider: FirebaseAuthProvider
    
    public init(authProvider: FirebaseAuthProvider = DefaultFirebaseAuthProvider()) {
        self.authProvider = authProvider
    }
    
    public func signInAnonymously(completion: @escaping (Result<String, Error>) -> Void) {
        authProvider.signInAnonymously { uid, error in
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
}
