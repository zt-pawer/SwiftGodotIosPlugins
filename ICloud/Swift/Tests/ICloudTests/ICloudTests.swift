import XCTest
@testable import ICloud

class MockKeyValueStore: KeyValueStoreProtocol {
    var storage: [String: Any] = [:]
    var syncCalled = false
    
    func synchronize() -> Bool {
        syncCalled = true
        return true
    }
    
    func set(_ value: Any?, forKey defaultName: String) {
        if let value = value {
            storage[defaultName] = value
        } else {
            storage.removeValue(forKey: defaultName)
        }
    }
    
    func object(forKey defaultName: String) -> Any? {
        return storage[defaultName]
    }
}

final class ICloudTests: XCTestCase {
    func testICloudErrorEnum() {
        XCTAssertEqual(ICloudError.unknownError.rawValue, 1)
        XCTAssertEqual(ICloudError.valueError.rawValue, 2)
        XCTAssertEqual(ICloudError.notAvailable.rawValue, 3)
    }
    
    func testICloudServiceSetAndGet() {
        let mockStore = MockKeyValueStore()
        let service = ICloudService(store: mockStore)
        
        service.setValue("SaveState", forKey: "gameState")
        XCTAssertEqual(service.getValue(forKey: "gameState") as? String, "SaveState")
        XCTAssertFalse(mockStore.syncCalled, "Should not sync automatically if autoSync is false")
    }
    
    func testICloudServiceAutoSync() {
        let mockStore = MockKeyValueStore()
        let service = ICloudService(store: mockStore)
        service.autoSync = true
        
        service.setValue("AutoSaveState", forKey: "gameState")
        XCTAssertTrue(mockStore.syncCalled, "Should sync automatically if autoSync is true")
    }
}
