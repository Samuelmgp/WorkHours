//
//  PayPeriod.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-09-24.
//

import Foundation
import SwiftData

struct PayPeriodSnapshot {
    let payPeriodStart: Date
    let payPeriodEnd: Date

    init?(payPeriodStart: Date, payPeriodEnd: Date, calendar: Calendar = .current) {
        guard payPeriodStart < payPeriodEnd,
              let start = calendar.dateInterval(
                  of: .day,
                  for: payPeriodStart
              )?.start,
              let end = calendar.dateInterval(
                  of: .day,
                  for: payPeriodEnd
              )?.end
        else {
            return nil
        }

        self.payPeriodStart = start
        self.payPeriodEnd = end
    }

    func getNextPayPeriod(payPeriodFrequency: payFrequency, calendar: Calendar = .current ) -> PayPeriodSnapshot? {
        let nextStart: Date
        let nextEnd: Date

        switch payPeriodFrequency {
        case .daily:
            guard
                let start = calendar.date(
                    byAdding: .day,
                    value: 1,
                    to: payPeriodStart
                ),
                let end = calendar.date(
                    byAdding: .day,
                    value: 1,
                    to: payPeriodEnd
                )
            else { return nil }

            nextStart = start
            nextEnd = end

        case .weekly:
            guard
                let start = calendar.date(
                    byAdding: .day,
                    value: 7,
                    to: payPeriodStart
                ),
                let end = calendar.date(
                    byAdding: .day,
                    value: 7,
                    to: payPeriodEnd
                )
            else { return nil }

            nextStart = start
            nextEnd = end

        case .biweekly:
            guard
                let start = calendar.date(
                    byAdding: .day,
                    value: 14,
                    to: payPeriodStart
                ),
                let end = calendar.date(
                    byAdding: .day,
                    value: 14,
                    to: payPeriodEnd
                )
            else { return nil }

            nextStart = start
            nextEnd = end

        case .monthly:
            guard
                let start = calendar.date(
                    byAdding: .month,
                    value: 1,
                    to: payPeriodStart
                ),
                let end = calendar.date(
                    byAdding: .month,
                    value: 1,
                    to: payPeriodEnd
                )
            else { return nil }

            nextStart = start
            nextEnd = end

        case .none:
            return nil
        }

        return PayPeriodSnapshot(payPeriodStart: nextStart, payPeriodEnd: nextEnd, calendar: calendar)
    }

    func contains(_ date: Date) -> Bool {
        date >= payPeriodStart && date < payPeriodEnd
    }
}

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
