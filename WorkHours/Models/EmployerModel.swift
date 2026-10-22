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
        return wage?.formatted(.number.precision(.fractionLength(2))) ?? "Varies"
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
        self.currentPayPeriodStart = currentPayPeriodStart
        self.currentPayPeriodEnd = currentPayPeriodEnd
        self.PayPeriods = PayPeriods
    }
    
    func getPayPeriods() -> [PayPeriod] {
        return self.PayPeriods
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
    
    func updatePayPeriod(){
        guard let future = getNextPayPeriod() else { return }
        self.currentPayPeriodStart = future.payPeriodStart
        self.currentPayPeriodEnd = future.payPeriodEnd
        
        // Create next pay period:
        
        
        // Save
    }
    
}
