//
//  EmployerModel.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-10-20.
//

import Foundation
import SwiftData

@Model
final class EmployerModel {
    
    var employerName: String
    var employerColor: String?
    private var employedSince: Date
    
    private var wage: Double?
    private var hourRounding: WorkHoursRoundingOptions
    
    private var payPeriodFrequency: PayFrequency
    private var currentPayPeriodStart: Date?
    private var currentPayPeriodEnd: Date?
    
    @Relationship(deleteRule: .cascade, inverse: \PayPeriod.employer)
    private var PayPeriods: [PayPeriod]
    
    init(employerName: String, employedSince: Date, payPeriodFrequency: PayFrequency, wage: Double? = nil, hourRounding: WorkHoursRoundingOptions, currentPayPeriodStart: Date, currentPayPeriodEnd: Date, PayPeriods: [PayPeriod] = [], employerColor: String = "") {
        self.employerName = employerName
        self.employerColor = employerColor
        self.employedSince = employedSince
        self.payPeriodFrequency = payPeriodFrequency
        self.wage = wage
        self.hourRounding = hourRounding
        self.PayPeriods = PayPeriods
        // Set current pay period:
        let currentPeriod = createPayPeriod(payPeriodStart: currentPayPeriodStart, payPeriodEnd: currentPayPeriodEnd)
        
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
        guard let sanatized = PayPeriodSanitizer(payPeriodStart: startDate, payPeriodEnd: endDate)
        else { return nil }
        
        let newPayPeriod = PayPeriod(employer: self, payPeriodStartDate: sanatized.payPeriodStart, payPeriodEndDate: sanatized.payPeriodEnd)
        
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
    
    /**
     This method will be responsible for adding WorkTickets to an employer.
     - parameters: TempWorkTicket, PayArrangement
     - returns: AddWorkTicketResult [succes: Bool, error: String]
     */
    func addWorkTicket(snapshot: TicketSnapshot) -> AddWorkTicketResult{
        // First determine if there is a valid pay period
        guard let period = getCurrentPayPeriod()
        else { return AddWorkTicketResult(
            success: false,
            error: "There is no current pay periods for this employer.")
        }
        
        // Determine if the period is eligable
        let contains = period.contains(snapshot.ticket.date)
        var possiblePeriod: PayPeriod? = nil
        
        if contains {
            possiblePeriod = getCurrentPayPeriodModel()
        } else {
            return AddWorkTicketResult(
                success: false,
                error: """
                The tickets date range is outside the scope for the current pay period.
                Current Period: \(period.payPeriodStart.formatted(date: .abbreviated, time: .standard)) - \(period.payPeriodEnd.formatted(date: .abbreviated, time: .standard))
                Ticket Date: \(snapshot.ticket.date.formatted(date: .abbreviated, time: .standard))
                The work date must be between 
                \(period.payPeriodStart.formatted(date: .abbreviated, time: .standard)) (inclusive) 
                and 
                \(period.payPeriodEnd.formatted(date: .abbreviated, time: .standard)) (exclusive).
                """)
        }
        
        guard let period = possiblePeriod else {
            return AddWorkTicketResult(
                success: false,
                error: "An error occurred and the possible pay period is not available. Please try again later, or manually add your hours to this employer.")
        }
        
        let finalTicket = {
            switch snapshot.payArrangement {
            case .hourly:
                return WorkTicket(workingHours: snapshot.ticket, payArrangement: .hourly(rate: snapshot.amount), roundingOption: snapshot.roundingOption)
            case .lumpSum:
                return WorkTicket(workingHours: snapshot.ticket, payArrangement: .lumpSum(amount: snapshot.amount), roundingOption: snapshot.roundingOption)
            }
        }()
        
        period.addWorkTicket(ticket: finalTicket)
        
        return AddWorkTicketResult(success: true)
    }
}

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

struct AddWorkTicketResult {
    let success: Bool
    let error: String
    
    init(success: Bool, error: String = "") {
        self.success = success
        self.error = error
    }
}
