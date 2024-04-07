//
//  SeriesGridView.swift
//  AnimeApp
//
//  Created by Preston Clayton on 1/29/24.
//

import SwiftUI

struct SeriesGridView: View {
    var list_series: [SeriesInfo]
    let columns = [GridItem(.adaptive(minimum: 140))]
    
    var loadNextPageIfNeeded: ((SeriesInfo) -> ())?

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(list_series) { series in
                    HomePosterView(series: series)
                        .onAppear {
                            loadNextPageIfNeeded?(series)
                        }
                }
            }
            .padding()
        }
    }
}

#Preview {
    SeriesGridView(list_series: [], loadNextPageIfNeeded: {_ in })
}
