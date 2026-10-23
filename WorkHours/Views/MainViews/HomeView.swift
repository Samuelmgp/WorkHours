//
//  HomeView.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-09-18.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    
    @Environment(\.modelContext) private var context
    @State var liveSession: WorkingHours? = nil
    @State var shiftStarted: Bool = false
    
    @State private var isShowingClockOutOverview = false
    
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
            guard let session: WorkingHours = restoreActiveSession() else {
                return
            }
            self.liveSession = session
            self.shiftStarted = true
        }
        .fullScreenCover(isPresented: $isShowingClockOutOverview,
        onDismiss: {
            self.liveSession = nil
            self.shiftStarted = false
        },
        content: {
            ClockOutOverview(session: $liveSession, endTime: .now)
        })
    }
    
    func restoreActiveSession() -> WorkingHours? {
        guard let data = UserDefaults.standard.data(forKey: "activeWorkSession") else {
            return nil
        }
        
        return try? JSONDecoder().decode(WorkingHours.self, from: data)
    }
    
    func clockIn() {
        shiftStarted = true
        let workHours = WorkingHours(.now)
        let data = try? JSONEncoder().encode(workHours)
        UserDefaults.standard.set(data, forKey: "activeWorkSession")
        liveSession = workHours
    }
    
    func clockOut() {
        shiftStarted = false
        defer { UserDefaults.standard.removeObject(forKey: "activeWorkSession")}
        
        guard let session: WorkingHours = restoreActiveSession() else { return }
        liveSession = session
        // Restructure saving methods
        
        isShowingClockOutOverview = true
    }
}

#Preview {
    HomeView()
}
