//
//  WorkedHoursCreationSheet.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-09-25.
//

import SwiftUI
import SwiftData

struct WorkedHoursCreationSheet: View {
    
    @Environment(\.modelContext) var context
    @Binding var isPresented: Bool
    @State var isProcessing: Bool = false
    
    @State var startTime: Date = .now
    @State var endTime: Date = .now
    @State var roundingOption: WorkHoursRoundingOptions = .none
    
    @State var errorMessage = ""
    
    var body: some View {
        Form {
            Section("Work Details"){
                DatePicker("Start Time", selection: $startTime)
                DatePicker("End Time", selection: $endTime)
            }
            Section("Hours Rounding"){
                Picker("Round Nearest: ", selection: $roundingOption){
                    ForEach(WorkHoursRoundingOptions.allCases, id: \.self){ o in
                        Text("\(o.getTitle())")
                    }
                }
            }
            
            !errorMessage.isEmpty ? Text("\(errorMessage)") : nil
            
            Button {
                isProcessing = true
                
                // Prevent Negative Work Hours:
                if (startTime > endTime){
                    let t = startTime
                    startTime = endTime
                    endTime = t
                }
                
                let ticket = WorkTicket(workDate: startTime, startTime: startTime, endTime: endTime, payArrangement: .hourly(rate: 0), roundingOption: roundingOption)
                let workDate = ticket.getWorkDate()
                
                let descriptor = FetchDescriptor<PayPeriod>(
                    predicate: #Predicate {
                        $0.payPeriodStartDate <= workDate && $0.payPeriodEndDate >= workDate
                    }
                )
                
                do {
                    guard let payPeriod = try context.fetch(descriptor).first else {
                        errorMessage = "No pay period found for \(workDate.formatted(date: .abbreviated, time: .shortened))"
                        isProcessing = false
                        return
                    }
                    
                    ticket.payPeriod = payPeriod
                    context.insert(ticket)
                    
                    try context.save()
                } catch {
                    print("Failed to clock out properly: \(error)")
                }
                
                isPresented = false
            } label: {
                Text("Add Hours")
            }
            .disabled(isProcessing)
        }
        .onAppear {
            guard let hoursRounding = UserManager.shared.user()?.hourRounding else { return }
            roundingOption = hoursRounding
        }
    }
}

#Preview {
    @Previewable @State var a: Bool = true
    WorkedHoursCreationSheet(isPresented: $a)
}
