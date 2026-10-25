//
//  WorkedHoursCreationSheet.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-09-25.
//

import SwiftUI
import SwiftData

enum PayArrangementOptions: CaseIterable {
    case hourly
    case lumpSum
    
    func getTitle() -> String{
        switch self {
        case .hourly: return "Hourly Pay"
        case .lumpSum: return "One-time Payment"
        }
    }
}

struct WorkedHoursCreationSheet: View {
    
    @Environment(\.modelContext) var context
    @Bindable private var payPeriod: PayPeriod
    @Binding var isPresented: Bool
    @State var isProcessing: Bool = false
    
    @State var startTime: Date
    @State var endTime: Date
    @State var roundingOption: WorkHoursRoundingOptions
    @State var payArrangement: PayArrangementOptions
    @State var pay: Double
    
    @State var errorMessage = ""
    
    init(payPeriod: PayPeriod, isPresented: Binding<Bool>) {
        self.payPeriod = payPeriod
        self._isPresented = isPresented
        
        self.startTime = payPeriod.payPeriodStartDate
        self.endTime = payPeriod.payPeriodStartDate
        
        if let details: EmployerDetails = payPeriod.employer?.getDetails() {
            self.roundingOption = details.hoursRounding
            if let wage: Double = details.wage {
                self.payArrangement = .hourly
                self.pay = wage
            } else {
                self.payArrangement = .lumpSum
                self.pay = 0.0
            }
        } else {
            self.roundingOption = .none
            self.payArrangement = .lumpSum
            self.pay = 0.0
        }
    }
    
    var body: some View {
        Form {
            Section("Employer"){
                Label(payPeriod.employer?.employerName ?? "Employer", systemImage: "suitcase")
                Text("\(payPeriod.payPeriodStartDate.formatted(date: .abbreviated, time: .shortened)) - \(payPeriod.payPeriodEndDate.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
            }.listRowBackground(Color.clear)
            
            
            Section("Work Details"){
                DatePicker("Start Time", selection: $startTime)
                    .onChange(of: startTime){
                        endTime = startTime
                    }
                DatePicker("End Time", selection: $endTime)
            }
            Section("Pay"){
                Picker("Pay Arrangement:", selection: $payArrangement){
                    ForEach(PayArrangementOptions.allCases, id:\.self){ o in
                        Text(o.getTitle())
                    }
                }
                WageInput(value: $pay, placeholder: payArrangement == .lumpSum ? "Pay" : "Pay / Hour")
                if payArrangement == .hourly {
                    Picker("Round Nearest: ", selection: $roundingOption){
                        ForEach(WorkHoursRoundingOptions.allCases, id: \.self){ o in
                            Text("\(o.getTitle())")
                        }
                    }
                }
            }
            
            errorMessage.isEmpty ? nil :
            Label(errorMessage, systemImage: "exclamationmark.circle")
                .listRowBackground(Color.clear)
                .foregroundStyle(.red)
            
            Button {
                isProcessing = true
                saveWorkTicket()
            } label: {
                Text("Add Hours")
            }
            .disabled(isProcessing)
        }
    }
    
    func saveWorkTicket(){
        // Prevent Negative Work Hours:
        if (startTime > endTime){
            let t = startTime
            startTime = endTime
            endTime = t
        }
        
        // Ensure Time is within bounds:
        if !(payPeriod.payPeriodStartDate <= startTime && startTime < payPeriod.payPeriodEndDate){
            isProcessing = false
            errorMessage = """
            Note: \(startTime.formatted(date: .abbreviated, time: .shortened)) is outside of the bounds of this pay period.
            
            The start time must be greater than
            or equal to the pay period start date.
            
            The start time must also be less than 
            the pay period end date.
            """
            return
        }
        
        let workTicket: WorkTicket = { switch payArrangement {
            case .hourly:
            return WorkTicket(workDate: startTime, startTime: startTime, endTime: endTime, payArrangement: .hourly(rate: pay), roundingOption: roundingOption)
            case .lumpSum:
            return WorkTicket(workDate: startTime, startTime: startTime, endTime: endTime, payArrangement: .lumpSum(amount: pay), roundingOption: roundingOption)
            }
        }()
        
        payPeriod.addWorkTicket(ticket: workTicket)
        isPresented = false
    }
}

#Preview {
    @Previewable @State var a: Bool = true
    let period = PayPeriod(payPeriodStartDate: .now, payPeriodEndDate: .now)
    WorkedHoursCreationSheet(payPeriod: period, isPresented: $a)
}
