//
//  HomeViewModelTests.swift
//  ExpenseTrackingTests
//
//  Created by Noa Fredman.
//

import XCTest
@testable import ExpenseTracking

final class HomeViewModelTests: XCTestCase {
    private var homeViewModel: HomeViewModelProtocol!
    private var mockDataManager: MockDataManager!
    private var loginVM: LoginViewModelProtocol!
    private let firstName = Lorem.firstName
    
    override func setUp() {
        super.setUp()
        let userDefaults = UserDefaults(suiteName: #file)!
        userDefaults.removePersistentDomain(forName: #file)
        mockDataManager = MockDataManager(userDefaults: userDefaults)
        mockDataManager.getExpenseClustersCalled = {
            return []
        }
        loginVM = LoginViewModel(dataManager: mockDataManager)
        homeViewModel = HomeViewModel(dataManager: mockDataManager)
        mockDataManager.handleLoginCalled = { _ in
            
        }
        try? loginVM.didLogin(name: firstName)
    }
    
    // MARK: - updateData
    func testUpdateData_succeed() {
        let expense = createExpense()
        let expenseCluster = ExpenseCluster(
            id: UUID(),
            date: Date.today,
            expenses: [expense]
        )
        let userInfo = UserInfo(
            id: UUID(),
            name: firstName,
            expenseCluster: [expenseCluster]
        )
        let userInfoAfterExpenseRemoved = UserInfo(
            id: userInfo.id,
            name: userInfo.name,
            expenseCluster: []
        )
        runPerParemeter(HomeViewModel.UpdateDataType.filter(date: expenseCluster.date, expense: expense), HomeViewModel.UpdateDataType.removedInfo, HomeViewModel.UpdateDataType.none) { [self] updateDataType in
            guard let updateDataType = updateDataType as? HomeViewModel.UpdateDataType else {
                return
            }
            let getExpenseClustersCalledExpectation = expectation(description: "getExpenseClustersCalled expectation")
            mockDataManager.getExpenseClustersCalled = {
                getExpenseClustersCalledExpectation.fulfill()
                return [expenseCluster]
            }
            homeViewModel.updateData(for: updateDataType)
            switch updateDataType {
                
            case .filter:
                XCTAssertEqual(homeViewModel.didDeleteInfo, false)
                XCTAssertEqual(homeViewModel.state.isFiltered, updateDataType)
            case .removedInfo:
                XCTAssertEqual(homeViewModel.didDeleteInfo, true)
                XCTAssertEqual(homeViewModel.state.expenses, [expenseCluster])
                XCTAssertEqual(homeViewModel.state.isFiltered, HomeViewModel.UpdateDataType.none)
            case .none:
                XCTAssertEqual(homeViewModel.didDeleteInfo, false)
                XCTAssertEqual(homeViewModel.state.expenses, [expenseCluster])
                XCTAssertEqual(homeViewModel.state.isFiltered, HomeViewModel.UpdateDataType.none)
            }
            wait(for: [getExpenseClustersCalledExpectation], timeout: 0.01)
        }
    }
    
    // MARK: - removedExpense
    
    func testRemovedExpense_succeed() {
        let expense = createExpense()
        let expenseCluster = ExpenseCluster(
            id: UUID(),
            date: Date.today,
            expenses: [expense]
        )
        let userInfo = UserInfo(
            id: UUID(),
            name: firstName,
            expenseCluster: [expenseCluster]
        )
        let userInfoAfterExpenseRemoved = UserInfo(
            id: userInfo.id,
            name: userInfo.name,
            expenseCluster: []
        )
        let getExpenseClustersCalledExpectation = expectation(description: "getExpenseClustersCalled expectation")
        getExpenseClustersCalledExpectation.expectedFulfillmentCount = 2
        mockDataManager.getExpenseClustersCalled = {
            getExpenseClustersCalledExpectation.fulfill()
            return [expenseCluster]
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
                setUserInfoCalledExpectation.fulfill()
                XCTAssertEqual(decodedUserInfoArray, [userInfoAfterExpenseRemoved])
            }
        }
        
        XCTAssertNotNil(try? homeViewModel.removedExpense(expenseClusterId: expenseCluster.id, expenseId: expense.id))
        
        wait(
            for: [getExpenseClustersCalledExpectation,
                  getCurrentUserIdCalledExpectation,
                  setUserInfoCalledExpectation,
                  getAllUsersInfoArrayCalledExpectation],
            timeout: 0.01
        )
    }
    
    func testRemovedExpense_expectError() {
        let userInfo = UserInfo(
            id: UUID(),
            name: firstName
        )
        let expense = createExpense()
        let expenseToRemove = createExpense()
        let expenseCluster = ExpenseCluster(
            id: UUID(),
            date: Date.today,
            expenses: [expense]
        )
        
        let expenseClusterToRemove = ExpenseCluster(
            id: UUID(),
            date: Date.today,
            expenses: [expense]
        )
        
        runPerParemeter((expenseClusterToRemove.id, expense.id, HomeViewModel.HomeViewModelError.expenseClusterNotFoundError), (expenseCluster.id, expenseToRemove.id, HomeViewModel.HomeViewModelError.expenseNotFoundError)) { [self] paramTuple in
            guard let paramTuple = paramTuple as? (UUID, UUID, HomeViewModel.HomeViewModelError) else {
                return
            }
            let getExpenseClustersCalledExpectation = expectation(description: "getExpenseClustersCalled expectation")
            mockDataManager.getExpenseClustersCalled = {
                getExpenseClustersCalledExpectation.fulfill()
                return [expenseCluster]
            }
            do{
                try homeViewModel.removedExpense(expenseClusterId: paramTuple.0, expenseId: paramTuple.1)
            } catch {
                XCTAssertEqual(error as! HomeViewModel.HomeViewModelError, paramTuple.2)
            }
            
            wait(
                for: [getExpenseClustersCalledExpectation],
                timeout: 0.01
            )
        }
    }
    
    func testRemovedExpense_expectError_userIdIsThrows() {
        let userInfo = UserInfo(
            id: UUID(),
            name: firstName
        )
        let expense = createExpense()
        let expenseCluster = ExpenseCluster(
            id: UUID(),
            date: Date.today,
            expenses: [expense]
        )
        
        let getExpenseClustersCalledExpectation = expectation(description: "getExpenseClustersCalled expectation")
        mockDataManager.getExpenseClustersCalled = {
            getExpenseClustersCalledExpectation.fulfill()
            return [expenseCluster]
        }
        
        let getCurrentUserIdCalledExpectation = expectation(description: "getCurrentUserIdCalled expectation")
        mockDataManager.getCurrentUserIdCalled = {
            getCurrentUserIdCalledExpectation.fulfill()
            throw DataManager.DataManagerError.CodablesError.retrievingSavedCurrentUserIdError
        }
        
        let getAllUsersInfoArrayCalledExpectation = expectation(description: "getAllUsersInfoArrayCalled expectation")
        mockDataManager.getAllUsersInfoArrayCalled = {
            getAllUsersInfoArrayCalledExpectation.fulfill()
            return [userInfo]
        }
        XCTAssertThrowsError(try homeViewModel.removedExpense(expenseClusterId: expenseCluster.id, expenseId: expense.id)) { error in
            XCTAssertEqual(error as! HomeViewModel.HomeViewModelError, HomeViewModel.HomeViewModelError.userInfoCorruptDataError)
        }
        
        wait(
            for: [getExpenseClustersCalledExpectation,
                  getCurrentUserIdCalledExpectation,
                  getAllUsersInfoArrayCalledExpectation],
            timeout: 0.01
        )
    }
    
    // MARK: - helper methods
    func createExpense() -> Expense {
            Expense(
                id: UUID(),
                title: Lorem.title,
                amount: Double.random(in: 1...1_000)
            )
        }
}
