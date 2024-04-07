import SwiftUI
import SwiftData

struct SearchView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var focused: Bool = true

    @State var sourceIndex: Int = 0

    @State var query: String = ""
    
    @State var doneLoading: Bool = false
    @State var page: Int = 1
    
    @State var results = [SeriesInfo]()
    
    let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 200))
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(results) { result in
                    SearchResult(result: result)
                        .onAppear {
                            loadNextPageIfNeeded(result)
                        }
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $query, isPresented: $focused, placement: .navigationBarDrawer(displayMode: .always))
        //implement debounce so this isn't necessary
        .onSubmit(of: .search) {
            search()
        }
        .textInputAutocapitalization(.never)
        .disableAutocorrection(true)
    }

    func search() {
        page = 1
        results = []
        doneLoading = false
        
        Task {
            results = try await gogoanime.search(query: query, page: page, context: modelContext)
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
        page += 1
        
        Task {
            let response = try await gogoanime.search(query: query, page: page, context: modelContext)
            if response == [] { doneLoading = true }
            
            results = results + response
        }
    }
}

struct SearchResult: View {
    @Environment(\.modelContext) private var modelContext
    var result: SeriesInfo
        
    var body: some View {
        NavigationLink {
            SeriesView(series: result)
        } label : {
            VStack {
                PosterView(url: result.image, rounded: false)
                Text(result.name)
                    .font(.headline)
                    .padding()
            }
        }
    .padding(.bottom, 10)
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        TabView {
            NavigationView {
                SearchView()
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle("Search")
            }.navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
            NavigationView {
                Text("Dawg")
            }
            .tabItem {
                Label("Evil Search", systemImage: "magnifyingglass")
            }

        }
    }
}
