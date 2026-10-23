//
//  ContentView.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-10-22.
//

import SwiftUI

struct ContentView: View {
    
    @State private var user: UserModel? = UserManager.shared.loadUser()
    @State private var onBoardingComplete = false
    
    var body: some View {
        Group {
            if (user == nil && onBoardingComplete == false){
                OnboardingView(onboardingComplete: $onBoardingComplete)
            } else {
                MainTabView(user: $user)
            }
        }
    }
}

#Preview {
    ContentView()
}
