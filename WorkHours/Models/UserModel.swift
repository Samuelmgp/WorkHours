//
//  UserModel.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-09-20.
//

import Foundation
import SwiftData
import Combine

enum PayFrequency: String, CaseIterable, Codable {
    case none = "None"
    case daily = "Daily"
    case weekly = "Weekly"
    case biweekly = "Bi-Weekly"
    case monthly = "Monthly"
}

final class UserModel: Codable, Observable {
    var firstName: String
    var lastName: String
    var employer: String
    
    var currentPayPeriodStartDate: Date
    var currentPayPeriodEndDate: Date
    
    var nextPayPeriodStartDate: Date?
    var nextPayPeriodEndDate: Date?
    
    var paidFrequency: PayFrequency
    var hourRounding: WorkHoursRoundingOptions
    var wage: Double
    
    var trackTravelTime: Bool
    
    
    init(firstName: String, lastName: String, employer: String, payweekStart: Date, payweekEnd: Date, paidFrequency: PayFrequency = .none, hourRounding: WorkHoursRoundingOptions = .none, wage: Double = 0.0, trackTravelTime: Bool = false) {
        self.firstName = firstName
        self.lastName = lastName
        self.employer = employer
        self.currentPayPeriodStartDate = payweekStart
        self.currentPayPeriodEndDate = payweekEnd
        self.paidFrequency = paidFrequency
        self.hourRounding = hourRounding
        self.wage = wage
        self.trackTravelTime = trackTravelTime
        self.setNextPayPeriod()
    }

    func setNextPayPeriod(){
        switch (self.paidFrequency){
            case .daily:
            self.nextPayPeriodStartDate = Calendar.current.date(byAdding: .day, value: 1, to: self.currentPayPeriodStartDate)
            self.nextPayPeriodEndDate = Calendar.current.date(byAdding: .day, value: 1, to: self.currentPayPeriodEndDate)
            case .weekly:
                self.nextPayPeriodStartDate = Calendar.current.date(byAdding: .day, value: 7, to: self.currentPayPeriodStartDate)
                self.nextPayPeriodEndDate = Calendar.current.date(byAdding: .day, value: 7, to: self.currentPayPeriodEndDate)
            case .biweekly:
                self.nextPayPeriodStartDate = Calendar.current.date(byAdding: .day, value: 14, to: self.currentPayPeriodStartDate)
                self.nextPayPeriodEndDate = Calendar.current.date(byAdding: .day, value: 14, to: self.currentPayPeriodEndDate)
            case .monthly:
                self.nextPayPeriodStartDate = Calendar.current.date(byAdding: .month, value: 1, to: self.currentPayPeriodStartDate)
                self.nextPayPeriodEndDate = Calendar.current.date(byAdding: .day, value: 1, to: self.currentPayPeriodEndDate)
            default:
                self.nextPayPeriodStartDate = nil
                self.nextPayPeriodEndDate = nil
        }
        
        UserManager.shared.saveUser(self)
    }
    
    //TODO: Ensure Current Pay Period Has Ended
    func updateCurrentPayPeriod(){
        self.currentPayPeriodStartDate = self.nextPayPeriodStartDate ?? self.currentPayPeriodStartDate
        self.currentPayPeriodEndDate = self.nextPayPeriodEndDate ?? self.currentPayPeriodEndDate
        
        // Create new Pay Period Model:
        guard let container = try? ModelContainer(for: PayPeriod.self) else { setNextPayPeriod(); return }
        let context = ModelContext(container)
        
        let newPayPeriod = PayPeriod(payPeriodStartDate: self.currentPayPeriodStartDate, payPeriodEndDate: self.currentPayPeriodEndDate, wage: self.wage)
        
        context.insert(newPayPeriod)
        
        do {
            try context.save()
        } catch {
            print("Error: \(error)")
        }
        
        setNextPayPeriod()
    }
}
