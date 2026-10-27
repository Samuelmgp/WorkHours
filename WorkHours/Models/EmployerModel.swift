//
//  EmployerModel.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-10-20.
//

import Foundation
import SwiftData

struct EmployerDetails {
    let employerName: String
    let employedSince: Date
    let wage: Double?
    let hoursRounding: WorkHoursRoundingOptions
    let payPeriodFrequency: PayFrequency
    
    init(employerName: String, employedSince: Date, wage: Double?, hoursRounding: WorkHoursRoundingOptions, payPeriodFrequency: PayFrequency) {
        self.employerName = employerName
        self.employedSince = employedSince
        self.hoursRounding = hoursRounding
        self.payPeriodFrequency = payPeriodFrequency
        self.wage = wage
    }
    
    /**
     - returns : Wage as a string value.
     */
    
    func getWage() -> String {
        if let wage = wage?.formatted(.currency(code: "cad")){
            return "\(wage) / Hour"
        }
        return "Varies"
    }
    
    /**
     - returns : Employed Since formatted into Months & Years
     */
    func getEmployedSinceFormatted() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.year, .month]
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 2
        return formatter.string(from: self.employedSince, to: .now)?.capitalized ?? "Unavailable"
    }
}

@Model
final class EmployerModel {
    
    var employerName: String
    private var employedSince: Date
    
    private var wage: Double?
    private var hourRounding: WorkHoursRoundingOptions
    
    private var payPeriodFrequency: PayFrequency
    private var currentPayPeriodStart: Date?
    private var currentPayPeriodEnd: Date?
    
    @Relationship(deleteRule: .cascade, inverse: \PayPeriod.employer)
    private var PayPeriods: [PayPeriod]
    
    init(employerName: String, employedSince: Date, payPeriodFrequency: PayFrequency, wage: Double? = nil, hourRounding: WorkHoursRoundingOptions, currentPayPeriodStart: Date, currentPayPeriodEnd: Date, PayPeriods: [PayPeriod] = []) {
        self.employerName = employerName
        self.employedSince = employedSince
        self.payPeriodFrequency = payPeriodFrequency
        self.wage = wage
        self.hourRounding = hourRounding
        self.PayPeriods = PayPeriods
        // Set current pay period:
        let currentPeriod = createPayPeriod(payPeriodStart: self.currentPayPeriodStart, payPeriodEnd: self.currentPayPeriodEnd)
        
        self.currentPayPeriodStart = currentPeriod?.payPeriodStartDate
        self.currentPayPeriodEnd = currentPeriod?.payPeriodEndDate
    }
    
    func getPayPeriods() -> [PayPeriod] {
        if (self.PayPeriods.isEmpty){ return [] }
        return self.PayPeriods.sorted(by: {$0.payPeriodStartDate < $1.payPeriodStartDate})
    }
    
    func getCurrentPayPeriodModel() -> PayPeriod? {
        if (self.PayPeriods.isEmpty){ return nil }
        let sortedPayPeriods = self.getPayPeriods()
        
        guard let start = self.currentPayPeriodStart else { return nil }
        guard let period = sortedPayPeriods.last else { return nil }
        
        if period.payPeriodStartDate == start {
            return period
        } else {
            // PayPeriod dates are outdated.
            if start < period.payPeriodStartDate {
                return updatePayPeriod()
            } else if start == period.payPeriodEndDate {
                return createPayPeriod()
            }
        }
        return nil
    }
    
    func getDetails() -> EmployerDetails {
        return EmployerDetails(employerName: self.employerName, employedSince: self.employedSince, wage: self.wage, hoursRounding: self.hourRounding, payPeriodFrequency: self.payPeriodFrequency)
    }
    
    func getCurrentPayPeriod() -> PayPeriodSnapshot? {
        guard let start = self.currentPayPeriodStart, let end = self.currentPayPeriodEnd else {
            return nil
        }
        guard let snapshot = PayPeriodSnapshot(payPeriodStart: start, payPeriodEnd: end) else { return nil }
        return snapshot
    }
    
    func getNextPayPeriod() -> PayPeriodSnapshot? {
        guard let start = self.currentPayPeriodStart, let end = self.currentPayPeriodEnd else {
            return nil
        }
        guard let snapshot = PayPeriodSnapshot(payPeriodStart: start, payPeriodEnd: end) else { return nil }
        
        return snapshot.getNextPayPeriod(payPeriodFrequency: self.payPeriodFrequency)
    }
    
    func updatePayPeriodFrequency(payFrequency: PayFrequency){
        self.payPeriodFrequency = payFrequency
    }
    
    func updateRounding(roundingOption: WorkHoursRoundingOptions){
        self.hourRounding = roundingOption
    }
    
    func updateWage(wage: Double){
        guard wage > 0 else { self.wage = nil; return }
        self.wage = wage
    }
    
    @discardableResult
    func updatePayPeriod() -> PayPeriod? {
        guard let future = getNextPayPeriod() else { return nil }
        self.currentPayPeriodStart = future.payPeriodStart
        self.currentPayPeriodEnd = future.payPeriodEnd
        
        // Create the next pay period
        return createPayPeriod()
    }
    
    /**
     This method is to be utilized only when creating a pay period in UI or at Employer initialization where the pay period dates are non-standard
     date times. This will set the start to the start of the day (inclusive) and end to the start of the next day after pay period end (exclusive).
     - parameters: `payPeriodStart` is a date that is not standardized and can be nil. `payPeriodEnd` is also not standardized.
     */
    @discardableResult
    func createPayPeriod(payPeriodStart: Date?, payPeriodEnd: Date?) -> PayPeriod? {
        guard let startDate: Date = payPeriodStart, let endDate: Date = payPeriodEnd else { return nil }
        guard let snapshot = PayPeriodSnapshot(payPeriodStart: startDate, payPeriodEnd: endDate) else { return nil }
        
        let newPayPeriod = PayPeriod(employer: self, payPeriodStartDate: snapshot.payPeriodStart, payPeriodEndDate: snapshot.payPeriodEnd)
        self.PayPeriods.append(newPayPeriod)
        
        return newPayPeriod
    }
    
    /**
     This method is to be used internally assuming standardized date times.
     */
    @discardableResult
    private func createPayPeriod() -> PayPeriod? {
        guard let startDate: Date = self.currentPayPeriodStart, let endDate: Date = self.currentPayPeriodEnd else { return nil }
        
        let newPayPeriod = PayPeriod(employer: self, payPeriodStartDate: startDate, payPeriodEndDate: endDate)
        self.PayPeriods.append(newPayPeriod)
        
        return newPayPeriod
    }
}
