//
//  PayPeriodModifier.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-10-18.
//

import SwiftUI
import SwiftData

struct PayPeriodModifier: View {
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Bindable var payPeriod: PayPeriod
    
    @State private var wage: Double = 0.0
    
    var body: some View {
        List {
            Section("Wage"){
                WageInput(value: $wage)
                Text("Note: A Wage of $0.00 will set this as a variable pay. To obtain estimated pay each work day must be modified with associated pay rate. Modifying the pay rate will update all the pay days associated with this pay period.")
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .listRowSeparator(.hidden)
            }
            
            Button ("Save"){
                dismiss()
            }
            .buttonStyle(.glassProminent)
            .buttonSizing(.flexible)
            .padding(.horizontal)
            .listRowSeparator(.hidden)
            
            Section ("Danger Zone"){
                Button("Delete"){
                    do {
                        context.delete(payPeriod)
                        try context.save()
                        dismiss()
                    } catch {
                        print("Context was unable to save.")
                    }
                }
                .tint(.red)
                .buttonStyle(.glassProminent)
                .buttonSizing(.flexible)
                .padding(.horizontal)
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
    }
}

#Preview {
    
    @Previewable var period = PayPeriod(payPeriodStartDate: .now, payPeriodEndDate: .now)
    
    PayPeriodModifier(payPeriod: period)
}
