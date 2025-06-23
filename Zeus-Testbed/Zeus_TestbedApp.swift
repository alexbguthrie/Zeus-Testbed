//
//  Zeus_TestbedApp.swift
//  Zeus-Testbed
//
//  Created by Alex Guthrie on 6/19/25.
//

import SwiftUI
import SwiftData

@main
struct Zeus_TestbedApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
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
            FilesMainView()
        }
        .modelContainer(sharedModelContainer)
    }
}
