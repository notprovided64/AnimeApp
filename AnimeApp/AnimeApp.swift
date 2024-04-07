//
//  AnimeAppApp.swift
//  AnimeApp
//
//  Created by Preston Clayton on 1/30/24.
//

import SwiftUI
import SwiftData
import Foundation


@main
struct AnimeApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            SeriesInfo.self,
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
            TabView() {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                    }
            }
            .accentColor(.indigo)
        }
        .modelContainer(sharedModelContainer)
    }
}
