//
//  ContentView.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-10-22.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @Query(sort: \EmployerModel.employerName ) private var employers: [EmployerModel] = []
    
    @State private var user: UserModel? = UserManager.shared.loadUser()
    @State private var onBoardingComplete = false
    
    var body: some View {
        Group {
            if (user == nil && onBoardingComplete == false){
                OnboardingView(onboardingComplete: $onBoardingComplete)
            } else {
                MainTabView(user: $user)
                    .onAppear {
                        // Verify that pay periods are all up to date
                        // This will only work for next consecutive pay period.
                        for employer in employers {
                            if let nextPeriod = employer.getNextPayPeriod() {
                                if nextPeriod.contains(.now){
                                    employer.updatePayPeriod()
                                }
                            }
                        }
                    }
            }
        }
    }
}

#Preview {
    ContentView()
}
