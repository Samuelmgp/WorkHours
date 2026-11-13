//
//  DayComponent.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-10-27.
//

import SwiftUI
import SwiftData

struct DayComponent: View {

    private let date: Date
    private let numericDay: Int
    
    var backgroundStyle: Color
    var boarderStyle: Color
    var textStyle: Color
    

    @Query private var workTickets: [WorkTicket]

    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    private var visibleTickets: [WorkTicket] {
        Array(workTickets.prefix(3))
    }

    init(date: Date = .now, numericDay: Int? = nil,
         backgroundStyle: ((_ day: Date) -> Color)? = nil,
         boarderStyle: ((_ day: Date) -> Color)? = nil,
         textStyle: ((_ day: Date) -> Color)? = nil,
    ) {
        self.date = date
        self.numericDay = numericDay ?? date.dayInt
        self.backgroundStyle = backgroundStyle?(date) ?? Color.gray
        self.boarderStyle = boarderStyle?(date) ?? Color.gray
        self.textStyle = textStyle?(date) ?? Color.primary
        

        let startOfDay = date.startOfDay
        let endOfDay = date.endOfDay

        let predicate = #Predicate<WorkTicket> { ticket in
            startOfDay <= ticket.workDate &&
            ticket.workDate < endOfDay
        }

        self._workTickets = Query(filter: predicate)
    }

    var body: some View {
        VStack(alignment:.leading, spacing: 10) {
            HStack(alignment: .top){
                // Day number
                Text("\(numericDay)")
                    .font(.system(
                        size: 18,
                        weight: isToday ? .bold : .medium,
                        design: .rounded
                    ))
                    .offset(x: 5, y: 5)
                    .contentTransition(.numericText())
                    .foregroundStyle(textStyle)
            }
            // Employer indicators
            HStack(spacing: 2) {
                ForEach(visibleTickets, id: \.persistentModelID) { ticket in
                    WorkTicketIndicator(
                        color: indicatorColor(for: ticket)
                    )
                }

                if workTickets.count > 3 {
                    Text("+\(workTickets.count - 3)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(
                            isToday ? Color.white : Color.secondary
                        )
                        .fixedSize()
                }
            }
            .frame(height: 15)
            .frame(maxWidth: .infinity)

        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .background {
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .fill(backgroundStyle)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .strokeBorder(boarderStyle)
        }
        .animation(.easeInOut(duration: 0.2), value: isToday)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityDescription)
    }

    private func indicatorColor(for ticket: WorkTicket) -> Color {
        guard
            let period = ticket.payPeriod,
            let employer = period.employer
        else {
            return .white
        }

        return Color(hex: employer.employerColor) ?? .white
    }

    private var accessibilityDescription: String {
        let ticketCount = workTickets.count

        if isToday {
            return "Today, \(numericDay), \(ticketCount) work tickets"
        }

        return "Day \(numericDay), \(ticketCount) work tickets"
    }
}

#Preview {
    let container = try! ModelContainer(
        for: WorkTicket.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = container.mainContext

    
    let sampleTicket = WorkTicket(workDate: .now, startTime: .now, payArrangement: .hourly(rate: 20))
    
    let sampleTicket2 = WorkTicket(workDate: .now, startTime: .now, payArrangement: .hourly(rate: 20))
    
    let sampleTicket3 = WorkTicket(workDate: .now, startTime: .now, payArrangement: .hourly(rate: 20))
    
    context.insert(sampleTicket)
    context.insert(sampleTicket2)
    context.insert(sampleTicket3)
    
    try! context.save()
    
    
    return DayComponent()
}
