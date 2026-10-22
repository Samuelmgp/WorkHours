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
    @Query(sort: \PayPeriod.payPeriodStartDate, order: .reverse) var payPeriods: [PayPeriod] = []
    
    @State var contentUnavailable = false
    @State var showPayPeriodCreation = false
    
    var body: some View {
        List {
            if (contentUnavailable == false){
                Section ("Current Period"){
                    if ((payPeriods.first) != nil){
                        NavigationLink(destination: PayPeriodOverview(payPeriod: payPeriods.first!)){
                            PayPeriodComponent(payPeriod: payPeriods.first!)
                        }
                    }
                }
                
                if (payPeriods.count > 1){
                    Section("Previous"){
                        ForEach(payPeriods, id: \.self) { period in
                            if (period != payPeriods.first) {
                                NavigationLink(destination: PayPeriodOverview(payPeriod: period)){
                                    PayPeriodComponent(payPeriod: period)
                                }
                            }
                        }
                    }
                }
            }
        }
        .overlay {
            contentUnavailable == true ? ContentUnavailableView("Work Hours Unavailable", systemImage: "suitcase", description: Text("You currently have not logged any work hours. Please log some to view here.")) :
            nil
        }
        .sheet(isPresented: $showPayPeriodCreation){
            PayPeriodCreationSheet(isPresented: $showPayPeriodCreation)
                .presentationDetents([.medium, .height(300)])
        }
        .onAppear {
            if (payPeriods.isEmpty){
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
