//
//  EmployerCreationView.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-10-21.
//

import SwiftUI
import SwiftData

struct EmployerCreationView: View {
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var employer: String = ""
    @State private var employedDate: Date = .now
    @State private var colorOption: Color = .clear
    @State private var wage: Double = 0.0
    @State private var hoursRounding: WorkHoursRoundingOptions = .none
    
    @State private var firstPayPeriodStart: Date = .now
    @State private var firstPayPeriodEnd: Date = .now
    @State private var payFrequency: PayFrequency = .none
    
    @State private var isProcessing: Bool = false
    
    @State private var errorMessage = ""
    
    var onComplete: () -> Void = {}
    var onCancel: () -> Void = {}
    
    var body: some View {
        Form {
            errorMessage.isEmpty ? nil :
            Text(errorMessage)
                .font(.footnote)
                .foregroundStyle(.red)
                .listRowBackground(Color.clear)
            
            Section("Basic Information") {
                InputField("Employer Name", "suitcase", text: $employer)
                    .inputFieldStyle(.plain)
                    .textInputAutocapitalization(.words)
                    
                DatePicker("Employment Started", selection: $employedDate, displayedComponents: .date)
                
                ColorPicker("Employer Color", selection: $colorOption, supportsOpacity: false)
            }
            
            Section("Pay Period Details"){
                DatePicker("Start of Pay Period", selection: $firstPayPeriodStart, displayedComponents: .date)
                DatePicker("End of Pay Period", selection: $firstPayPeriodEnd, displayedComponents: .date)
                Picker("Pay Frequency", systemImage: "plus.arrow.trianglehead.clockwise", selection: $payFrequency){
                    ForEach(PayFrequency.allCases, id: \.self){ o in
                        Text(o.rawValue)
                    }
                }
            }
            
            Section("Wage") {
                Picker("Hours Rounding", selection: $hoursRounding){
                    ForEach(WorkHoursRoundingOptions.allCases, id: \.self){ o in
                        Text(o.getTitle())
                    }
                }
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
                    onCancel()
                }
                .tint(.red)
            }
            
            ToolbarItem(placement: .primaryAction){
                Button("Save"){
                    isProcessing = true
                    createEmployer()
                }
                .disabled(isProcessing)
                .tint(.accentColor)
            }
        }
    }
    
    func createEmployer(){
        // Input validation
        if (employer.isEmpty){
            errorMessage = "Employer name cannot be empty."
            isProcessing = false
            return
        }
        
        // Otherwise:
        let wage = { wage <= 0 ? nil : wage}
        // Convert color to string:
        let color = colorOption.description
        
        let model = EmployerModel(employerName: employer, employedSince: employedDate, payPeriodFrequency: payFrequency, wage: wage(), hourRounding: hoursRounding, currentPayPeriodStart: firstPayPeriodStart, currentPayPeriodEnd: firstPayPeriodEnd, employerColor: color)
        
        context.insert(model)
        
        do {
            try context.save()
            onComplete()
        } catch {
            errorMessage = "An error occurred could not create employer at this time."
            isProcessing = false
        }
    }
}

#Preview {
    NavigationView {
        EmployerCreationView()
    }
}
