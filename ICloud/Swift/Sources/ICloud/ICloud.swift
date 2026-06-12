import Foundation
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
    /// Error during the retrieving of data from iCloud
    @Signal var icloudGetFail: SignalWithArguments<Int, String>
    /// @Signal
    /// Error during the storing of data in iCloud
    @Signal var icloudSetFail: SignalWithArguments<Int, String>    
    // MARK: KeyValue
    /// @Signal
    /// iCloud notification
    @Signal var notificationChange: SignalWithArguments<Int, GArray>

    static var shared: ICloud?
    private var service: ICloudServiceProtocol
    
    var autoSync: Bool {
        get { service.autoSync }
        set { service.autoSync = newValue }
    }

    required init(_ context: InitContext) {
        let defaultService = ICloudService()
        self.service = defaultService
        super.init(context)
        
        setupCallbacks()
        ICloud.shared = self
    }
    
    private func setupCallbacks() {
        service.onStoreDidChange = { [weak self] changeReason, changedKeys in
            guard let self = self else { return }
            var array = GArray()
            for key in changedKeys {
                array.append(Variant(key))
            }
            self.notificationChange.emit(changeReason, array)
        }
    }

    /// @Callable
    ///
    /// Synchronize
    @Callable
    func synchronize() -> Bool {
        return service.synchronize()
    }

    /// @Callable
    ///
    /// Write a Godot variant equivalent value to iCloud
    @Callable
    func setValue(_ aValue: Variant, forKey key: String) {
        guard let value = variantToAny(aValue) else {
            icloudSetFail.emit(ICloudError.valueError.rawValue, "Value not supported \(aValue)")
            return
        }
        service.setValue(value, forKey: key)
    }

    /// @Callable
    ///
    /// Read a Godot variant equivalent value from iCloud
    @Callable
    func getValue(forKey key: String) -> Variant? {
        guard let swiftVal = service.getValue(forKey: key) else {
            icloudGetFail.emit(ICloudError.valueError.rawValue, "Value not available for \(key)")
            return nil
        }
        
        guard let variantVal = anyToVariant(swiftVal) else {
            icloudGetFail.emit(ICloudError.valueError.rawValue, "Value not convertible for \(key)")
            return nil
        }
        
        return variantVal
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
