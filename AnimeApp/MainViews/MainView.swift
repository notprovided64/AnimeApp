//
//  MainView.swift
//  AnimeApp
//
//  Created by Preston Clayton on 4/10/24.
//

import SwiftUI

typealias ViewLabel = (view: AnyView, label: AnyView)

let viewData: [ViewLabel] = [
    (AnyView(HomeView()), AnyView(Label("Home", systemImage: "house.fill"))),
    (AnyView(CategoryView()), AnyView(Label("Browse", systemImage: "books.vertical.fill"))),
    (AnyView(SavedSeriesView()), AnyView(Label("Saved", systemImage: "rectangle.stack.fill"))),
    (AnyView(SearchView()), AnyView(Label("Search", systemImage: "magnifyingglass")))
]

struct MainView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        if UIDevice.isIPhone {
            TabMainView()
        } else {
            SidebarMainView()
        }

    }
}

#Preview {
    MainView()
}
