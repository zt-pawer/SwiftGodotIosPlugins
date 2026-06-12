import Foundation

public protocol KeyValueStoreProtocol {
    func synchronize() -> Bool
    func set(_ value: Any?, forKey defaultName: String)
    func object(forKey defaultName: String) -> Any?
}

extension NSUbiquitousKeyValueStore: KeyValueStoreProtocol {}

public protocol ICloudServiceProtocol {
    func synchronize() -> Bool
    func setValue(_ value: Any, forKey key: String)
    func getValue(forKey key: String) -> Any?
    var autoSync: Bool { get set }
    var onStoreDidChange: ((Int, [String]) -> Void)? { get set }
}

public final class ICloudService: ICloudServiceProtocol {
    private let store: KeyValueStoreProtocol
    private var observer: NSObjectProtocol?
    
    public var autoSync: Bool = false
    public var onStoreDidChange: ((Int, [String]) -> Void)?
    
    public init(store: KeyValueStoreProtocol = NSUbiquitousKeyValueStore.default) {
        self.store = store
        setupObserver()
    }
    
    private func setupObserver() {
        // Only observe notifications if it is the real NSUbiquitousKeyValueStore
        guard let ubStore = store as? NSUbiquitousKeyValueStore else { return }
        observer = NotificationCenter.default.addObserver(
            forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: ubStore,
            queue: .main
        ) { [weak self] notification in
            guard let self = self, let userInfo = notification.userInfo else { return }
            let changeReason = userInfo[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int ?? -1
            let changedKeys = userInfo[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String] ?? []
            self.onStoreDidChange?(changeReason, changedKeys)
        }
    }
    
    public func synchronize() -> Bool {
        return store.synchronize()
    }
    
    public func setValue(_ value: Any, forKey key: String) {
        store.set(value, forKey: key)
        if autoSync {
            _ = store.synchronize()
        }
    }
    
    public func getValue(forKey key: String) -> Any? {
        return store.object(forKey: key)
    }
    
    deinit {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
