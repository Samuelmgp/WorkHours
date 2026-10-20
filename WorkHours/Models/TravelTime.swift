//
//  TravelTime.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-10-19.
//

import Foundation
import SwiftData

@Model
final class TravelTime {
    private var travelTimeStart: Date
    private var travelTimeEnd: Date?
    private var duration: TimeInterval?
    
    init(travelTimeStart: Date = .now, travelTimeEnd: Date? = nil, duration: TimeInterval? = nil) {
        self.travelTimeStart = travelTimeStart
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
