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

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
