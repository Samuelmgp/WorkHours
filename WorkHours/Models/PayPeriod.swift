//
//  PayPeriod.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-09-24.
//

import Foundation
import SwiftData

@Model
final class PayPeriod {
    var payPeriodStartDate: Date
    var payPeriodEndDate: Date
    var payRate: Double

    private var totalHoursWorked: Double
    private var estimatedPay: Double
    
    @Relationship(deleteRule: .cascade, inverse: \WorkHoursTicket.payPeriod)
    var workTickets: [WorkHoursTicket]
    
    init(payPeriodStartDate: Date, payPeriodEndDate: Date, payRate: Double = 0, totalHoursWorked: Double = 0, estimatedPay: Double = 0, workTickets: [WorkHoursTicket] = []) {
        // Set Start Date to 12am & End Date to 23:59:59pm
        let temp_payweekStart = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: payPeriodStartDate)
        let temp_payweekEnd = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: payPeriodEndDate)
        if (temp_payweekStart != nil && temp_payweekEnd != nil) {
            self.payPeriodStartDate = temp_payweekStart!
            self.payPeriodEndDate = temp_payweekEnd!
        } else {
            self.payPeriodStartDate = payPeriodStartDate
            self.payPeriodEndDate = payPeriodEndDate
        }
        self.payRate = payRate
        self.totalHoursWorked = totalHoursWorked
        self.estimatedPay = estimatedPay
        self.workTickets = workTickets
    }
    
    func getHoursWorked() -> Double {
        return self.totalHoursWorked
    }
    
    func getPayRate() -> Double {
        return self.payRate
    }
    
    
    func calculateHours() -> Double {
        var hours: Double = 0
        for ticket in workTickets {
            hours += ticket.getHoursWorked()
        }
        self.totalHoursWorked = hours
        return hours
    }
    
    func calculateEstimatedPay() -> Double {
        self.estimatedPay = payRate * totalHoursWorked
        return self.estimatedPay
    }
}
