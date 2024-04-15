//
//  TabMainView.swift
//  AnimeApp
//
//  Created by Preston Clayton on 4/10/24.
//

import SwiftUI

struct TabMainView: View {
    var body: some View {
        TabView() {
            ForEach(0..<viewData.count) { index in
                viewData[index].view
                    .tabItem {
                        viewData[index].label
                    }
            }
//            HomeView()
//                .tabItem {
//                    Label("Home", systemImage: "house")
//                }
//            SavedSeriesView()
//                .tabItem {
//                    Label("Saved", systemImage: "rectangle.stack.fill")
//                }
//            SearchView()
//                .tabItem {
//                    Label("Search", systemImage: "magnifyingglass")
//                }
        }
        .accentColor(.indigo)
    }
    
}
#Preview {
    TabMainView()
}
