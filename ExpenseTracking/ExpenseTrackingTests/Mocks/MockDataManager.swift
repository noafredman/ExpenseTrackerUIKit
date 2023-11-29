//
//  MockDataManager.swift
//  ExpenseTrackingTests
//
//  Created by Noa Fredman.
//

import Foundation
@testable import ExpenseTracking
import XCTest

final class MockDataManager: DataManagerProtocol {

    static var shared: DataManagerProtocol = DataManager.shared
    var userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
        MockDataManager.shared.userDefaults = userDefaults
    }

    var getExpenseClustersCalled: (() -> [ExpenseCluster])?
    func getExpenseClusters() -> [ExpenseCluster] {
        guard let getExpenseClustersCalled else {
            XCTFail("getExpenseClustersCalled not set")
            return []
        }
        return getExpenseClustersCalled()
    }
    
    var getAllUsersInfoArrayCalled: (() -> [UserInfo])?
    func getAllUsersInfoArray() -> [UserInfo] {
        guard let getAllUsersInfoArrayCalled else {
            XCTFail("getAllUsersInfoArrayCalled not set")
            return []
        }
        return getAllUsersInfoArrayCalled()
    }
    
    var getCurrentUserIdCalled: (() throws -> UUID)?
    func getCurrentUserId() throws -> UUID {
        guard let getCurrentUserIdCalled else {
            XCTFail("getCurrentUserIdCalled not set")
            return UUID()
        }
        return try getCurrentUserIdCalled()
    }
    
    var handleLoginCalled: ((UserInfo) throws -> ())?
    func handleLogin(userInfo: UserInfo) throws {
        guard let handleLoginCalled else {
            XCTFail("handleLoginCalled not set")
            return
        }
        return try handleLoginCalled(userInfo)
    }
    
    var setUserInfoCalled: ((Data) -> ())?
    func setUserInfo(_ encoded: Data) {
        guard let setUserInfoCalled else {
            XCTFail("setUserInfoCalled not set")
            return
        }
        return setUserInfoCalled(encoded)
    }
    
    var getCurrentUserNameCalled: (() -> String?)?
    func getCurrentUserName() -> String? {
        guard let getCurrentUserNameCalled else {
            XCTFail("getCurrentUserNameCalled not set")
            return nil
        }
        return getCurrentUserNameCalled()
    }
    
    var handleLogoutCalled: (() -> ())?
    func handleLogout() {
        guard let handleLogoutCalled else {
            XCTFail("handleLogoutCalled not set")
            return
        }
        return handleLogoutCalled()
    }
    
}
