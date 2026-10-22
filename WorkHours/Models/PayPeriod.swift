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
        guard payPeriodStart <= payPeriodEnd,
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

    func getNextPayPeriod(payPeriodFrequency: PayFrequency, calendar: Calendar = .current ) -> PayPeriodSnapshot? {
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
    
    var employer: EmployerModel?
    
    var payPeriodStartDate: Date
    var payPeriodEndDate: Date
    
    @Relationship(deleteRule: .cascade, inverse: \WorkTicket.payPeriod)
    var workTickets: [WorkTicket]
    
    init(employer: EmployerModel? = nil, payPeriodStartDate: Date, payPeriodEndDate: Date, workTickets: [WorkTicket] = []) {
        self.employer = employer
        self.payPeriodStartDate = payPeriodStartDate
        self.payPeriodEndDate = payPeriodEndDate
        self.workTickets = workTickets
    }
    
    func getWageInformation() -> Double? {
        return nil
    }
    
    func calculateHours() -> Double {
        var hours: Double = 0
        for ticket in workTickets {
            hours += ticket.getHoursWorked()
        }
        return hours
    }
    
    func calculateEstimatedPay() -> Double {
        var estimate = 0.0
        for ticket in workTickets {
            estimate += ticket.getGrossPay()
        }
        return estimate
    }
}
