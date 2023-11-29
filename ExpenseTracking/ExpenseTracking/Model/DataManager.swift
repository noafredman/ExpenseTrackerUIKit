//
//  DataManager.swift
//  ExpenseTracking
//
//  Created by Noa Fredman.
//

import Foundation

protocol DataManagerProtocol {
    static var shared: DataManagerProtocol { get }
    var userDefaults: UserDefaults { set get }
    func handleLogin(userInfo: UserInfo) throws
    func getCurrentUserName() -> String?
    func getExpenseClusters() throws -> [ExpenseCluster]
    func getAllUsersInfoArray() throws -> [UserInfo]
    func getCurrentUserId() throws -> UUID
    func setUserInfo(_ encoded: Data)
    func handleLogout()
}

final class DataManager: DataManagerProtocol {
    
    enum DataManagerError {
        enum CodablesError: Error {
            case encodingSaveFirstUserError
            case encodingCurrentUserIdOfExistingUserError
            case retrievingSavedCurrentUserIdError
            case retrievingSavedCurrentUserInfoError
            case retrievingSavedUserInfoError
            case decodingSavedUserInfoError
            case decodingSavedCurrentUserIdError
        }
        
        enum UserInfoError: Error {
            case couldNotFindUserForCurrentUserId
            case encodingCurrentUserIdOfExistingUserError
            case decodingSavedUserInfoError
        }
    }
    
    static var shared: DataManagerProtocol = DataManager()
    var userDefaults: UserDefaults = UserDefaults.standard
    
    private init() { }
    
    func getExpenseClusters() throws -> [ExpenseCluster] {
        let currentUserId = try getCurrentUserId()
        let usersInfo = try getAllUsersInfoArray()
        for info in usersInfo {
            if info.id == currentUserId {
                return info.expenseCluster
            }
        }
        throw DataManagerError.UserInfoError.couldNotFindUserForCurrentUserId
    }
    
    func getAllUsersInfoArray() throws -> [UserInfo] {
        guard let expenses = userDefaults.data(forKey: UserDefaultsKeys.usersInfo.rawValue) else {
            throw DataManagerError.CodablesError.retrievingSavedUserInfoError
        }
        guard let decodedUserInfoArray = try? JSONDecoder().decode([UserInfo].self, from: expenses) else {
            throw DataManagerError.CodablesError.decodingSavedUserInfoError
        }
        return decodedUserInfoArray
    }
    
    func getCurrentUserId() throws -> UUID {
        guard let currentUserIdData = userDefaults.data(forKey: UserDefaultsKeys.currentUserId.rawValue) else {
            throw DataManagerError.CodablesError.retrievingSavedCurrentUserIdError
        }
        guard let currentUserId =  try? JSONDecoder().decode(UUID.self, from: currentUserIdData) else {
            throw DataManagerError.CodablesError.decodingSavedCurrentUserIdError
        }
        return currentUserId
    }
    
    func getCurrentUserName() -> String? {
        if let str = userDefaults.string(forKey: UserDefaultsKeys.currentUserName.rawValue) {
            return str
        }
        return nil
    }
    
    func handleLogin(userInfo: UserInfo) throws {
        let name = userInfo.name
        if let savedUserInfo = userDefaults.data(forKey: UserDefaultsKeys.usersInfo.rawValue) {
            if var decodedUsersInfo = try? JSONDecoder().decode([UserInfo].self, from: savedUserInfo) {
                if let savedUserInfo = decodedUsersInfo.first (where: { $0.name == name}) {
                    // existing user
                    if let encodedUserId = try? savedUserInfo.id.encode() {
                        userDefaults.set(encodedUserId, forKey: UserDefaultsKeys.currentUserId)
                        userDefaults.set(name, forKey: UserDefaultsKeys.currentUserName)
                    } else {
                        throw DataManagerError.CodablesError.encodingCurrentUserIdOfExistingUserError
                    }
                } else {
                    // new user
                    decodedUsersInfo.append(userInfo)
                    if let encodedUsersInfo = try? decodedUsersInfo.encode(),
                       let encodedUserId = try? userInfo.id.encode() {
                        userDefaults.set(encodedUsersInfo, forKey: UserDefaultsKeys.usersInfo)
                        userDefaults.set(name, forKey: UserDefaultsKeys.currentUserName)
                        userDefaults.set(encodedUserId, forKey: UserDefaultsKeys.currentUserId)
                    } else {
                        throw DataManagerError.CodablesError.encodingSaveFirstUserError
                    }
                }
            } else {
                throw DataManagerError.CodablesError.decodingSavedUserInfoError
            }
        } else {
            //first user to log in
            if let encodedUsersInfo = try? [userInfo].encode(),
               let encodedUserId = try? userInfo.id.encode() {
                userDefaults.set(encodedUsersInfo, forKey: UserDefaultsKeys.usersInfo)
                userDefaults.set(name, forKey: UserDefaultsKeys.currentUserName)
                userDefaults.set(encodedUserId, forKey: UserDefaultsKeys.currentUserId)
            } else {
                throw DataManagerError.CodablesError.encodingSaveFirstUserError
            }
        }
    }
    
    func setUserInfo(_ encoded: Data) {
        userDefaults.set(encoded, forKey: UserDefaultsKeys.usersInfo)
    }
    
    func handleLogout() {
        userDefaults.removeObject(forKey: UserDefaultsKeys.currentUserName)
        userDefaults.removeObject(forKey: UserDefaultsKeys.currentUserId)
    }
}
