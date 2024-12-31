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

    // MARK: KeyValue
    /// @Signal
    /// iCloud notification
    @Signal var notificationChange:
        SignalWithArguments<Int, GArray>

    static var instance: ICloud?
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
        ICloud.instance = self
    }

    required init(nativeHandle: UnsafeRawPointer) {
        super.init()
        notificationSetup()
        ICloud.instance = self
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
    /// Write a Godot string equivalent value to iCloud
    @Callable
    func setStringValue(_ aValue: String, forKey key: String) {
        iCloudStore.set(aValue, forKey: key)
        if autoSync { iCloudStore.synchronize() }
    }

    /// @Callable
    ///
    /// Read a Godot string equivalent value from iCloud
    @Callable
    func getStringValue(forKey key: String) -> String? {
        return iCloudStore.string(forKey: key)
    }

    /// @Callable
    ///
    /// Write a Godot in equivalent value to iCloud
    @Callable
    func setIntValue(_ aValue: Int64, forKey key: String) {
        iCloudStore.set(aValue, forKey: key)
        if autoSync { iCloudStore.synchronize() }
    }

    /// @Callable
    ///
    /// Read a Godot int equivalent value from iCloud
    /// Note: On a 32bit system it might fail if outside of the 32-bit range
    @Callable
    func getIntValue(forKey key: String) -> Int? {
        return Int(iCloudStore.longLong(forKey: key))
    }

    /// @Callable
    ///
    /// Write a Godot float equivalent value to iCloud
    @Callable
    func setFloatValue(_ aValue: Double, forKey key: String) {
        iCloudStore.set(aValue, forKey: key)
        if autoSync { iCloudStore.synchronize() }
    }

    /// @Callable
    ///
    /// Read a Godot float equivalent value from iCloud
    @Callable
    func getFloatValue(forKey key: String) -> Double? {
        return iCloudStore.double(forKey: key)
    }

    /// @Callable
    ///
    /// Write a Godot bool equivalent value to iCloud
    @Callable
    func setBoolValue(_ aValue: Bool, forKey key: String) {
        iCloudStore.set(aValue, forKey: key)
        if autoSync { iCloudStore.synchronize() }
    }

    /// @Callable
    ///
    /// Read a Godot bool equivalent value from iCloud
    @Callable
    func getBoolValue(forKey key: String) -> Bool? {
        return iCloudStore.bool(forKey: key)
    }

}
