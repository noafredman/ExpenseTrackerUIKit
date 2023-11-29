//
//  LoginViewModel.swift
//  ExpenseTracking
//
//  Created by Noa Fredman.
//

import Foundation

enum UserDefaultsKeys: String {
    case usersInfo
    case currentUserId
    case currentUserName
}

protocol LoginViewModelProtocol {
    func didLogin(name: String) throws
}

final class LoginViewModel: LoginViewModelProtocol {
    let dataManager: DataManagerProtocol
    
    init(dataManager: DataManagerProtocol) {
        self.dataManager = dataManager
    }
    
    func didLogin(name: String) throws {
        let userInfo = UserInfo(id: UUID(), name: name)
        try dataManager.handleLogin(userInfo: userInfo)
    }
}
