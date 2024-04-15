import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(filter: #Predicate<SeriesInfo> { $0.dateWatched != nil },
           sort: [SortDescriptor(\SeriesInfo.dateWatched, order: .reverse)])
    var recent: [SeriesInfo]
    
    @Query(filter: #Predicate<SeriesInfo> { $0.saved },
           sort: [SortDescriptor(\SeriesInfo.dateAdded, order: .reverse)] )
    var saved: [SeriesInfo]
    
    @AppStorage("homeLayout2") private var rows: [RowViewSetting] = defaultHomeScreen

    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(rows) { row in
                    if row.on {
                        switch row.type {
                        case .recent:
                            SeriesRow(title: "Recently Watched", list_series: recent, hideIfEmpty: true)
                        case .saved:
                            SeriesRow(title: "Saved Titles", list_series: saved, hideIfEmpty: true)
                        case.category(let category):
                            CategoryRowView(category: category)
                        }
                    }
                }
                .padding(.bottom)
            }
            .scrollIndicators(.never)
            .navigationBarTitle("Home", displayMode: .automatic)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Menu {
                            Text("Not sure what to put here yet")
                        } label : {
                            Image(systemName: "ellipsis.circle")
                        }
                        .keyboardShortcut("f")
                    }
                }
            }

        }
    }
}

//#Preview {
//    HomeView()
//        .modelContainer(for: SeriesInfo.self, inMemory: true)
//}
