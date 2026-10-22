//
//  UserManager.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-09-23.
//

import Foundation

/**
 * User Manager Singleton Class
 * This class is designed for the purpose of maintain a globalized user state.
 */
final class UserManager {
    private init(){ }
    private let USER_DATA = "user_data"
    
    static let shared = UserManager()
    
    private var currentUser: UserModel? = nil
    private var currentPayPeriod: PayPeriod? = nil
    
    
    /**
     * Creates a new user and stores it in UserDefaults
    - Returns: UserModel
     *    User data. Or nil if data failed to be encoded.
     */
    func createUser(firstName: String, lastName: String, trackTravelTime: Bool) -> UserModel? {
        let newUser = UserModel(firstName: firstName, lastName: lastName, trackTravelTime: trackTravelTime)
        
        guard let data = try? JSONEncoder().encode(newUser) else { return nil }
        UserDefaults.standard.set(data, forKey: USER_DATA)
        
        self.currentUser = newUser
        
        return newUser
    }
    
    /**
     * Saves current UserModel data to UserDefaults.
     *- Returns: Bool
     *      True: If data encoding was successful & user was saved to UserDefaults
     *      False: If data encoding failed.
     */
    @discardableResult
    func saveUser(_ userModel: UserModel) -> Bool {
        guard let data = try? JSONEncoder().encode(userModel) else { return false}
        UserDefaults.standard.set(data, forKey: USER_DATA)
        return true
    }
    
    /**
     * Loads a UserModel from UserDefaults.
     * - Returns: UserModel?
     *      UserMode: If successful decoding of Data from UserDefaults
     *      `nil`: If data does not exist or if decoding failed.
     */
    func loadUser() -> UserModel? {
        guard let data = UserDefaults.standard.data(forKey: USER_DATA) else { return nil }
        guard let user = try? JSONDecoder().decode(UserModel.self, from: data) else { return nil }
        self.currentUser = user
        return user
    }
    
    func deleteUser(){
        UserDefaults.standard.removeObject(forKey: USER_DATA)
        self.currentUser = nil
    }
    
    /**
     * Get current user if any.
     * - Returns: UserModel?
     *      If there currently is a user loaded in it will be returned otherwise nil.
     */
    func user() -> UserModel? {
        return self.currentUser
    }
    
}
