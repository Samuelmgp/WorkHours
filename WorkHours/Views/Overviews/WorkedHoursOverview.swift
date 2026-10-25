//
//  WorkedHoursOverview.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-09-25.
//

import SwiftUI
import SwiftData

struct WorkedHoursOverview: View {
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var ticket: WorkTicket
    
    @State var isEditing: Bool = false
    @State var isProcessing: Bool = false
    
    @State var newStartTime: Date = .now
    @State var newEndTime: Date = .now
    @State var newRounding: WorkHoursRoundingOptions = .none
    
    var body: some View {
        List {
            Group {
                HSText(lhText: ticket.getWorkDate().formatted(date: .complete, time: .omitted), systemImage: "calendar")
                    .font(.system(size: 18, weight: .semibold))
                
                if let payPeriod: PayPeriod = ticket.payPeriod {
                    if let employer: EmployerModel = payPeriod.employer {
                        HSText(lhText: "Employer", rhText: employer.employerName, systemImage: "suitcase")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    HSText(lhText: payPeriod.payPeriodStartDate.formatted(date: .abbreviated, time: .standard), mText: "-", rhText: payPeriod.payPeriodEndDate.formatted(date: .abbreviated, time: .standard), systemImage: "dollarsign.gauge.chart.lefthalf.righthalf")
                        .font(.footnote)
                }
            }
            .listRowBackground(Color.clear)
            
            Group {
                HSText(lhText: "Start Time", rhText: ticket.getStartTime().formatted(date: .omitted, time: .standard), systemImage: "clock")
                    .listRowSeparator(.visible, edges: .top)
                HSText(lhText: "End Time", rhText: ticket.getEndTime().formatted(date: .omitted, time: .standard), systemImage: "clock")
                    .listRowSeparator(.visible, edges: .bottom)
                HSText(lhText: "Hours", rhText: ticket.getHoursWorked().formatted(.number.precision(.fractionLength(2))), systemImage: "timelapse")
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            
            if (isEditing) {
                Section("Modify"){
                    DatePicker("Start Time", selection: $newStartTime)
                    DatePicker("End Time", selection: $newEndTime)
                    Picker("Rounding Option", selection: $newRounding){
                        ForEach(WorkHoursRoundingOptions.allCases, id: \.self) { o in
                            Text("\(o.getTitle())")
                        }
                    }
                }
                HStack(alignment: .bottom){
                    Button {
                        isProcessing = true
                        context.delete(ticket)
                        do {
                            try context.save()
                        } catch {
                            print("Error: \(error)")
                        }
                        dismiss()
                    } label: {
                        HStack {
                            Text("Delete")
                            Image(systemName: "trash")
                        }
                        .containerRelativeFrame(.horizontal, alignment: .center)
                        .tint(.red)
                    }
                    .disabled(isProcessing)
                }
            }
        }
        .onAppear {
            newStartTime = ticket.getStartTime()
            newEndTime = ticket.getEndTime()
            newRounding = ticket.getRoundingOption()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if (isEditing){
                        isProcessing = true
                        ticket.update(workDate: newStartTime, endTime: newEndTime, roundingOption: newRounding)
                        do {
                            try context.save()
                            isProcessing = false
                            isEditing = !isEditing
                        } catch {
                            print("Error saving: \(error)")
                        }
                    } else {
                        isEditing = !isEditing
                    }
                } label: {
                    Text(isEditing ? "Save" : "Edit")
                }
                .disabled(isProcessing)
            }
        }
        .navigationTitle("Work Summary")
    }
}

#Preview {
    @Previewable var ticket = WorkTicket(workDate: .now, startTime: .now, payArrangement: .hourly(rate: 20))
    
    NavigationView {
        WorkedHoursOverview(ticket: ticket)
    }
}
