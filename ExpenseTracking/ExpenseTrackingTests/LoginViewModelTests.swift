//
//  LoginViewModelTests.swift
//  LoginViewModelTests
//
//  Created by Noa Fredman.
//

import XCTest
@testable import ExpenseTracking

final class LoginViewModelTests: XCTestCase {
    private var loginViewModel: LoginViewModelProtocol!
    private var mockDataManager: MockDataManager!
    
    override func setUp() {
        super.setUp()
        let userDefaults = UserDefaults(suiteName: #file)!
        userDefaults.removePersistentDomain(forName: #file)
        mockDataManager = MockDataManager(userDefaults: userDefaults)
        loginViewModel = LoginViewModel(dataManager: mockDataManager)
    }
    
    func testLoginCreateNewUserIfUserAlreadyExist() {
        let name1 = Lorem.firstName
        let name2 = Lorem.firstName + Lorem.firstName
        mockDataManager.handleLoginCalled = { userInfo in
            XCTAssertNotNil(userInfo)
            XCTAssertEqual(userInfo.name, name1)
        }
        XCTAssertNotNil(try? loginViewModel.didLogin(name: name1))
        
        mockDataManager.handleLoginCalled = { userInfo in
            XCTAssertNotNil(userInfo)
            XCTAssertEqual(userInfo.name, name2)
        }
        XCTAssertNotNil(try? loginViewModel.didLogin(name: name2))
    }
}
