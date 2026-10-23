//
//  ClockOutOverview.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-10-22.
//

import SwiftUI

struct ClockOutOverview: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @Binding var session: WorkingHours?
    var endTime: Date
    
    @State private var employer: EmployerModel?
    @State private var roundingOption: WorkHoursRoundingOptions = .none
    @State private var pay: Double = 0.0
    @State private var payArrangement: PayArrangementOptions = .lumpSum
    
    @State private var isProcessing:Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
            Form {
                Section("Select Employer"){
                    EmployerPicker(selected: $employer)
                        .onChange(of: employer){
                            updateWorkTicket()
                        }
                }
                Section("Date & Time"){
                    Text("\(session?.date.formatted(date: .abbreviated, time: .omitted) ?? "Unavailable")")
                    Group {
                        HSText(lhText: "Start Time", rhText: session?.date.formatted(date: .omitted, time: .standard) ?? "Unavailable", systemImage: "clock")
                            .listRowSeparator(.visible, edges: .top)
                        HSText(lhText: "End Time", rhText: endTime.formatted(date: .omitted, time: .standard), systemImage: "clock")
                            .listRowSeparator(.hidden, edges: .top)
                            .listRowSeparator(.visible, edges: .bottom)
                    }
                }
                .listRowBackground(Color.clear)
                
                Section("Pay Details"){
                    if (employer != nil && payArrangement == .hourly) {
                        Picker("Pay Arrangement", selection: $payArrangement){
                            ForEach(PayArrangementOptions.allCases, id: \.self){ o in
                                Text(o.getTitle())
                            }
                        }
                        HSText(lhText: "Wage", rhText: pay.formatted(.currency(code: "cad")), systemImage: "dollarsign")
                        HSText(lhText: "Rounding", rhText: roundingOption.getTitle())
                    } else if (employer != nil || payArrangement == .lumpSum) {
                        Picker("Pay Arrangement", selection: $payArrangement){
                            ForEach(PayArrangementOptions.allCases, id: \.self){ o in
                                Text(o.getTitle())
                            }
                        }
                        WageInput(value: $pay, placeholder: payArrangement == .lumpSum ? "Payout" : "Wage / Hour")
                        Picker("Rounding", selection: $roundingOption){
                            ForEach(WorkHoursRoundingOptions.allCases, id: \.self){ o in
                                Text(o.getTitle())
                            }
                        }
                    }
                }
                
                errorMessage.isEmpty ? nil :
                Text(errorMessage)
                    .listRowBackground(Color.clear)
                    .font(.footnote)
                    .foregroundStyle(.red)
                
                Button("Save"){
                    isProcessing = true
                    save()
                }
                .buttonStyle(.glassProminent)
                .buttonSizing(.flexible)
                .listRowBackground(Color.clear)
                .disabled(isProcessing)
            }
            .navigationTitle("Summary")
    }
    
    private func save(){
    
        // Validate
        guard let ticket = session?.date else {
            isProcessing = false;
            errorMessage = "FATAL ERROR: Session is no longer available. Please manually enter hours under desired employer pay period."
            return
        }
        guard let desiredEmployer: EmployerModel = employer else {
            isProcessing = false;
            errorMessage = "Error: Please select an employer prior to saving!"
            return
        }
        
        // Obtain Pay Period Details:
        guard let currentPeriod = desiredEmployer.getCurrentPayPeriod() else {
            isProcessing = false;
            errorMessage = "Error: This employer does not have a current pay period available. Please try again later."
            return
        }
        
        var canSave = false
        if (currentPeriod.contains(ticket)){
            // Toggle save option
            canSave = true
        } else {
            if let nextPayPeriod = currentPeriod.getNextPayPeriod(payPeriodFrequency: desiredEmployer.getDetails().payPeriodFrequency) {
                
                canSave = nextPayPeriod.contains(ticket)
                
            }
        }
        
        guard let period = desiredEmployer.getCurrentPayPeriodModel() else {
            isProcessing = false;
            errorMessage = "Error: This employer does not have a current pay period available. Please try again later."
            return
        }
        
        if (canSave){
            
            let finalTicket = {
                switch payArrangement {
                case .hourly :
                    return WorkTicket(workDate: ticket, startTime: ticket, payArrangement: .hourly(rate: pay), roundingOption: roundingOption)
                case .lumpSum :
                    return WorkTicket(workDate: ticket, startTime: ticket, payArrangement: .lumpSum(amount: pay), roundingOption: roundingOption)
                }
            }()
            
            period.addWorkTicket(ticket: finalTicket)
            isProcessing = false
            dismiss()
        } else {
            isProcessing = false;
            errorMessage = "Error: This employer does not have a current pay period available. Please try again later."
            return
        }
        
    }
    
    private func updateWorkTicket(){
        if employer != nil {
            if let details = employer?.getDetails() {
                if let wage: Double = details.wage {
                    pay = wage
                    payArrangement = .hourly
                } else {
                    payArrangement = .lumpSum
                }
                roundingOption = details.hoursRounding
            }
        }
    }
}

#Preview {
    
    @Previewable @State var w: WorkingHours? = WorkingHours(.now)
    
    NavigationView {
        ClockOutOverview(session: $w, endTime: .now)
    }
}
