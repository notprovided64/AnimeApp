//
//  SavedSeriesViews.swift
//  AnimeApp
//
//  Created by Preston Clayton on 4/10/24.
//

import SwiftUI
import SwiftData

struct SavedSeriesView: View {
    @Query(filter: #Predicate<SeriesInfo> { $0.saved },
           sort: [SortDescriptor(\SeriesInfo.dateAdded, order: .reverse)] )
    var saved: [SeriesInfo]

    var body: some View {
        NavigationStack {
            SeriesGridView(list_series: saved)
                .navigationTitle("Saved Titles")
        }
    }
}

#Preview {
    SavedSeriesView()
}
