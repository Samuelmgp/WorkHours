//
//  EmployerCreationView.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-10-21.
//

import SwiftUI

struct EmployerCreationView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var employer: String = ""
    @State private var employedDate: Date = .now
    @State private var wage: Double = 0.0
    
    @State private var firstPayPeriodStart: Date = .now
    @State private var firstPayPeriodEnd: Date = .now
    @State private var payFrequency: PayFrequency = .none
    
    var onComplete: () -> Void = {}
    
    var body: some View {
        Form {
            Section("Basic Information") {
                InputField("Employer Name", "suitcase", text: $employer)
                    .inputFieldStyle(.plain)
                    .textInputAutocapitalization(.words)
                    
                DatePicker("Employment Started", selection: $employedDate, displayedComponents: .date)
            }
            
            Section("Pay Period Details"){
                DatePicker("Start of Pay Period", selection: $firstPayPeriodStart, displayedComponents: .date)
                DatePicker("End of Pay Period", selection: $firstPayPeriodEnd, displayedComponents: .date)
                Picker("Pay Frequency", systemImage: "arrow", selection: $payFrequency){
                    ForEach(PayFrequency.allCases, id: \.self){ o in
                        Text(o.rawValue)
                    }
                }
            }
            
            Section("Wage") {
                WageInput(value: $wage)
                Text("Note: If the employer does not offer a set wage, rather provides lumpsum payments leave this at $0.00")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary.opacity(0.75))
            }
        }
        .listRowBackground(EmptyView())
        .navigationTitle("New Employer")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction){
                Button("Cancel"){
                    dismiss()
                }
                .tint(.red)
            }
            
            ToolbarItem(placement: .primaryAction){
                Button("Save"){
                    
                }
                .tint(.accentColor)
            }
        }
    }
}

#Preview {
    NavigationView {
        EmployerCreationView()
    }
}
