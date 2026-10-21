//
//  HomeView.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-09-18.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    
    @Environment(\.modelContext) var context
    @State var liveSession: WorkingHours? = nil
    @State var shiftStarted: Bool = false
    
    var clockInColorStyle: Color {
        switch shiftStarted {
        case true : return Color.gray
        case false : return Color.blue
        }
    }
    
    var clockOutColorStyle: Color {
        switch shiftStarted {
        case true : return Color.blue
        case false : return Color.gray
        }
    }
    
    var body: some View {
        VStack(spacing: 10){
            CalendarComponent()
            liveSession != nil ?
            TimelineView(.periodic(from: .now, by: 1)){ t in
                Text("Live Session: \(Duration.seconds(t.date.timeIntervalSince(liveSession!.date)).formatted(.time(pattern: .hourMinuteSecond)))")
            }
            : nil
            HStack(spacing: 50) {
                Button {
                    clockIn()
                } label: {
                    Label("Clock In", systemImage: "clock.badge")
                        .tint(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 120, height: 45)
                                .foregroundStyle(clockInColorStyle)
                        )
                        .padding(.vertical, 25)
                    
                }
                .disabled(shiftStarted)
                
                Button {
                    clockOut()
                } label: {
                    Label("Clock Out", systemImage: "clock.badge.checkmark")
                        .tint(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 120, height: 45)
                                .foregroundStyle(clockOutColorStyle)
                        )
                    
                }
                .disabled(!shiftStarted)
            }
        }
        .navigationTitle("Dashboard")
        .onAppear{
            guard let liveSession: WorkingHours = restoreActiveSession() else {
                return
            }
            self.liveSession = liveSession
            self.shiftStarted = true
        }
    }
    
    func clockIn() {
        shiftStarted = true
        let workHours = WorkingHours(.now)
        let data = try? JSONEncoder().encode(workHours)
        UserDefaults.standard.set(data, forKey: "activeWorkSession")
        liveSession = workHours
    }
    
    func restoreActiveSession() -> WorkingHours? {
        guard let data = UserDefaults.standard.data(forKey: "activeWorkSession") else {
            return nil
        }
        
        return try? JSONDecoder().decode(WorkingHours.self, from: data)
    }
    
    func clockOut() {
        shiftStarted = false
        defer { UserDefaults.standard.removeObject(forKey: "activeWorkSession")}
        
        guard let check = restoreActiveSession() else { return }
        
        guard let hoursRounding = UserManager.shared.user()?.hourRounding else {
            return
        }
        
        let ticket = WorkTicket(workDate: check.date, startTime: check.date, payArrangement: .hourly(rate: 0), roundingOption: hoursRounding)
        
        let workDate = ticket.getWorkDate()
        
        let descriptor = FetchDescriptor<PayPeriod>(
            predicate: #Predicate {
                $0.payPeriodStartDate <= workDate && $0.payPeriodEndDate >= workDate
            }
        )
        
        do {
            guard let payPeriod = try context.fetch(descriptor).first else { print("No pay period found for \(ticket.getWorkDate())"); return }
            
            ticket.payPeriod = payPeriod
            context.insert(ticket)
            
            try context.save()
            liveSession = nil
        } catch {
            print("Failed to clock out properly: \(error)")
        }
        
    }
}

#Preview {
    HomeView()
}
