//
//  MainTabView.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-10-22.
//

import SwiftUI

struct MainTabView: View {
    
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
                    ProfileView()
                }
            }
        }
    }
}

#Preview {
    MainTabView()
}
