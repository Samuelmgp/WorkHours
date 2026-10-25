//
//  WorkingHours.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-09-18.
//

import Foundation

/// This is an interface to temporarily store a WorkTicket prior to it being saved as a WorkTicket.

final class TempWorkTicket: Codable {
    
    // MARK: Stores the work date & start time
    var date: Date
    var endTime: Date?
    
    
    enum CodingKeys: CodingKey {
        case date
        case endTime
    }
    
    init(_ date: Date) {
        self.date = date
    }
    
    // MARK: Required for Codable & UserDefaults saving & loading
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.date = try container.decode(Date.self, forKey: .date)
        self.endTime = try container.decode(Date?.self, forKey: .endTime)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.date, forKey: .date)
        try container.encode(self.endTime, forKey: .endTime)
    }
    
    // MARK: Optional method for details
    func getHoursWorked() -> Double? {
        guard let s: TimeInterval = self.endTime?.timeIntervalSince(self.date) else { return nil }
        let min = s / 60
        
        return min / 60
    }
    
    func getHoursWorkedStr() -> String {
        guard let hours = getHoursWorked() else { return "Unavailable" }
        return hours.formatted(.number.precision(.fractionLength(2)))
    }
    
    func getEndTimeStr() -> String {
        guard let str = self.endTime?.formatted(date: .omitted, time: .standard) else {
            return "Unavailable"
        }
        return str
    }
    
}
