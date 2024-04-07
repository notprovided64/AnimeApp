import SwiftUI
import SwiftData

// enable passthrough for loading
struct CategoryRowView: View {
    @Environment(\.modelContext) private var modelContext
    let title: String
    let category: Category
    
    @State var doneLoading: Bool = false
    @State var page: Int = 1
    
    @State var results = [SeriesInfo]()
    
    let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 200))
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            NavigationLink {
                SeriesGridView(list_series: results, loadNextPageIfNeeded: loadNextPageIfNeeded)
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle(title)
                //pass loadNextPageIfNeeded to this view to enable continued loading from within grid
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
                    ForEach(results) { series in
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
                            }
                        .onAppear {
                            loadNextPageIfNeeded(series)
                        }
                    }
                }
                .padding(.trailing)
            }
            .frame(height: 220)
            .task {
                loadNextPage()
            }
        }
    }
    
    func loadNextPageIfNeeded(_ result: SeriesInfo) {
        if doneLoading { return }
        
        let thresholdIndex = results.index(results.endIndex, offsetBy: -5)
         if results.firstIndex(where: { $0.id == result.id }) == thresholdIndex {
             loadNextPage()
         }
    }

    func loadNextPage() {
        Task {
            let response = try await gogoanime.getCategory(category: category, page: page, context: modelContext)
            if response == [] { doneLoading = true }
            
            results = results + response
            
            page += 1
        }
    }
}
