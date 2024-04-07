import SwiftUI

//TODO update you with ipad compatible view

struct SeriesView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State var showPlayer: Bool = false
    @Bindable var series: SeriesInfo
    
    var body: some View {
        //enable auto episode refresh by keeping refreshdate and running task based off that (user should never have to)
        ScrollView() {
            Header(series: series, showPlayer: $showPlayer)
            EpisodeList(series: series, showPlayer: $showPlayer)
            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    //add this functionality into a seriesinfo class function
                    if !series.saved {
                        modelContext.insert(series)
                        series.dateAdded = Date()
                        
                        if series.eps.count < 30 {
                            Task {
                                await gogoanime.loadAllEps(series: series)
                            }
                        }
                    }
                    
                    series.saved.toggle()
                } label: {
                    Image(systemName: !series.saved ? "plus.circle.fill" : "checkmark.circle.fill")
                        .foregroundStyle(Color.accentColor, .tertiary)
                        .scaleEffect(1.5)
                }
                .buttonStyle(.plain)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        Task {
                            await gogoanime.loadAllEps(series: series)
                        }
                    } label: {
                        Label("Preload All Episodes", systemImage: "arrow.down")
                    }

                    Button {
                        Task {
                            await gogoanime.getEpisodes(series: series)
                        }
                    } label: {
                        Label("Manually Refresh Episodes", systemImage: "arrow.clockwise")
                    }
                    Button {
                        Task {
                            series.clearWatchHistory()
                        }
                    } label: {
                        Label("Clear Watch History", systemImage: "bookmark.slash")
                    }

                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
        .task {
            if series.loading_state == .new {
                await gogoanime.getEpisodes(series: series)
            }
            
            // add support for tracking if an anime is currently airing, only run this code if true
            //      that requires adding in basic metadata support and rewriting a good chunk of the gogo api :(
            if let dateSinceLastUpdate = series.dateSinceLastUpdate {
                if Date().timeIntervalSince(dateSinceLastUpdate) / 3600 > 6 {
                    await gogoanime.getEpisodes(series: series)
                }
            }
        }
        .fullScreenCover(isPresented: $showPlayer) {
            NavigationStack {
                PlayerView(series: series)
                    .tint(.indigo)
            }
        }
//        .transaction({ transaction in
//            transaction.disablesAnimations = true
//        })
    }
}

    
struct Header: View {
    @Bindable var series: SeriesInfo
    @Binding var showPlayer: Bool
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(series.name)
                        .font(.largeTitle)
                        .minimumScaleFactor(0.2)
                    Button {
                        showPlayer.toggle()
                        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                        windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeLeft))
                    } label: {
                        Text("Play Episode \(series.curEpIndex+1)")
                    }
                    .buttonStyle(.bordered)
                    .disabled((series.loading_state != .done) || series.eps.isEmpty)
                }
                .padding()
                PosterView(url: series.image, rounded: false)
            }
            .frame(height: 250)
        }
        .padding()
    }
}

struct Border: View {
    @Bindable var series: SeriesInfo
    @Binding var ftl: Bool
    
    var body: some View {
        HStack {
            Text("Episodes")
                .font(.title2)
                .foregroundColor(.secondary)
                .onTapGesture {
                    ftl.toggle()
                }
            Spacer()
            Toggle("Jeff", isOn: $ftl)
                .toggleStyle(SortOrderStyle())

        }
        .padding()
        .background(Material.ultraThick)
    }
}

struct EpisodeList: View {
    @Bindable var series: SeriesInfo
    @State var ftl: Bool = true
    @Binding var showPlayer: Bool

    
    var range: Array<Int> {
        let range = Array(0..<series.eps.count)
        if self.ftl {
            return range
        } else {
            return range.reversed()
        }
    }
    
    var body: some View {
        Border(series: series, ftl: $ftl)
        switch series.loading_state {
        case .new:
            VStack {
                Spacer()
            }
        case .loading:
            ProgressView()
                .progressViewStyle(.circular)
                .padding(.top)
        case .failed:
            Text("Failed to load episodes")
        case .done:
            LazyVStack {
                ForEach(range, id: \.self) { index in
                    Button {
                        showPlayer.toggle()
                        
                    } label: {
                        EpisodeRow(series: series, number: index)
                    }
                    .simultaneousGesture(TapGesture().onEnded{
                        series.curEpIndex = index
                    })
                    Divider()
                }
            }
        }
    }
}

struct EpisodeRow: View {
    @Bindable var series: SeriesInfo
    let number: Int
    
    var episode: Episode {
        return series.eps[number]
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Epsiode \(number+1)")
                    .foregroundColor(.secondary)
                    .bold()
            }
            .padding([.leading, .bottom, .top])
            .padding([.leading], 10)
//            switch episode.loading_state {
//            case .new:
//                ZStack {}
//            case .loading:
//                ProgressView()
//                    .progressViewStyle(.circular)
//            case .done:
//                Image(systemName: "checkmark.circle.fill")
//                    .font(Font.system(.caption).weight(.bold))
//                    .foregroundColor(Color(UIColor.tertiaryLabel))
//            case .failed:
//                Image(systemName: "exclamationmark.triangle.fill")
//                    .font(Font.system(.caption).weight(.bold))
//                    .foregroundColor(Color(UIColor.tertiaryLabel))
//            }
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.secondary)
                .opacity(episode.watched ? 1 : 0)
            Spacer()
            //add marker in js video to show when video is done
            Image(systemName: "chevron.forward")
              .font(Font.system(.caption).weight(.bold))
              .foregroundColor(Color(UIColor.tertiaryLabel))
              .padding([.trailing], 20)
        }
    }
}

struct SortOrderStyle: ToggleStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        return HStack {
            Image(systemName: configuration.isOn ? "arrow.down" : "arrow.up")
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(.secondary)
                .onTapGesture {
                    configuration.isOn.toggle()
                }
                .padding([.leading],3)
        }
    }
}

#Preview {
    SearchView()
}
