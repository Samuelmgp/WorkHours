//
//  PayPeriodCreationSheet.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-09-24.
//

import SwiftUI
import SwiftData

struct PayPeriodCreationSheet: View {
    
    @Binding var isPresented: Bool
    
    @Environment(\.modelContext) var context
    @State var employer: EmployerModel? = nil
    @State var startDate: Date = .now
    @State var endDate: Date = .now
    
    @State var isProcessing: Bool = false
    
    var body: some View {
        Form {
            Section("New Pay Period"){
                EmployerPicker(selected: $employer)
                DatePicker("Pay Period Start", selection: $startDate, displayedComponents: .date)
                DatePicker("Pay Period End", selection: $endDate, displayedComponents: .date)
                Text("Note: Pay Period Start & End Date cannot be modified after being created.")
                    .font(.footnote)
                    .listRowBackground(RoundedRectangle(cornerRadius: 12).foregroundStyle(.clear))
                    .foregroundStyle(.red)
                    .listRowSeparator(.hidden)

                Button {
                    isProcessing = true
                    create()
                } label: {
                    Text("Create Pay Period")
                }
                .disabled(isProcessing)
            }
        }
    }
    
    func create(){
        // Validate
        if (startDate > endDate){
            // Error prevention
            let t = startDate
            startDate = endDate
            endDate = t
        }
        
        if (employer == nil){ isPresented = false; return}
        
        // Save
        employer?.createPayPeriod(payPeriodStart: startDate, payPeriodEnd: endDate)
        
        isPresented = false
    }
}

#Preview {
    @Previewable @State var isPresented = true
    PayPeriodCreationSheet(isPresented: $isPresented)
}
