//
//  WorkHoursApp.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-09-18.
//

import SwiftUI
import SwiftData

@main
struct WorkHoursApp: App {
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            EmployerModel.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @State private var user: UserModel? = UserManager.shared.loadUser()
    @State var isShowingUserCreation = false

    var body: some Scene {
        WindowGroup {
            TabView {
                Tab("Home", systemImage: "house"){
                    NavigationView {
                        HomeView()
                    }
                }
                
                Tab("Pay Periods", systemImage: "list.clipboard") {
                    NavigationView {
                        WorkView()
                    }
                }
                
                Tab("Profile", systemImage: "person"){
                    NavigationView {
                        ProfileView(user: $user)
                    }
                }
            }
            .onChange(of: user != nil){
                if (user == nil){
                    isShowingUserCreation = true
                }
            }
            .onAppear {
                if (user == nil) {
                    isShowingUserCreation = true
                }
            }
            .fullScreenCover(isPresented: $isShowingUserCreation, onDismiss: {
                self.user = UserManager.shared.loadUser()
            }){
                UserCreationView(isShowingUserCreation: $isShowingUserCreation)
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
