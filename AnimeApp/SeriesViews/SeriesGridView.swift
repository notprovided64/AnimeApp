//
//  SeriesGridView.swift
//  AnimeApp
//
//  Created by Preston Clayton on 1/29/24.
//

import SwiftUI

//TODO fix padding on you
struct SeriesGridView: View {
    var list_series: [SeriesInfo]
    let columns = [GridItem(.adaptive(minimum: 140))]
    
    var loadNextPageIfNeeded: ((SeriesInfo) -> ())?
    var doneLoading: Binding<Bool>?
    
    @State private var selectedSeries: SeriesInfo? = nil

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(list_series) { series in
                    HomePosterView(series: series)
                        .onTapGesture {
                            selectedSeries = series
                        }
                        .onAppear {
                            loadNextPageIfNeeded?(series)
                        }
                }
            }
            .padding()
            if let doneLoading {
                if !doneLoading.wrappedValue {
                  ProgressView()
                        .progressViewStyle(.circular)
                }
            }
        }
        .sheet(item: $selectedSeries) { series in
            NavigationView {
                SeriesView(series: series)
                    .accentColor(.indigo)
            }
        }
    }
}

//#Preview {
//    SeriesGridView(list_series: [], loadNextPageIfNeeded: {_ in }, doneLoading:true)
//}
