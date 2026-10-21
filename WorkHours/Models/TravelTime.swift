//
//  TravelTime.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-10-19.
//

import Foundation
import SwiftData

enum TravelType: String, Codable {
    case toWork
    case toDestination
}

@Model
final class TravelTime {
    var workHourTicket: WorkTicket?
    
    private var travelTimeStart: Date
    private var travelType: TravelType
    private var travelTimeEnd: Date?
    private var duration: TimeInterval?
    
    init(travelTimeStart: Date = .now, travelType: TravelType = .toDestination, travelTimeEnd: Date? = nil, duration: TimeInterval? = nil) {
        self.travelTimeStart = travelTimeStart
        self.travelType = travelType
        self.travelTimeEnd = travelTimeEnd
        self.duration = duration
    }

    func completeTravel(travelTimeEnd: Date){
        self.travelTimeEnd = travelTimeEnd
        self.duration = travelTimeEnd.timeIntervalSince(self.travelTimeStart)
    }
    
    func getTravelStartTime() -> Date {
        return self.travelTimeStart
    }
    
    func getTravelEndTime() -> Date? {
        return self.travelTimeEnd
    }
    
    func getDurration() -> TimeInterval {
        return self.duration ?? 0.0
    }
}
