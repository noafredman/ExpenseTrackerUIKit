//
//  ExpenseFormViewModelTests.swift
//  ExpenseTrackingTests
//
//  Created by Noa Fredman.
//

import Foundation

import XCTest
@testable import ExpenseTracking

final class ExpenseFormViewModelTests: XCTestCase {
    private var expenseFormViewModel: ExpenseFormViewModelProtocol!
    private var mockDataManager: MockDataManager!
    private let today = Date.today
    private let yesterday = Date.yesterday
    private let tomorrow = Date.tomorrow
    
    override func setUp() {
        super.setUp()
        let userDefaults = UserDefaults(suiteName: #file)!
        userDefaults.removePersistentDomain(forName: #file)
        mockDataManager = MockDataManager(userDefaults: userDefaults)
        expenseFormViewModel = ExpenseFormViewModel(dataManager: mockDataManager)
    }
    
    // MARK: - createClicked

    func testCreateClicked_firstExpense_shouldSucceed() {
        // create expense of (date) today
        let userInfo = UserInfo(
            id: UUID(),
            name: Lorem.firstName
        )
        let expense = createExpense()
        let expenseCluster = ExpenseCluster(
            id: UUID(),
            date: today,
            expenses: [expense]
        )
        let expectedUserInfo = UserInfo(
            id: userInfo.id,
            name: userInfo.name,
            expenseCluster: [expenseCluster]
        )
        let getCurrentUserIdCalledExpectation = expectation(description: "getCurrentUserIdCalled expectation")
        mockDataManager.getCurrentUserIdCalled = {
            getCurrentUserIdCalledExpectation.fulfill()
            return userInfo.id
        }
        let getAllUsersInfoArrayCalledExpectation = expectation(description: "getAllUsersInfoArrayCalled expectation")
        mockDataManager.getAllUsersInfoArrayCalled = {
            getAllUsersInfoArrayCalledExpectation.fulfill()
            return [userInfo]
        }
        let setUserInfoCalledExpectation = expectation(description: "setUserInfoCalled expectation")
        mockDataManager.setUserInfoCalled = { encoded in
            if let decodedUserInfoArray = try? JSONDecoder().decode([UserInfo].self, from: encoded) {
                setUserInfoCalledExpectation.fulfill()
                XCTAssertEqual(decodedUserInfoArray, [expectedUserInfo])
            }
        }
        
        expenseFormViewModel.createClicked(
            date: expenseCluster.date,
            expense: expense,
            newExpenseClusterId: expenseCluster.id
        )
        
        wait(
            for: [getCurrentUserIdCalledExpectation,
                  setUserInfoCalledExpectation,
                  getAllUsersInfoArrayCalledExpectation],
            timeout: 0.01
        )
    }
    
    func testCreateClicked_addExpenseWithSameDateAsExistingExpenseDate_shouldSucceed() {
        var firstExpense = ExpenseCluster(
            id: UUID(),
            date: yesterday,
            expenses: [createExpense()]
        )
        let userInfo = UserInfo(
            id: UUID(),
            name: Lorem.firstName,
            expenseCluster: [firstExpense]
        )
        let expense = createExpense()
        
        let secondExpense = ExpenseCluster(
            id: UUID(),
            date: yesterday,
            expenses: [expense]
        )
        firstExpense.expenses.append(expense)
        let expectedUserInfo = UserInfo(
            id: userInfo.id,
            name: userInfo.name,
            expenseCluster: [firstExpense]
        )
        let getCurrentUserIdCalledExpectation = expectation(description: "getCurrentUserIdCalled expectation")
        mockDataManager.getCurrentUserIdCalled = {
            getCurrentUserIdCalledExpectation.fulfill()
            return userInfo.id
        }
        let getAllUsersInfoArrayCalledExpectation = expectation(description: "getAllUsersInfoArrayCalled expectation")
        mockDataManager.getAllUsersInfoArrayCalled = {
            getAllUsersInfoArrayCalledExpectation.fulfill()
            return [userInfo]
        }
        let setUserInfoCalledExpectation = expectation(description: "setUserInfoCalled expectation")
        mockDataManager.setUserInfoCalled = { encoded in
            if let decodedUserInfoArray = try? JSONDecoder().decode([UserInfo].self, from: encoded) {
                XCTAssertEqual(decodedUserInfoArray.first?.expenseCluster.count, 1)
                XCTAssertEqual(decodedUserInfoArray.first?.expenseCluster.first?.expenses.count, 2)
                XCTAssertEqual(decodedUserInfoArray, [expectedUserInfo])
                setUserInfoCalledExpectation.fulfill()
            }
        }
        
        expenseFormViewModel.createClicked(
            date: secondExpense.date,
            expense: expense,
            newExpenseClusterId: secondExpense.id
        )
        
        wait(
            for: [getCurrentUserIdCalledExpectation,
                  setUserInfoCalledExpectation,
                  getAllUsersInfoArrayCalledExpectation],
            timeout: 0.01
        )
    }
    
    func testCreateClicked_addExpenseWithNewDate_shouldSucceed() {
        let firstExpense = ExpenseCluster(
            id: UUID(),
            date: Date.now,
            expenses: [createExpense()]
        )
        let userInfo = UserInfo(
            id: UUID(),
            name: Lorem.firstName,
            expenseCluster: [firstExpense]
        )
        let expense = createExpense()
        let secondExpense = ExpenseCluster(
            id: UUID(),
            date: yesterday,
            expenses: [expense]
        )
        let expectedUserInfo = UserInfo(
            id: userInfo.id,
            name: userInfo.name,
            expenseCluster: [firstExpense, secondExpense]
        )
        let getCurrentUserIdCalledExpectation = expectation(description: "getCurrentUserIdCalled expectation")
        mockDataManager.getCurrentUserIdCalled = {
            getCurrentUserIdCalledExpectation.fulfill()
            return userInfo.id
        }
        let getAllUsersInfoArrayCalledExpectation = expectation(description: "getAllUsersInfoArrayCalled expectation")
        mockDataManager.getAllUsersInfoArrayCalled = {
            getAllUsersInfoArrayCalledExpectation.fulfill()
            return [userInfo]
        }
        let setUserInfoCalledExpectation = expectation(description: "setUserInfoCalled expectation")
        mockDataManager.setUserInfoCalled = { encoded in
            if let decodedUserInfoArray = try? JSONDecoder().decode([UserInfo].self, from: encoded) {
                XCTAssertEqual(decodedUserInfoArray.first?.expenseCluster.count, 2)
                XCTAssertEqual(decodedUserInfoArray, [expectedUserInfo])
                setUserInfoCalledExpectation.fulfill()
            }
        }
        
        expenseFormViewModel.createClicked(
            date: secondExpense.date,
            expense: expense,
            newExpenseClusterId: secondExpense.id
        )
        
        wait(
            for: [getCurrentUserIdCalledExpectation,
                  setUserInfoCalledExpectation,
                  getAllUsersInfoArrayCalledExpectation],
            timeout: 0.01
        )
    }
    
    func testCreateClicked_getCurrentIdFails_shouldFail() {
        var firstExpense = ExpenseCluster(
            id: UUID(),
            date: yesterday,
            expenses: [createExpense()]
        )
        let userInfo = UserInfo(
            id: UUID(),
            name: Lorem.firstName,
            expenseCluster: [firstExpense]
        )
        let expense = createExpense()
        
        let secondExpense = ExpenseCluster(
            id: UUID(),
            date: yesterday,
            expenses: [expense]
        )
        firstExpense.expenses.append(expense)
        let expectedUserInfo = UserInfo(
            id: userInfo.id,
            name: userInfo.name,
            expenseCluster: [firstExpense]
        )
        let getCurrentUserIdCalledExpectation = expectation(description: "getCurrentUserIdCalled expectation")
        mockDataManager.getCurrentUserIdCalled = {
            getCurrentUserIdCalledExpectation.fulfill()
            throw NSError()
        }
        let getAllUsersInfoArrayCalledExpectation = expectation(description: "getAllUsersInfoArrayCalled expectation")
        mockDataManager.getAllUsersInfoArrayCalled = {
            getAllUsersInfoArrayCalledExpectation.fulfill()
            return [userInfo]
        }
        let setUserInfoCalledExpectation = expectation(description: "setUserInfoCalled expectation")
        setUserInfoCalledExpectation.isInverted = true
        mockDataManager.setUserInfoCalled = { encoded in
            if let decodedUserInfoArray = try? JSONDecoder().decode([UserInfo].self, from: encoded) {
                XCTAssertEqual(decodedUserInfoArray.first?.expenseCluster.count, 1)
                XCTAssertEqual(decodedUserInfoArray.first?.expenseCluster.first?.expenses.count, 2)
                XCTAssertEqual(decodedUserInfoArray, [expectedUserInfo])
                setUserInfoCalledExpectation.fulfill()
            }
        }
        
        expenseFormViewModel.createClicked(
            date: secondExpense.date,
            expense: expense,
            newExpenseClusterId: secondExpense.id
        )
        
        wait(
            for: [getCurrentUserIdCalledExpectation,
                  setUserInfoCalledExpectation,
                  getAllUsersInfoArrayCalledExpectation],
            timeout: 0.01
        )
    }
    
    
    // MARK: - saveEditedExpense
    
    func testSaveEdited_titleOrAmountEdited_success() {
        let expense = createExpense()
        let expense2 = createExpense()
        let expense2TitleChanged = Expense(
            id: expense2.id,
            title: Lorem.title,
            amount: expense2.amount
        )
        let expense2AmountChanged = Expense(
            id: expense2.id,
            title: Lorem.title,
            amount: expense2.amount + 1
        )
        
        runPerParemeter(expense2TitleChanged, expense2AmountChanged) { [self] expense2Changed in
            guard let expense2Changed = expense2Changed as? Expense else {
                XCTFail()
                return
            }
            let expense = ExpenseCluster(
                id: UUID(),
                date: yesterday,
                expenses: [expense]
            )
            let expense2 = ExpenseCluster(
                id: UUID(),
                date: today,
                expenses: [expense2]
            )
            
            let userInfo = UserInfo(
                id: UUID(),
                name: Lorem.firstName,
                expenseCluster: [expense, expense2]
            )
            mockDataManager.getExpenseClustersCalled = {
                return [expense, expense2]
            }
            let getCurrentUserIdCalledExpectation = expectation(description: "getCurrentUserIdCalled expectation")
            mockDataManager.getCurrentUserIdCalled = {
                getCurrentUserIdCalledExpectation.fulfill()
                return userInfo.id
            }
            let getAllUsersInfoArrayCalledExpectation = expectation(description: "getAllUsersInfoArrayCalled expectation")
            mockDataManager.getAllUsersInfoArrayCalled = {
                getAllUsersInfoArrayCalledExpectation.fulfill()
                return [userInfo]
            }
            let setUserInfoCalledExpectation = expectation(description: "setUserInfoCalled expectation")
            mockDataManager.setUserInfoCalled = { encoded in
                if let decodedUserInfoArray = try? JSONDecoder().decode([UserInfo].self, from: encoded) {
                    XCTAssertEqual(decodedUserInfoArray.first?.expenseCluster.count, 2)
                    XCTAssertEqual(decodedUserInfoArray.first?.expenseCluster[1].expenses[0], expense2Changed)
                    setUserInfoCalledExpectation.fulfill()
                }
            }
            
            expenseFormViewModel.saveEditedExpense(
                expenseClusterId: expense2.id,
                date: expense2.date,
                expense: expense2Changed
            )
            
            wait(
                for: [getCurrentUserIdCalledExpectation,
                      getAllUsersInfoArrayCalledExpectation,
                      setUserInfoCalledExpectation],
                timeout: 0.01
            )
        }
    }
    
    func testSaveEdited_dateEdited_success() {
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
        let expense2Changed = Expense(
            id: expense2.id,
            title: Lorem.title,
            amount: Double.random(in: 1...1_000)
        )
        var userInfo = UserInfo(
            id: UUID(),
            name: Lorem.firstName,
            expenseCluster: [expenseCluster, expenseCluster2]
        )
        mockDataManager.getExpenseClustersCalled = {
            return [expenseCluster, expenseCluster2]
        }
        let getCurrentUserIdCalledExpectation = expectation(description: "getCurrentUserIdCalled expectation")
        getCurrentUserIdCalledExpectation.expectedFulfillmentCount = 2
        mockDataManager.getCurrentUserIdCalled = {
            getCurrentUserIdCalledExpectation.fulfill()
            return userInfo.id
        }
        let getAllUsersInfoArrayCalledExpectation = expectation(description: "getAllUsersInfoArrayCalled expectation")
        getAllUsersInfoArrayCalledExpectation.expectedFulfillmentCount = 2
        var count = 0
        mockDataManager.getAllUsersInfoArrayCalled = {
            count += 1
            getAllUsersInfoArrayCalledExpectation.fulfill()
            if count == 1 {
                return [userInfo]
            } else {
                userInfo.expenseCluster.remove(at: 1)
                return [userInfo]
            }
        }
        let setUserInfoCalledExpectation = expectation(description: "setUserInfoCalled expectation")
        setUserInfoCalledExpectation.expectedFulfillmentCount = 2
        var countSetUserInfoCalled = 0
        mockDataManager.setUserInfoCalled = { encoded in
            countSetUserInfoCalled += 1
            if let decodedUserInfoArray = try? JSONDecoder().decode([UserInfo].self, from: encoded) {
                if countSetUserInfoCalled == 1 {
                    // called after removing the expense we want to edit
                    XCTAssertEqual(decodedUserInfoArray.first?.expenseCluster.count, 1)
                } else if countSetUserInfoCalled == 2 {
                    // called after adding the the updated expense
                    XCTAssertEqual(decodedUserInfoArray.first?.expenseCluster.count, 2)
                    XCTAssertEqual(decodedUserInfoArray.first?.expenseCluster[1].expenses[0], expense2Changed)
                }
                setUserInfoCalledExpectation.fulfill()
            }
        }
        
        expenseFormViewModel.saveEditedExpense(
            expenseClusterId: expenseCluster2.id,
            date: tomorrow,
            expense: expense2Changed
        )
        
        wait(
            for: [getCurrentUserIdCalledExpectation,
                  getAllUsersInfoArrayCalledExpectation,
                  setUserInfoCalledExpectation],
            timeout: 0.01
        )
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
