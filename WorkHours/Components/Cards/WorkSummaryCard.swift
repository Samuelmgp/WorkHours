//
//  WorkSummaryComponent.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-09-20.
//

import SwiftUI

struct WorkSummaryCard: View {
    
    @Bindable var ticket: WorkTicket
    var date: String
    let hours: String
    var timeIn: String
    var timeOut: String
    
    init(ticket: WorkTicket) {
        self.ticket = ticket
        self.date = ticket.getWorkDate().formatted(date: .numeric, time: .omitted)
        self.hours = ticket.getHoursWorked().formatted(.number.precision(.fractionLength(2)))
        self.timeIn = ticket.getStartTime().formatted(date: .omitted, time: .shortened)
        self.timeOut = ticket.getEndTime().formatted(date: .omitted, time: .shortened)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Label("\(date)", systemImage: "calendar")
                Label("Start: \(timeIn)", systemImage: "hourglass")
            }
            Spacer()
            VStack(alignment: .leading, spacing: 5){
                Label("\(hours)", systemImage: "clock")
                Label("End: \(timeOut)", systemImage: "hourglass.bottomhalf.fill")
            }
        }
    }
}

let payPeriod: PayPeriod = PayPeriod(payPeriodStartDate: .now, payPeriodEndDate: .now)
#Preview {
    
    @Previewable var ticket: WorkTicket = WorkTicket(workDate: .now, startTime: .now, payArrangement: .hourly(rate: 20))
    
    WorkSummaryCard(ticket: ticket)
}
