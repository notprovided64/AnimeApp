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
    
    @State private var showSearch = false

    var body: some View {
        // handle long press context menus
        NavigationStack {
            ScrollView {
                ForEach(rows) { row in
                    if row.on {
                        switch row.type {
                        case .recent:
                            SeriesRow(title: "Recently Watched", list_series: recent, hideIfEmpty: true, extraContextMenuItem: { series in
                                    Button(role: .destructive) {
                                        series.dateWatched = nil
                                    } label: {
                                        Label("Remove from Recently Watched", systemImage: "clock.badge.xmark")
                                    }
                                }
                            )
                        case .saved:
                            SeriesRow(title: "Saved Titles", list_series: saved, hideIfEmpty: true)
                        case.category(let category):
                            CategoryRowView(title: category.getTitle(), category: category)
                        }
                    }
                }
                .padding(.bottom)

            }
            .scrollIndicators(.never)
            .navigationDestination(isPresented: $showSearch) {
               SearchView()
           }
            .navigationBarTitle("AnimeApp", displayMode: .automatic)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Menu {
                            Text("Not sure what to put here yet")
                        } label : {
                            Image(systemName: "ellipsis.circle")
                        }
                        
                        Button {
                            showSearch = true
                        } label : {
                            Image(systemName: "magnifyingglass")
                        }
                    }
                }
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(saved[index])
            }
        }
    }    
}

//#Preview {
//    HomeView()
//        .modelContainer(for: SeriesInfo.self, inMemory: true)
//}
