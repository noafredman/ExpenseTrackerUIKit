//
//  ProfileViewModel.swift
//  ExpenseTracking
//
//  Created by Noa Fredman.
//

import Foundation
import Combine

protocol ProfileViewModelProtocol {
    var state: ProfileViewModel.State { get }
    func refreshData()
    func logout()
}

final class ProfileViewModel: ProfileViewModelProtocol {
    final class State {
        @Published var totalExpenseItems: String = "0"
    }
    var dataManager: DataManagerProtocol!
    var state = State()
    init(dataManager: DataManagerProtocol) {
        self.dataManager = dataManager
        refreshData()
    }
 
    func refreshData() {
        state.totalExpenseItems = ((try? dataManager.getExpenseClusters().reduce(0) {
            $0 + $1.expenses.count
        }) ?? 0).description
    }
    
    func logout() {
        dataManager.handleLogout()
    }
}
