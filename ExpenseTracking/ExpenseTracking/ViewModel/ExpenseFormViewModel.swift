//
//  ExpenseFormViewModel.swift
//  ExpenseTracking
//
//  Created by Noa Fredman.
//

import Foundation

protocol ExpenseFormViewModelProtocol {
    func createClicked(date: Date, expense: Expense, newExpenseClusterId: UUID)
    func saveEditedExpense(expenseClusterId: UUID, date: Date, expense: Expense)
}

final class ExpenseFormViewModel: ExpenseFormViewModelProtocol {
    let dataManager:DataManagerProtocol!
    
    init(dataManager: DataManagerProtocol) {
        self.dataManager = dataManager
    }
    
    /// Create the expense for the expense cluster of given date.
    func createClicked(date: Date, expense: Expense, newExpenseClusterId: UUID) {
        guard var decodedUsersInfo = try? dataManager.getAllUsersInfoArray(),
              let userInfoAndIndex = try? getUserInfoAndIndex(decodedUsersInfo: decodedUsersInfo),
              var userInfo = userInfoAndIndex.userInfo else {
            return
        }
        let userIndex = userInfoAndIndex.userIndex
        if userInfo.expenseCluster.isEmpty {
            userInfo.expenseCluster = [ExpenseCluster(id: newExpenseClusterId, date: date, expenses: [expense])]
        } else if userInfo.expenseCluster.contains(where: {
            Calendar.current.isDate($0.date, equalTo: date, toGranularity: .day)
        }) {
            // add the expense to the expense cluster with the same date
            for (index, expenseCluster) in userInfo.expenseCluster.enumerated() {
                if Calendar.current.isDate(expenseCluster.date, equalTo: date, toGranularity: .day) {
                    userInfo.expenseCluster[index].expenses.append(expense)
                    break
                }
            }
        } else {
            // no group with same date -> create expenseCluster
            userInfo.expenseCluster.append(ExpenseCluster(id: newExpenseClusterId, date: date, expenses: [expense]))
        }
        decodedUsersInfo[userIndex] = userInfo
        if let encoded = try? decodedUsersInfo.encode() {
            dataManager.setUserInfo(encoded)
        }
    }
    
    func saveEditedExpense(expenseClusterId: UUID, date: Date, expense newExpense: Expense) {
        guard let allExpenses = try? dataManager.getExpenseClusters() else {
            return
        }
        guard var previousUpdatedExpenseCluster = allExpenses.first(where: {
            $0.id == expenseClusterId
        }) else {
            return
        }
        guard let previousSavedExpense = previousUpdatedExpenseCluster.expenses.first(where: {
            $0.id == newExpense.id
        }) else {
            return
        }
        // guard expense data has been changed
        guard previousSavedExpense.title != newExpense.title ||
                previousSavedExpense.amount != newExpense.amount ||
                previousUpdatedExpenseCluster.date != date
        else {
            return
        }
        if !Calendar.current.isDate(previousUpdatedExpenseCluster.date, equalTo: date, toGranularity: .day) {
            // edited the date
            // 1. check if expense with new date existes.
            previousUpdatedExpenseCluster.expenses.removeAll(where: {
                $0.id == newExpense.id
            })
            
            // 2. check if old date has other expenses then will need to save both old and new dates
            if previousUpdatedExpenseCluster.expenses.isEmpty == false {
                updateExpenseCluster(previousUpdatedExpenseCluster)
            } else {
                //remove expense
                removeExpense(expenseId: expenseClusterId)
            }
            // find expense to update
            // if exists - update it.
            // else create new expense with given data parameters
            
            if var expenseCluster = allExpenses.first(where: {
                Calendar.current.isDate($0.date, equalTo: date, toGranularity: .day)
            }) {
                expenseCluster.expenses.append(newExpense)
                updateExpenseCluster(expenseCluster)
            } else {
                // save user expense changes to memory
                updateExpenseCluster(ExpenseCluster(id: UUID(), date: date, expenses: [newExpense]))
            }
        } else {
            // same date - the info's been changed/updated
            for (index, expense) in previousUpdatedExpenseCluster.expenses.enumerated() {
                if expense.id == newExpense.id {
                    previousUpdatedExpenseCluster.expenses[index] = newExpense
                    break
                }
            }
            updateExpenseCluster(previousUpdatedExpenseCluster)
        }
    }
    
    // MARK: - Private helpers
    
    private func updateExpenseCluster(_ updatedExpenseCluster: ExpenseCluster) {
        let date = updatedExpenseCluster.date
        guard var decodedUsersInfo = try? dataManager.getAllUsersInfoArray(),
              let userInfoAndIndex = try? getUserInfoAndIndex(decodedUsersInfo: decodedUsersInfo),
              var userInfo = userInfoAndIndex.userInfo else {
            return
        }
        let userIndex = userInfoAndIndex.userIndex
        if userInfo.expenseCluster.isEmpty {
            userInfo.expenseCluster = [updatedExpenseCluster]
        } else if userInfo.expenseCluster.contains(where: {
            Calendar.current.isDate($0.date, equalTo: date, toGranularity: .day)
        }) {
            for (index, expense) in userInfo.expenseCluster.enumerated() {
                if Calendar.current.isDate(expense.date, equalTo: date, toGranularity: .day) {
                    userInfo.expenseCluster[index] = updatedExpenseCluster
                    break
                }
            }
        } else {
            //no expense with given/edited date.
            userInfo.expenseCluster.append(updatedExpenseCluster)
        }
        decodedUsersInfo[userIndex] = userInfo
        if let encoded = try? decodedUsersInfo.encode() {
            dataManager.setUserInfo(encoded)
        }
    }
    
    private func getUserInfoAndIndex(decodedUsersInfo: [UserInfo]) throws -> (userInfo: UserInfo?, userIndex: Int) {
        var userIndex = 0
        var userInfo: UserInfo? = nil
        do {
            let currentUserId = try dataManager.getCurrentUserId()
            for (index, infoItem) in decodedUsersInfo.enumerated() {
                if infoItem.id == currentUserId {
                    userInfo = infoItem
                    userIndex = index
                    break
                }
            }
            return (userInfo, userIndex)
        } catch {
            throw error
        }
    }
    
    private func removeExpense(expenseId: UUID) {
        guard var decodedUsersInfo = try? dataManager.getAllUsersInfoArray(),
              let userInfoAndIndex = try? getUserInfoAndIndex(decodedUsersInfo: decodedUsersInfo),
              var userInfo = userInfoAndIndex.userInfo else {
            return
        }
        let userIndex = userInfoAndIndex.userIndex
        var allExpenses = userInfo.expenseCluster
        allExpenses.removeAll(where: {$0.id == expenseId})
        userInfo.expenseCluster = allExpenses
        decodedUsersInfo[userIndex] = userInfo
        if let encoded = try? decodedUsersInfo.encode() {
            dataManager.setUserInfo(encoded)
        }
    }
}
