//
//  EmployerPicker.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-10-22.
//

import SwiftUI
import SwiftData

struct EmployerPicker: View {
    
    @Query(sort: \EmployerModel.employerName) private var employers:[EmployerModel] = []
    
    @Binding var selected: EmployerModel?
    
    
    var body: some View {
        if (!employers.isEmpty){
            Menu(selected?.employerName ?? "Employer", systemImage: "suitcase"){
                ForEach(employers, id:\.self){ employer in
                    Button {
                        selected = employer
                    } label: {
                        Label(employer.employerName, systemImage: "suitcase")
                    }
                }
            }
        } else {
            Label("Please create an Employer", systemImage: "exclamationmark.circle")
                .foregroundStyle(.red)
        }
    }
}

#Preview {
    @Previewable @State var employer: EmployerModel? = nil
    
    let container = try! ModelContainer(
        for: EmployerModel.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    let context = container.mainContext
    
    let sampleEmployer = EmployerModel(
        employerName: "SGX",
        employedSince: .now,
        payPeriodFrequency: .daily,
        hourRounding: .none,
        currentPayPeriodStart: .now,
        currentPayPeriodEnd: .now
    )
    
    let sampleEmployer2 = EmployerModel(
        employerName: "MFM",
        employedSince: .now,
        payPeriodFrequency: .daily,
        hourRounding: .none,
        currentPayPeriodStart: .now,
        currentPayPeriodEnd: .now
    )
    
    context.insert(sampleEmployer)
    context.insert(sampleEmployer2)
    try! context.save()
    
    return NavigationView {
        EmployerPicker(selected: $employer)
    }
    .modelContainer(container)
}
