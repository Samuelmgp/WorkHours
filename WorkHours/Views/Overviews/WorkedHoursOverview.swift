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
            Section("\(ticket.getWorkDate().formatted(date: .complete, time: .shortened))"){
                Text("Hours Worked: \(ticket.getHoursWorked().formatted(.number.precision(.fractionLength(2))))")
                    .listRowSeparator(.hidden)
                Text("Rounding Option: \(ticket.getRoundingOption().getTitle())")
                
                Text("Start Time: \(ticket.getStartTime().formatted(date: .omitted, time: .shortened))")
                Text("End Time: \(ticket.getEndTime().formatted(date: .omitted, time: .shortened))")
            }
            .listRowBackground(Rectangle().foregroundStyle(.clear))
            .foregroundStyle(.primary.opacity(0.85))
            
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
        .navigationTitle("Work Ticket Overview")
    }
}

#Preview {
    @Previewable var ticket = WorkTicket(workDate: .now, startTime: .now, payArrangement: .hourly(rate: 20))
    
    NavigationView {
        WorkedHoursOverview(ticket: ticket)
    }
}
