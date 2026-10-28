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
                    DayComponent(date: day)
                }
            }
        }
        .padding(.horizontal)
        .onAppear{
            updateDays()
        }
    }
    
    private func isThisMonth(date: Date) -> Bool{
        return date.monthInt == currentMonth.monthInt
    }
    
    private func updateDays() {
        days = currentMonth.calendarDisplayDays
    }
    
}

#Preview {
    CalendarComponent()
}
