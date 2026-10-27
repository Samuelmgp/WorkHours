//
//  EmployerView.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-10-21.
//

import SwiftUI
import SwiftData

struct EmployerView: View {
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var employer: EmployerModel
    
    private var employerDetails: EmployerDetails
    private var payPeriodSnapshot: PayPeriodSnapshot?
    private var nextPayPeriodSnapshot: PayPeriodSnapshot?
    
    @State private var isEditing: Bool = false
    @State private var isProcessing: Bool = false
    
    init(employer: EmployerModel) {
        self.employer = employer
        self.employerDetails = employer.getDetails()
        self.payPeriodSnapshot = employer.getCurrentPayPeriod()
        self.nextPayPeriodSnapshot = employer.getNextPayPeriod()
    }
    
    var body: some View {
        List {
            isEditing == false ? nil :
            Section("Danger Zone"){
                Button("Delete Employer"){
                    deleteEmployer()
                }
                .buttonSizing(.flexible)
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .disabled(isProcessing)
            }
            .listRowBackground(Color.clear)
            
            
            Section ("Details"){
                Group {
                    Text("Employer: \(employer.employerName)")
                    Text("Worked Here: \(employerDetails.getEmployedSinceFormatted())")
                }
                .font(.system(size: 18, weight: .semibold))
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            
            Section ("Current Pay Period"){
                HSText(lhText: "Start", rhText: "\(payPeriodSnapshot?.payPeriodStart.formatted(date: .abbreviated, time: .standard) ?? "Undetermined")", systemImage: "calendar")
                HSText(lhText: "End", rhText: "\(payPeriodSnapshot?.payPeriodEnd.formatted(date: .abbreviated, time: .standard) ?? "Undetermined")", systemImage: "calendar")
            }
            .listRowBackground(Color.clear)
            
            Section("Hours & Pay"){
                HSText(lhText: "Pay Frequency", rhText: employerDetails.payPeriodFrequency.rawValue, systemImage: "calendar")
                HSText(lhText: "Hours Rounding", rhText: "\(employerDetails.hoursRounding.getTitle())", systemImage: "clock")
                HSText(lhText: "Wage", rhText: employerDetails.getWage(), systemImage: "dollarsign")
            }
            
            Section("Pay Period Logs"){
                if (employer.getPayPeriods().isEmpty){
                    ContentUnavailableView("No Pay Periods", systemImage: "list.clipboard", description: Text("You currently do not have any pay periods associated with this employer."))
                        .scaledToFill()
                } else {
                    PayPeriodList(employer: employer)
                        .scaledToFill()
                }
            }
            .listRowBackground(Color.clear)
        }
        .navigationTitle(employer.employerName)
        .navigationSubtitle("Employer Since: \(employerDetails.employedSince.formatted(date: .abbreviated, time: .omitted))")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing){
                Button("Delete"){
                    isEditing = true
                }
                .tint(.red)
                .disabled(isProcessing)
            }
        }
    }
    
    private func deleteEmployer(){
        isProcessing = true
        context.delete(employer)
        do {
            try context.save()
        } catch {
            print("Error deleting employer. \(error)")
        }
        dismiss()
    }
}

#Preview {
    @Previewable var sample = EmployerModel(employerName: "SGX", employedSince: .now, payPeriodFrequency: .daily, hourRounding: .none, currentPayPeriodStart: .now, currentPayPeriodEnd: .now)
    
    NavigationView(content: { EmployerView(employer: sample) })
}
