//
//  UserModel.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-09-20.
//

import Foundation

final class UserModel: Codable {
    var firstName: String
    var lastName: String
    
    // MARK: Modifiable Settings:
    var trackTravelTime: Bool
    
    /// Pay period global settings
    var deletePastPayPeriods: Bool
    var deletePayPeriodAfter: DeletableAfter
    
    
    init(firstName: String, lastName: String, trackTravelTime: Bool) {
        self.firstName = firstName
        self.lastName = lastName
        // Settings
        self.trackTravelTime = trackTravelTime
        self.deletePastPayPeriods = false
        self.deletePayPeriodAfter = .never
    }
}

// MARK: Enums associated with UserModel

enum PayFrequency: String, CaseIterable, Codable {
    case none = "None"
    case daily = "Daily"
    case weekly = "Weekly"
    case biweekly = "Bi-Weekly"
    case monthly = "Monthly"
}

enum DeletableAfter: String, CaseIterable, Codable {
    case never = "N/A"
    case month = "a Month"
    case trimester = "3 Months"
    case quarterly = "4 Months"
    case semi_annually = "6 Months"
    case annually = "A Year"
}
