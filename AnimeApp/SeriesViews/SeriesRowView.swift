//
//  SeriesRow.swift
//  AnimeApp
//
//  Created by Preston Clayton on 1/29/24.
//

import SwiftUI

struct SeriesRow: View {
    @Environment(\.modelContext) private var modelContext

    let title: String
    var list_series: [SeriesInfo]
    let hideIfEmpty: Bool
    
    var category: Category? = nil
    @State var page: Int = 1
    @State var doneLoading: Bool = false
    
    var extraContextMenuItem: ((_ series: SeriesInfo) -> any View)? = nil
    
    var body: some View {
        if list_series.isEmpty && hideIfEmpty {
            EmptyView()
        } else {
            VStack(alignment: .leading) {
                NavigationLink {
                    SeriesGridView(list_series: list_series)
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationTitle(title)
                } label: {
                    HStack {
                        Text(title)
                            .font(.title2)
                            .foregroundStyle(.primary)
                            .padding(.leading)
                        Image(systemName: "chevron.forward")
                            .foregroundStyle(.secondary)
                    }
                    .bold()
                }
                .buttonStyle(PlainButtonStyle())
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach(list_series) { series in
                            HomePosterView(series: series)
                                .contextMenu {
                                    Button(role: series.saved ? .destructive : .none) {
                                        series.saved.toggle()
                                    } label: {
                                        if series.saved {
                                            Label("Unsave", systemImage: "minus")
                                        } else {
                                            Label("Save", systemImage: "plus")
                                        }
                                    }
                                    if extraContextMenuItem != nil {
                                        AnyView(extraContextMenuItem!(series))
                                    }
                                }
                        }
                    }
                    .padding(.trailing)
                }
                .frame(height: 220)
            }
        }
    }
}

//#Preview {
//    SeriesRow(title: "", list_series: [SeriesInfo](), hideIfEmpty: false)
//}
