//
//  PosterView2.swift
//  AnimeApp
//
//  Created by Preston Clayton on 3/9/23.
//

import SwiftUI

struct HomePosterView: View {
    var series: SeriesInfo
    
    @State var detailsShown = false
    
    var body: some View {
        Button {
            detailsShown.toggle()
        } label: {
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
            .aspectRatio(2/3, contentMode: .fit)
            .padding([.bottom, .leading])
            .shadow(radius: 5)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .sheet(isPresented: $detailsShown) {
            NavigationView {
                SeriesView(series: series)
                    .accentColor(.indigo)
            }
        }
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
