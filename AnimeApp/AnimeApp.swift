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
            MainView()
        }
        .modelContainer(sharedModelContainer)
        
        #if targetEnvironment(macCatalyst)
        let _ = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.forEach { windowScene in
            windowScene.sizeRestrictions?.minimumSize = CGSize(width: 800, height: 580)
            windowScene.titlebar?.titleVisibility = UITitlebarTitleVisibility.hidden
            windowScene.titlebar?.autoHidesToolbarInFullScreen = true
            // windowScene.sizeRestrictions?.maximumSize = CGSize(width: 640, height: 480)
        }
        #endif
    }
}
