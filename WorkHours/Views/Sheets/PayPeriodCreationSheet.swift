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
    @State var startDate: Date = .now
    @State var endDate: Date = .now
    @State var wage: Double = 0.0
    
    @State var isProcessing: Bool = false
    
    var body: some View {
        Form {
            Section("Pay Period Details"){
                DatePicker("Pay Period Start", selection: $startDate, displayedComponents: .date)
                DatePicker("Pay Period End", selection: $endDate, displayedComponents: .date)
                Text("Note: Pay Period Start & End Date cannot be modified after being created.")
                    .font(.footnote)
                    .listRowBackground(RoundedRectangle(cornerRadius: 12).foregroundStyle(.clear))
                    .foregroundStyle(.red)
                    .listRowSeparator(.hidden)
                WageInput(value: $wage)
                Button {
                    isProcessing = true
                    create()
                } label: {
                    Text("Create Pay Period")
                }
                .disabled(isProcessing)
            }
        }
        .onAppear {
            guard let u = UserManager.shared.user() else { return }
            wage = u.wage
        }
        .padding(.vertical, 10)
    }
    
    func create(){
        if (startDate > endDate){
            // Error prevention
            let t = startDate
            startDate = endDate
            endDate = t
        }
        let newPayPeriod = PayPeriod(payPeriodStartDate: startDate, payPeriodEndDate: endDate, wage: wage)
        
        context.insert(newPayPeriod)
        do {
            try context.save()
        } catch {
            print("Error Creating Pay Period: \(error)")
        }
        isPresented = false
    }
}

#Preview {
    @Previewable @State var isPresented = true
    PayPeriodCreationSheet(isPresented: $isPresented)
}
