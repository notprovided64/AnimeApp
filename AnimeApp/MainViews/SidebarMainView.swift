//
//  SidebarMainView.swift
//  AnimeApp
//
//  Created by Preston Clayton on 4/10/24.
//

import SwiftUI

struct SidebarMainView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        NavigationSplitView {
            SidebarView()
        } detail: {
            HomeView()
        }
    }
}

struct SidebarView: View {

    var body: some View {
        List {
            ForEach(0..<viewData.count) { index in
                NavigationLink(destination: viewData[index].view) {
                    viewData[index].label
                }
            }
//            NavigationLink(destination: HomeView()) {
//                Label("Home", systemImage: "house")
//            }
//            NavigationLink(destination: SavedSeriesView()) {
//                Label("Saved", systemImage: "rectangle.stack.fill")
//            }
//            NavigationLink(destination: SearchView()) {
//                Label("Search", systemImage: "magnifyingglass")
//            }
//            Section("Settings") {
//                NavigationLink(destination: SettingsView()) {
//                    Label("Settings", systemImage: "gearshape")
//                }
//            }
        }
        .navigationTitle("AnimeApp")
        .listStyle(SidebarListStyle())
    }
}

#Preview {
    SidebarMainView()
}
