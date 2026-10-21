//
//  WorkedHoursTicket.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-09-18.
//

import Foundation
import SwiftData

enum WorkHoursRoundingOptions: Double, CaseIterable, Codable {
    case none = 0
    case quartHour = 15
    case halfHour = 30
    case hour = 60
    
    func getTitle() -> String {
        switch self {
        case .none: return "Exact Hours"
        case .quartHour: return "Quarter Hour"
        case .halfHour: return "Half Hour"
        case .hour: return "Hour"
        }
    }
}

enum PayArrangement {
    case hourly(rate: Double)
    case lumpSum(amount: Double)
}

@Model
final class WorkTicket {
    var payPeriod: PayPeriod?
    
    private var workDate: Date
    private var startTime: Date
    private var endTime: Date
    
    @Relationship(deleteRule: .cascade, maximumModelCount: 2, inverse: \TravelTime.workHourTicket)
    private var travelTimes: [TravelTime]
    private var totalTravelDurration: TimeInterval?
    
    private var payType: String
    private var payArrangement: PayArrangement {
        switch payType {
        case "hourly":
            return .hourly(rate: payAmount)
        default:
            return .lumpSum(amount: payAmount)
        }
    }
    
    
    private var payAmount: Double
    private var hoursWorked: TimeInterval
    private var roundingOption: WorkHoursRoundingOptions
    
    init(workDate: Date, startTime: Date, endTime: Date = .now, payArrangement: PayArrangement, travelTimes: [TravelTime] = [], roundingOption: WorkHoursRoundingOptions = .none) {
        self.workDate = workDate
        self.startTime = startTime
        self.endTime = endTime
        self.hoursWorked = endTime.timeIntervalSince(startTime)
        self.roundingOption = roundingOption
        self.travelTimes = travelTimes
        switch(payArrangement){
        case .hourly(let rate):
            self.payType = "hourly"
            self.payAmount = rate
        case .lumpSum(let amount):
            self.payType = "lumpSum"
            self.payAmount = amount
        }
    }
    
    convenience init(workingHours: WorkingHours, payArrangement: PayArrangement) {
        self.init(workDate: workingHours.date, startTime: workingHours.date, endTime: .now, payArrangement: payArrangement)
    }
    
    func update(workDate: Date, endTime: Date, roundingOption: WorkHoursRoundingOptions) {
        self.workDate = workDate
        self.startTime = workDate
        self.endTime = endTime
        self.hoursWorked = endTime.timeIntervalSince(self.startTime)
        self.roundingOption = roundingOption
    }
    
    func getGrossPay() -> Double {
        switch payArrangement {
        case .hourly(let rate):
            return rate * getHoursWorked()
        case .lumpSum(let amount):
            return amount
        }
    }
    
    func getWorkDate() -> Date {
        return self.workDate
    }
    
    func getStartTime() -> Date {
        return self.startTime
    }
    
    func getEndTime() -> Date {
        return self.endTime
    }
    
    func getRoundingOption() -> WorkHoursRoundingOptions {
        return self.roundingOption
    }
    
    func getHoursWorked() -> Double {
        let minutes = hoursWorked / 60.0

        guard self.roundingOption.rawValue != 0 else {
            return minutes / 60.0
        }

        let roundedMinutes = ceil(minutes / self.roundingOption.rawValue) * self.roundingOption.rawValue

        return roundedMinutes / 60.0
    }
    
    func getHoursWorkedFormattedHM() -> String {
        return Duration.seconds(hoursWorked).formatted(.time(pattern: .hourMinute))
    }
    
}
