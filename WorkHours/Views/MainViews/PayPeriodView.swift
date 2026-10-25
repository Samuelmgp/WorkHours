//
//  WorkView.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-09-18.
//

import SwiftUI
import SwiftData

struct PayPeriodView: View {
    @Environment(\.modelContext) var context
    @Query var currentPayPeriods: [PayPeriod] = []
    @Query var pastPayPeriods: [PayPeriod] = []
    
    @State var contentUnavailable = false
    @State var showPayPeriodCreation = false
    
    init(){
        let now = Date.now
        
        let currentPeriodsPredicate = #Predicate<PayPeriod>{ period in
            period.payPeriodEndDate > now
        }
        
        let pastPeriodsPredicate = #Predicate<PayPeriod>{ period in
            period.payPeriodEndDate <= now
        }
        
        self._currentPayPeriods = Query(filter: currentPeriodsPredicate, sort: \PayPeriod.payPeriodStartDate, order: .reverse)
        self._pastPayPeriods = Query(filter: pastPeriodsPredicate, sort: \PayPeriod.payPeriodStartDate, order: .reverse)
    }
    
    var body: some View {
        List {
            if (contentUnavailable == false){
                if (!currentPayPeriods.isEmpty){
                    Section ("Current Period"){
                        ForEach(currentPayPeriods, id: \.self) { period in
                            NavigationLink(destination: PayPeriodOverview(payPeriod: period)){
                                PayPeriodComponent(payPeriod: period)
                            }
                        }
                    }
                } else {
                    ContentUnavailableView("No Current Pay Periods", systemImage: "dollarsign.gauge.chart.lefthalf.righthalf", description: Text("Add a current pay period for any Employer for it to be displayed here."))
                }
                
                if (!pastPayPeriods.isEmpty){
                    Section("Previous"){
                        ForEach(pastPayPeriods, id: \.self) { period in
                            NavigationLink(destination: PayPeriodOverview(payPeriod: period)){
                                PayPeriodComponent(payPeriod: period)
                            }
                        }
                    }
                } else {
                    ContentUnavailableView("No Past Pay Periods", systemImage: "dollarsign.gauge.chart.lefthalf.righthalf", description: Text("Add a past pay period for any Employer for it to be displayed here."))
                }
            }
        }
        .overlay {
            contentUnavailable == true ? ContentUnavailableView("Work Hours Unavailable", systemImage: "suitcase", description: Text("You currently have not logged any work hours. Please log some to view here.")) :
            nil
        }
        .sheet(isPresented: $showPayPeriodCreation){
            PayPeriodCreationSheet(isPresented: $showPayPeriodCreation)
                .presentationDetents([.medium, .height(350)])
        }
        .onAppear {
            if (currentPayPeriods.isEmpty && pastPayPeriods.isEmpty){
                contentUnavailable = true
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing){
                Button {
                    showPayPeriodCreation = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .navigationTitle("Pay Periods")
    }
}

#Preview {
    NavigationView {
        PayPeriodView()
    }
}
