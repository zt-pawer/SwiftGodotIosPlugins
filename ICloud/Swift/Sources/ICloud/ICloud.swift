//
//  ICloudViewController.swift
//  SwiftGodotIosPlugins
//
//  Created by ZT Pawer on 12/30/24.
//

import GameKit
import SwiftGodot

#initSwiftExtension(
    cdecl: "icloud",
    types: [
        ICloud.self
    ]
)

enum ICloudError: Int, Error {
    case unknownError = 1
    case valueError = 2
    case notAvailable = 3
}

@Godot
class ICloud: Object {

    /// @Signal
    /// Error during the interaction with iCloud
    @Signal var icloudFail: SignalWithArguments<Int, String>
    // MARK: KeyValue
    /// @Signal
    /// iCloud notification
    @Signal var notificationChange: SignalWithArguments<Int, GArray>

    static var shared: ICloud?
    private let iCloudStore = NSUbiquitousKeyValueStore.default
    private var notificationObserver: NSObjectProtocol?
    private var autoSyncEnabled: Bool = false
    var autoSync: Bool {
        get { autoSyncEnabled }
        set { autoSyncEnabled = newValue }
    }

    required init() {
        super.init()
        notificationSetup()
        ICloud.shared = self
    }

    required init(nativeHandle: UnsafeRawPointer) {
        super.init()
        notificationSetup()
        ICloud.shared = self
    }

    private func notificationSetup() {
        // Observe changes using a closure
        notificationObserver = NotificationCenter.default.addObserver(
            forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: iCloudStore,
            queue: .main
        ) { [weak self] notification in
            self?.handleiCloudStoreDidChange(notification: notification)
        }
    }

    deinit {
        // Clean up the observer
        if let observer = notificationObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    /// Handle iCloud changes
    /// Note: It has not been tested
    private func handleiCloudStoreDidChange(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }

        let changeReason =
            userInfo[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int ?? -1
        let changedKeys =
            userInfo[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String] ?? []

        var array = GArray()
        for key in changedKeys {
            array.append(Variant(key))
        }
        notificationChange.emit(changeReason, array)

    }

    /// @Callable
    ///
    /// Synchronize
    @Callable
    func synchronize() -> Bool {
        return iCloudStore.synchronize()
    }

    /// @Callable
    ///
    /// Write a Godot variant equivalent value to iCloud
    @Callable
    func setValue(_ aValue: Variant, forKey key: String) {
        var value = variantToAny(aValue)
        if value == nil {
            icloudFail.emit(ICloudError.valueError.rawValue, "Value not supported \(aValue)")
            return
        }
        iCloudStore.set(variantToAny(aValue), forKey: key)
        if autoSync { iCloudStore.synchronize() }
    }

    /// @Callable
    ///
    /// Read a Godot variant equivalent value from iCloud
    @Callable
    func getValue(forKey key: String) -> Variant? {
        return anyToVariant(iCloudStore.object(forKey: key))
    }

    private func variantToAny(_ value: Variant) -> Any? {
        switch value.gtype {
        case .string:
            return String(value)
        case .int:
            return Int(value)
        case .float:
            return Double(value)
        case .bool:
            return Bool(value)
        default:
            return nil
        }
    }

    private func anyToVariant(_ value: Any) -> Variant? {
        switch value {
        case let value as String:
            return Variant(value)
        case let value as Int:
            return Variant(value)
        case let value as Double:
            return Variant(value)
        case let value as Bool:
            return Variant(value)
        default:
            return nil
        }
    }

}
