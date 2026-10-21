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
    
    /**
     - returns : Employed Since formatted into Months & Years
     */
    func getEmployedSinceFormatted() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.year, .month]
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 2
        return formatter.string(from: self.employedSince, to: .now) ?? "Unavailable"
    }
}

@Model
final class EmployerModel {
    
    private var employerName: String
    private var employedSince: Date
    
    private var payPeriodFrequency: payFrequency
    private var wage: Double?
    private var hourRounding: WorkHoursRoundingOptions
    
    private var currentPayPeriodStart: Date?
    private var currentPayPeriodEnd: Date?
    
    @Relationship(deleteRule: .cascade) private var PayPeriods: [PayPeriod]
    
    init(employerName: String, employedSince: Date, payPeriodFrequency: payFrequency, wage: Double? = nil, hourRounding: WorkHoursRoundingOptions, currentPayPeriodStart: Date, currentPayPeriodEnd: Date, PayPeriods: [PayPeriod] = []) {
        self.employerName = employerName
        self.employedSince = employedSince
        self.payPeriodFrequency = payPeriodFrequency
        self.wage = wage
        self.hourRounding = hourRounding
        self.currentPayPeriodStart = currentPayPeriodStart
        self.currentPayPeriodEnd = currentPayPeriodEnd
        self.PayPeriods = PayPeriods
    }
    
    func getDetails() -> EmployerDetails {
        return EmployerDetails(employerName: self.employerName, employedSince: self.employedSince)
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
    
    func updatePayPeriodFrequency(payFrequency: payFrequency){
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
        let newPayPeriod = PayPeriod(payPeriodStartDate: future.payPeriodStart, payPeriodEndDate: future.payPeriodEnd)
    }
    
}
