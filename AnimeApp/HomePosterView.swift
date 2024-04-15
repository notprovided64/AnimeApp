//
//  PosterView2.swift
//  AnimeApp
//
//  Created by Preston Clayton on 3/9/23.
//

import SwiftUI

struct HomePosterView: View {
    var series: SeriesInfo
    
    var body: some View {
        AsyncImage(url: URL(string: series.image)) { image in
            image
                .resizable()
        } placeholder: {
            ZStack {
                ProgressView()
                    .progressViewStyle(.circular)
                Color(.clear)
            }
        }
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
            if series.dateWatched != nil {
                Button(role: .destructive) {
                    series.dateWatched = nil
                } label: {
                    Label("Remove from Recently Watched", systemImage: "clock.badge.xmark")
                }
            }
        }
        .aspectRatio(2/3, contentMode: .fit)
        .padding([.bottom, .leading])
        .shadow(radius: 5)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

//struct HomePosterView: View {
//    var series: SeriesInfo
//    
//    var body: some View {
//        NavigationLink {
//            SeriesView(series: series)
//        } label: {
//            AsyncImage(url: URL(string: series.image)) { image in
//                image
//                    .resizable()
//            } placeholder: {
//                ZStack {
//                    ProgressView()
//                        .progressViewStyle(.circular)
//                    Color(.clear)
//                }
//            }
//            .aspectRatio(2/3, contentMode: .fit)
//            .padding([.bottom, .leading])
//            .shadow(radius: 5)
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//
//        }
//    }
//}

//struct PosterView2_Previews: PreviewProvider {
//    static var previews: some View {
//        PosterView2()
//    }
//}
