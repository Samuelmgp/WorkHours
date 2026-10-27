//
//  ClockOutOverview.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-10-22.
//

import SwiftUI

struct TicketSnapshot {
    let ticket: TempWorkTicket
    let payArrangement: PayArrangementOptions
    let amount: Double
    let roundingOption: WorkHoursRoundingOptions
    
    init(ticket: TempWorkTicket, payArrangement: PayArrangementOptions, amount: Double, roundingOption: WorkHoursRoundingOptions) {
        self.ticket = ticket
        self.payArrangement = payArrangement
        self.amount = amount
        self.roundingOption = roundingOption
    }
}

struct ClockOutOverview: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @Binding var session: TempWorkTicket?
    
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
                        HSText(lhText: "End Time", rhText: session?.getEndTimeStr() ?? "Unavailable", systemImage: "clock")
                            .listRowSeparator(.hidden, edges: .top)
                            .listRowSeparator(.visible, edges: .bottom)
                        HSText(lhText: "Hours", rhText: session?.getHoursWorkedStr() ?? "Unavailable", systemImage: "timelapse")
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
                        
                        WageInput(value: $pay, placeholder: payArrangement == .lumpSum ? "Payout" : "Wage / Hour")
                        
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
            .toolbar {
                ToolbarItem(placement: .cancellationAction){
                    Button("Cancel"){
                        dismiss()
                    }
                }
            }
    }
    
    private func save(){
    
        // Validate
        guard let ticket: TempWorkTicket = session else {
            isProcessing = false;
            errorMessage = "FATAL ERROR: Session is no longer available. Please manually enter hours under desired employer pay period."
            return
        }
        
        guard let desiredEmployer: EmployerModel = employer else {
            isProcessing = false;
            errorMessage = "Error: Please select an employer prior to saving!"
            return
        }
        
        // Attempt save through employer
        let snapshot: TicketSnapshot = TicketSnapshot(ticket: ticket, payArrangement: payArrangement, amount: pay, roundingOption: roundingOption)
        
        let result = desiredEmployer.addWorkTicket(snapshot: snapshot)
        
        if result.success {
            dismiss()
        } else {
            errorMessage = result.error
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
    
    @Previewable @State var w: TempWorkTicket? = TempWorkTicket(.now)
    
    NavigationView {
        ClockOutOverview(session: $w)
    }
}
