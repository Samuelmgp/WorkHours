//
//  PayPeriodOverview.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-09-24.
//

import SwiftUI
import SwiftData

struct PayPeriodOverview: View {
    
    @Environment(\.modelContext) private var context
    
    @Bindable var payPeriod: PayPeriod
    @State var isPresentedAddHours: Bool = false
    @State var isPresentedWorkOverview: Bool = false
    
    @State var isEditing: Bool = false
    @State var isProcessing: Bool = false
    
    var body: some View {
        List {
            Section("Pay Period") {
                HStack {
                    Text("Start Date:")
                    Spacer()
                    Text("\(payPeriod.payPeriodStartDate.formatted(date: .abbreviated, time: .standard))")
                        .multilineTextAlignment(.trailing)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.primary.opacity(0.75))
                }
                HStack {
                    Text("End Date:")
                    Spacer()
                    Text("\(payPeriod.payPeriodEndDate.formatted(date: .abbreviated, time: .standard))")
                        .multilineTextAlignment(.trailing)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.primary.opacity(0.75))
                }
            }
            .listRowSeparator(.automatic)
            .listRowBackground(EmptyView())
            
            
            Section("Pay Information") {
                HStack(alignment: .center){
                    Text("Accummulated Hours:")
                    Spacer()
                    Text("\(payPeriod.calculateHours().formatted(.number.precision(.fractionLength(2))))")
                }
                HStack(alignment: .center){
                    Text("Estimated Pay:")
                    Spacer()
                    Text("\(payPeriod.calculateEstimatedPay().formatted(.currency(code: "cad")))")
                }
                HStack(alignment: .center) {
                    Text("Pay Rate:")
                    Spacer()
                    Text("\(payPeriod.payRate != 0 ? payPeriod.payRate.formatted(.currency(code: "cad")) + " / Hour" : "Variable")")
                }
            }
            .listRowBackground(Rectangle().foregroundStyle(.clear))
            
            if (!payPeriod.workTickets.isEmpty){
                Section("Logged Hours") {
                    ForEach(payPeriod.workTickets.sorted(by: {$0.getWorkDate() > $1.getWorkDate()}), id: \.self){ ticket in
                        NavigationLink(destination: WorkedHoursOverview(ticket: ticket)){
                            WorkSummaryComponent(ticket: ticket)
                        }
                    }
                    .onDelete { offsets in
                        let sorted = payPeriod.workTickets.sorted { $0.getWorkDate() > $1.getWorkDate() }
                        
                        for offset in offsets {
                            let ticket = sorted[offset]
                            context.delete(ticket)
                        }
                        
                        do {
                            try context.save()
                        } catch {
                            print("Error: \(error)")
                        }
                    }
                }
            }
            
        }
        .sheet(isPresented: $isPresentedAddHours){
            WorkedHoursCreationSheet(isPresented: $isPresentedAddHours)
                .presentationDetents([.medium, .height(360)])
        }
        .sheet(isPresented: $isEditing){
            PayPeriodModifier(payPeriod: payPeriod)
                .presentationDetents([.height(380)])
                .scrollDisabled(true)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing){
                Button {
                    isPresentedAddHours = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing){
                Button("Edit"){
                    if (isEditing){
                        isEditing = false
                    } else {
                        isEditing = true
                    }
                }
            }
        }
        .navigationTitle("Overview")
        .navigationSubtitle("\(payPeriod.payPeriodStartDate.formatted(date: .abbreviated, time: .omitted)) - \(payPeriod.payPeriodEndDate.formatted(date: .abbreviated, time: .omitted))")
    }
}

#Preview {
    @Previewable var payPeriod = PayPeriod(payPeriodStartDate: .now, payPeriodEndDate: .now, workTickets: [WorkHoursTicket(workDate: .now, startTime: .now.addingTimeInterval(-28800.0)),])
    NavigationView {
        PayPeriodOverview(payPeriod: payPeriod)
    }
}
