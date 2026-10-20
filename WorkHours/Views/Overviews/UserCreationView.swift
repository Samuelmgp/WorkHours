//
//  UserCreationView.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-09-20.
//

import SwiftUI
import SwiftData

struct UserCreationView: View {
    
    @Environment(\.modelContext) var context
    
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var employer: String = ""
    
    @State var payPeriodStartDate: Date = .now
    @State var payPeriodEndDate: Date = .now
    @State var payPeriodFrequency: payFrequency = .none
    @State var hoursRounding: WorkHoursRoundingOptions = .none
    @State var wageFieldValue: Double = 0.0
    
    @State var travelTimeTracking: Bool = false
    
    @Binding var isShowingUserCreation: Bool
    
    
    var body: some View {
        Form {
            Section("User Information"){
                InputField("First Name", "person", text: $firstName)
                    .textContentType(.givenName)
                InputField("Last Name", "person", text: $lastName)
                    .textContentType(.familyName)
                InputField("Employer", "suitcase", text: $employer)
                    .textContentType(.organizationName)
            }
            
            Section("Current Pay Period"){
                DatePicker("Start Date", selection: $payPeriodStartDate, displayedComponents: .date)
                DatePicker("End Date", selection: $payPeriodEndDate, displayedComponents: .date)
            }
            
            Section("Pay Period Advanced Details"){
                Picker("Payment Frequency", selection: $payPeriodFrequency){
                    ForEach(payFrequency.allCases, id: \.self){ t in
                        Text(t.rawValue)
                    }
                }
                
                Picker("Hours Rounding", selection: $hoursRounding){
                    ForEach(WorkHoursRoundingOptions.allCases, id: \.self){ t in
                        Text(t.getTitle())
                    }
                }
                
                WageInput(value: $wageFieldValue)
            }
            
            Section ("Travel Time Tracking"){
                Toggle("Enable Travel Time", systemImage: "clock", isOn: $travelTimeTracking)
            }
            
            Button {
                isShowingUserCreation = false
                saveUser()
            } label: {
                Text("Create User")
            }
            .disabled(!isShowingUserCreation)
        }
        .navigationTitle("Profile")
    }
    
    func saveUser(){
        // Set appropriate times:
        guard let temp_start = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: payPeriodStartDate) else { return }
        
        guard let temp_end = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: payPeriodEndDate) else { return }
        payPeriodStartDate = temp_start
        payPeriodEndDate = temp_end
        
        let user = UserManager.shared.createUser(firstName: firstName, lastName: lastName, employer: employer, payweekStart: payPeriodStartDate, payweekEnd: payPeriodEndDate, paidFrequency: payPeriodFrequency, hourRounding: hoursRounding, wage: wageFieldValue, trackTravelTime: travelTimeTracking)
        
        let firstPayPeriod = PayPeriod(payPeriodStartDate: payPeriodStartDate, payPeriodEndDate: payPeriodEndDate, payRate: wageFieldValue)
        
        if (firstPayPeriod.payPeriodEndDate < Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: .now)!){
            user?.updateCurrentPayPeriod()
        } else {
            context.insert(firstPayPeriod)
            do {
                try context.save()
            } catch {
                print("Error \(error.localizedDescription)")
            }
        }
    
        isShowingUserCreation = user == nil
    }
}

#Preview {
    @Previewable @State var isPresented = true
    UserCreationView(isShowingUserCreation: $isPresented)
}
