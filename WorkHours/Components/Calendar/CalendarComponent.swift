//
//  CalendarComponent.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-09-18.
//

import SwiftUI


struct CalendarComponent: View {
    
    @State private var payPeriod: PayPeriod?
    
    @State private var currentMonth = Date.now
    @State private var selectedDate = Date.now
    @State private var days: [Date] = []
    
    private let daysOfTheWeek = Date.capitalizeFirstLetterOfWeekdays
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        VStack(spacing: 10){
            HStack {
                Text(currentMonth.formatted(.dateTime.year().month()))
                    .font(.title)
                
                Spacer()
                Button {
                    currentMonth = Calendar.current.date(byAdding: .init(month: -1), to: currentMonth)!
                    updateDays()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .padding(.horizontal, 15)
                }

                Button {
                    currentMonth = Calendar.current.date(byAdding: .init(month: 1), to: currentMonth)!
                    updateDays()
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                }
                
            }
            
            // Calendar Grid:
            LazyVGrid(columns: columns, spacing: 20){
                
                ForEach(daysOfTheWeek.indices, id: \.self){ index in
                    Text(daysOfTheWeek[index])
                        .font(.subheadline)
                }
                
                ForEach(days, id: \.self){ day in
                    DayComponent(
                        date: day,
                        backgroundStyle: backgroundSyle(for:),
                        boarderStyle: boarderStyle(for:),
                        textStyle: textStyle(for:),
                    )
                }
            }
        }
        .padding(.horizontal)
        .onAppear{
            updateDays()
        }
    }
    
    private func boarderStyle(for day: Date) -> Color {
        let isToday = Calendar.current.isDateInToday(day)
        if isToday {
            return .blue.opacity(0.75)
        } else {
            return .primary.opacity(0.1)
        }
    }
    
    private func backgroundSyle(for day: Date) -> Color {
        let isToday = Calendar.current.isDateInToday(day)
        if isToday {
            return .blue.opacity(0.55)
        } else if day < currentMonth.startOfMonth {
            return .gray.opacity(0.75)
        } else {
            return .gray.opacity(0.1)
        }
    }
    
    private func textStyle(for day: Date) -> Color {
        let isToday = Calendar.current.isDateInToday(day)
        if isToday {
            return .white
        } else if day < currentMonth.startOfMonth {
            return .primary.opacity(0.4)
        } else {
            return .primary
        }
    }
    
    private func updateDays() {
        days = currentMonth.calendarDisplayDays
    }
    
}

#Preview {
    CalendarComponent()
}
