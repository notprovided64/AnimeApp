import SwiftUI
import SwiftData

// enable passthrough for loading
struct CategoryRowView: View {
    @Environment(\.modelContext) private var modelContext
    let category: Category
    
    @State var doneLoading: Bool = false
    @State var page: Int = 1
    
    @State private var selectedSeries: SeriesInfo? = nil
    
    @State var results = [SeriesInfo]()
    
    let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 200))
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            NavigationLink {
                SeriesGridView(list_series: results, loadNextPageIfNeeded: loadNextPageIfNeeded, doneLoading: $doneLoading)
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle(category.getTitle())
            } label: {
                HStack {
                    Text(category.getTitle())
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
                            .onTapGesture {
                                selectedSeries = series
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
        .sheet(item: $selectedSeries) { series in
            NavigationView {
                SeriesView(series: series)
                    .accentColor(.indigo)
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
