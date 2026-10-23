//
//  PayPeriodList.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-10-21.
//

import SwiftUI
import SwiftData

struct PayPeriodList: View {
    
    @Bindable var employer: EmployerModel
    @Query private var payPeriods: [PayPeriod] = []
    
    init(employer: EmployerModel) {
        self.employer = employer
        let employerID = employer.persistentModelID
        
        let predicate = #Predicate<PayPeriod> { period in
            period.employer?.persistentModelID == employerID
        }
        
        self._payPeriods = Query(filter: predicate, sort: \PayPeriod.payPeriodStartDate, order: .reverse)
    }
    
    var body: some View {
        List {
            if (!payPeriods.isEmpty){
                Section("Current"){
                    NavigationLink(destination: PayPeriodOverview(payPeriod: payPeriods[0]), label: {
                        PayPeriodComponent(payPeriod: payPeriods[0])
                    })
                }
                
                if (payPeriods.count > 1){
                    Section("Previous") {
                        ForEach(payPeriods, id: \.self){ period in
                            if (period != payPeriods[0]){
                                NavigationLink(destination: PayPeriodOverview(payPeriod: period), label: {
                                    PayPeriodComponent(payPeriod: period)
                                })
                            }
                        }
                    }
                }
            } else {
                ContentUnavailableView("No Pay Periods", systemImage: "list.clipboard", description: Text("You currently do not have any pay periods associated with this employer."))
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: EmployerModel.self, PayPeriod.self,
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
    
    let samplePeriod = PayPeriod(
        employer: sampleEmployer,
        payPeriodStartDate: .now,
        payPeriodEndDate: .now
    )
    
    let samplePeriod2 = PayPeriod(
        employer: sampleEmployer,
        payPeriodStartDate: .now,
        payPeriodEndDate: .now
    )

    context.insert(sampleEmployer)
    context.insert(samplePeriod)
    context.insert(samplePeriod2)
    try! context.save()
    
    
    return NavigationView {
        PayPeriodList(employer: sampleEmployer)
            .modelContainer(container)
    }
}
