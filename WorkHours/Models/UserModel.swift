//
//  UserModel.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-09-20.
//

import Foundation
import SwiftData
import Combine

enum PayFrequency: String, CaseIterable, Codable {
    case none = "None"
    case daily = "Daily"
    case weekly = "Weekly"
    case biweekly = "Bi-Weekly"
    case monthly = "Monthly"
}

final class UserModel: Codable, Observable {
    var firstName: String
    var lastName: String
    var trackTravelTime: Bool
    
    
    init(firstName: String, lastName: String, trackTravelTime: Bool) {
        self.firstName = firstName
        self.lastName = lastName
        self.trackTravelTime = trackTravelTime
    }
}
