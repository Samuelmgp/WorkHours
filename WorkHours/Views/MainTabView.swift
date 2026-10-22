//
//  MainTabView.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-10-22.
//

import SwiftUI

struct MainTabView: View {
    
    private var user: UserModel?
    
    init(user: UserModel? = nil) {
        self.user = user
    }
    
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house"){
                NavigationView {
                    HomeView()
                }
            }
            
            Tab("Pay Period", systemImage: "list.clipboard"){
                NavigationView {
                    PayPeriodView()
                }
            }
            
            Tab("Employers", systemImage: "suitcase") {
                NavigationView {
                    EmployersView()
                }
            }
            
            Tab("Profile", systemImage: "person"){
                NavigationView {
                    ProfileView(user: user)
                }
            }
        }
    }
}

#Preview {
    @Previewable var user: UserModel? = UserModel(firstName: "Example", lastName: "Tester", trackTravelTime: true)
    
    MainTabView(user: user)
}
