//
//  DataManagerTests.swift
//  ExpenseTrackingTests
//
//  Created by Noa Fredman.
//

import Foundation

import XCTest
@testable import ExpenseTracking

final class DataManagerTests: XCTestCase {
    private var dataManager = DataManager.shared
    private let today = Date.today
    private let yesterday = Date.yesterday
    private let tomorrow = Date.tomorrow
    
    override func setUp() {
        super.setUp()
        let userDefaults = UserDefaults(suiteName: #file)!
        userDefaults.removePersistentDomain(forName: #file)
        dataManager = DataManager.shared
        dataManager.userDefaults = userDefaults
    }
    
    // MARK: - HandleLogin
    
    func testHandleLogin_createsFirstUserIfDoesNotAlreadyExist() {
        let name = Lorem.firstName
        let userId = UUID()
        let mockUserInfo = UserInfo(
            id: userId,
            name: name,
            expenseCluster: []
        )
        XCTAssertNotNil(try? dataManager.handleLogin(userInfo: mockUserInfo))
        // check new user created
        let savedUserInfo = dataManager.userDefaults.data(forKey: UserDefaultsKeys.usersInfo.rawValue)
        XCTAssertNotNil(savedUserInfo)
        let decodedUsersInfo = try? JSONDecoder().decode([UserInfo].self, from: savedUserInfo!)
        XCTAssertNotNil(decodedUsersInfo)
        let user = decodedUsersInfo!.first (where: { $0.name == name})
        XCTAssertNotNil(user)
        XCTAssertEqual(decodedUsersInfo!.count, 1)
    }
    
    func testHandleLogin_doesNotCreateNewUserIfUserAlreadyExist() throws {
        let name = Lorem.firstName
        let userId = UUID()
        let mockUserInfo = UserInfo(
            id: userId,
            name: name,
            expenseCluster: []
        )
        try dataManager.handleLogin(userInfo: mockUserInfo)
        try dataManager.handleLogin(userInfo: mockUserInfo)
        // check new user created
        let savedUserInfo = dataManager.userDefaults.data(forKey: UserDefaultsKeys.usersInfo.rawValue)
        XCTAssertNotNil(savedUserInfo)
        let decodedUsersInfo = try JSONDecoder().decode([UserInfo].self, from: savedUserInfo!)
        XCTAssertEqual(decodedUsersInfo.filter( { $0.name == name}).count, 1)
    }
    
    func testHandleLogin_createNewUserIfUserAlreadyExist() throws {
        let name1 = Lorem.firstName
        let name2 = name1 + name1
        let user1Id = UUID()
        let user2Id = UUID()
        let mockUserInfo1 = UserInfo(
            id: user1Id,
            name: name1,
            expenseCluster: []
        )
        let mockUserInfo2 = UserInfo(
            id: user2Id,
            name: name2,
            expenseCluster: []
        )
        try dataManager.handleLogin(userInfo: mockUserInfo1)
        try dataManager.handleLogin(userInfo: mockUserInfo2)

        // check new user created
        let savedUserInfo = dataManager.userDefaults.data(forKey: UserDefaultsKeys.usersInfo.rawValue)
        XCTAssertNotNil(savedUserInfo)
        let decodedUsersInfo = try JSONDecoder().decode([UserInfo].self, from: savedUserInfo!)
        let user2 = decodedUsersInfo.first (where: { $0.name == name2})
        XCTAssertNotNil(user2)
        XCTAssertEqual(decodedUsersInfo.count, 2)
    }
    
    // MARK: - getCurrentUserName
    
    func testGetCurrentUserName_shouldSucceed() throws {
        let name = Lorem.firstName
        let userId = UUID()
        let mockUserInfo = UserInfo(
            id: userId,
            name: name,
            expenseCluster: []
        )
        try dataManager.handleLogin(userInfo: mockUserInfo)
        let savedUserName = dataManager.getCurrentUserName()
        XCTAssertNotNil(savedUserName)
        XCTAssertEqual(savedUserName, name)
    }
    
    func testGetCurrentUserName_expectNil() {
        XCTAssertNil(dataManager.getCurrentUserName())
    }
    
    // MARK: - handleLogout
    
    func testHandleLogout_shouldSucceed() throws {
        let name = Lorem.firstName
        let userId = UUID()
        let mockUserInfo = UserInfo(
            id: userId,
            name: name,
            expenseCluster: []
        )
        
        try dataManager.handleLogin(userInfo: mockUserInfo)
        XCTAssertNotNil(dataManager.getCurrentUserName())
        dataManager.handleLogout()
        XCTAssertNil(dataManager.getCurrentUserName())

    }
        
    // MARK: - getExpenseClusters
    
    func testGetExpenses_shouldSucceed() throws {
        let name1 = Lorem.firstName
        let user1Id = UUID()
        let user2Id = UUID()
        let expense = createExpense()
        let expense2 = createExpense()
        let expenseCluster = ExpenseCluster(
            id: UUID(),
            date: yesterday,
            expenses: [expense]
        )
        let expenseCluster2 = ExpenseCluster(
            id: UUID(),
            date: today,
            expenses: [expense2]
        )
        let expectedExpenses = [expenseCluster, expenseCluster2]
        let mockUserInfo1 = UserInfo(
            id: user1Id,
            name: name1,
            expenseCluster: expectedExpenses
        )
        try dataManager.handleLogin(userInfo: mockUserInfo1)
        let expenses = try? dataManager.getExpenseClusters()

        // check expenses are as expected
        XCTAssertEqual(expenses?.count, 2)
        XCTAssertEqual(expenses, expectedExpenses)
    }
    
    // MARK: - getAllUsersInfoArray

    func testGetAllUsersInfoArray_shouldSucceed() throws {
        let name1 = Lorem.firstName
        let name2 = name1 + name1
        let user1Id = UUID()
        let user2Id = UUID()
        let expense = createExpense()
        let expense2 = createExpense()
        let expenseCluster = ExpenseCluster(
            id: UUID(),
            date: yesterday,
            expenses: [expense]
        )
        let expenseCluster2 = ExpenseCluster(
            id: UUID(),
            date: today,
            expenses: [expense2]
        )
        let mockUserInfo1 = UserInfo(
            id: user1Id,
            name: name1,
            expenseCluster: [expenseCluster, expenseCluster2]
        )
        let mockUserInfo2 = UserInfo(
            id: user1Id,
            name: name2,
            expenseCluster: [expenseCluster2, expenseCluster]
        )
        let expectedUsers = [mockUserInfo1, mockUserInfo2]
        
        try dataManager.handleLogin(userInfo: mockUserInfo1)
        var users = try? dataManager.getAllUsersInfoArray()

        XCTAssertEqual(users?.count, 1)
        XCTAssertEqual(users, [mockUserInfo1])
        
        try dataManager.handleLogin(userInfo: mockUserInfo2)
        users = try? dataManager.getAllUsersInfoArray()

        // check expenses are as expected
        XCTAssertEqual(users?.count, 2)
        XCTAssertEqual(users, expectedUsers)
    }
    
    func testGetAllUsersInfoArray_shouldThrowError() throws {
        XCTAssertThrowsError(try dataManager.getAllUsersInfoArray()) { error in
            XCTAssertEqual(error as! DataManager.DataManagerError.CodablesError, DataManager.DataManagerError.CodablesError.retrievingSavedUserInfoError)
        }
    }
    
    // MARK: - getCurrentUserId

    func testGetCurrentUserId_shouldThrowError() throws {
        XCTAssertThrowsError(try dataManager.getCurrentUserId()) { error in
            XCTAssertEqual(error as! DataManager.DataManagerError.CodablesError, DataManager.DataManagerError.CodablesError.retrievingSavedCurrentUserIdError)
        }
    }
    
    
    func testGetCurrentUserId_shouldSucceed() throws {
        let name1 = Lorem.firstName
        let user1Id = UUID()
        let expense = createExpense()
        let expense2 = createExpense()
        let expenseCluster = ExpenseCluster(
            id: UUID(),
            date: yesterday,
            expenses: [expense]
        )
        let expenseCluster2 = ExpenseCluster(
            id: UUID(),
            date: today,
            expenses: [expense2]
        )
        let mockUserInfo1 = UserInfo(
            id: user1Id,
            name: name1,
            expenseCluster: [expenseCluster, expenseCluster2]
        )
        try dataManager.handleLogin(userInfo: mockUserInfo1)
        // check expenses are as expected
        XCTAssertEqual(try? dataManager.getCurrentUserId(), user1Id)
    }
    
    // MARK: - setUserInfo

    func testSetUserInfo_shouldSucceed() {
        let name1 = Lorem.firstName
        let user1Id = UUID()
        let expense = createExpense()
        let expense2 = createExpense()
        let expenseCluster = ExpenseCluster(
            id: UUID(),
            date: yesterday,
            expenses: [expense]
        )
        let expenseCluster2 = ExpenseCluster(
            id: UUID(),
            date: today,
            expenses: [expense2]
        )
        let mockUserInfo1 = UserInfo(
            id: user1Id,
            name: name1,
            expenseCluster: [expenseCluster, expenseCluster2]
        )
        try? dataManager.handleLogin(userInfo: mockUserInfo1)

        XCTAssertNoThrow(dataManager.setUserInfo(try [mockUserInfo1].encode()))
        XCTAssertEqual(try dataManager.getAllUsersInfoArray(), [mockUserInfo1])
    }
    
    // MARK: - Helper methods
    
    func createExpense() -> Expense {
        Expense(
            id: UUID(),
            title: Lorem.title,
            amount: Double.random(in: 1...1_000)
        )
    }
}
