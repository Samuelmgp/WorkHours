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
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: 35, height: 35)
                        .foregroundStyle(backgroundStyle(for: day))
                        .overlay {
                            Text(day.formatted(.dateTime.day()))
                                .foregroundStyle(textForegroundStyle(for: day))
                        }
                }
            }
        }
        .padding()
        .onAppear{
            updateDays()
        }
    }
    
    private func updateDays() {
        days = currentMonth.calendarDisplayDays
    }
    
    private func backgroundStyle(for day: Date) -> Color {
        let isCurrentDate = Calendar.current.isDate(day, inSameDayAs: .now)
        
        let pastDays = day < Date.now
        
        let defaultReturn = {
            if (isCurrentDate) {
                return Color.accentColor.opacity(0.4)
            }else if (pastDays) {
                return Color.secondary.opacity(0.15)
            }else {
                return Color.secondary.opacity(0.2)
            }
        }
        // Display the current pay period:
        guard let currentPayPeriodStart = UserManager.shared.user()?.currentPayPeriodStartDate else {
            return defaultReturn()
        }
        
        guard let currentPayPeriodEnd = UserManager.shared.user()?.currentPayPeriodEndDate else {
            return defaultReturn()
        }
        
        if (currentPayPeriodStart <= day && day <= currentPayPeriodEnd){
            if (isCurrentDate){
                return .accentColor.opacity(0.4)
            }
            return .green.opacity(0.35)
        }else {
            return defaultReturn()
        }
    }
    
    private func textForegroundStyle(for day: Date) -> Color {
        let isCurrentDate = Calendar.current.isDate(day, inSameDayAs: .now)
        let isPastDate = day < Date.now.startOfMonth
        if (isPastDate) {
            return .primary.opacity(0.4)
        } else if (isCurrentDate){
            return .primary
        } else {
            return .primary.opacity(0.7)
        }
    }
}

#Preview {
    CalendarComponent()
}
