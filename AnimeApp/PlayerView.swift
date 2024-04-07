import SwiftUI
import AVKit

struct PlayerView: View {
    @Environment(\.dismiss) var dismiss

    @Bindable var series : SeriesInfo
    @State private var episodeQuery: String = ""
    
    @State private var showingInfo = false
    @StateObject var model = PlayerViewModel()
    
    //show title bar even when episode is loading
    var body: some View {
        ZStack {
            Color(.black)
                .ignoresSafeArea()
            switch series.curEp.loading_state {
                case .new:
                    VStack{}
                case .loading:
                    VStack{
                        ProgressView()
                            .progressViewStyle(.circular)
                            .scaleEffect(3, anchor: .center)
                            .foregroundStyle(.white)
                    }
                case .done:
                    // try the  .opacity(model.showWebview ? 1 : 0) strat again, think it might work
                    PlayerWebView(url: getPlayerURL(), model: model, nextAction: {
                        series.nextEpisode()
                        Task {
                            await gogoanime.loadCurEp(series: series)
                        }
                    })
                    .onDisappear {
                        model.webView?.load(URLRequest(url: URL(string: "about:blank")!))
                    }
                    .ignoresSafeArea()
                    .aspectRatio(16/9, contentMode: .fit)
                    .sheet(isPresented: $showingInfo) {
                        VStack {
                            WebView(url: URL(string: series.mal_url!)!)
                        }
                        .padding(.top, 40)
                    }
                    .onAppear {
                        series.markCurEp()
                        series.dateWatched = Date()

                        Task {
                            if series.mal_url == nil {
                                await getMalLink(series: series)
                            }
                        }
                    }
                case .failed:
                    VStack {
                        Text("Error loading episode data")
                            .foregroundColor(.gray)
                            .font(.headline)
                        Text("Tap to retry")
                            .font(.subheadline)
                    }.onTapGesture {
                        Task {
                            await gogoanime.loadCurEp(series: series)
                        }
                    }
                }

        }
        .task {
            if series.curEp.loading_state == .new {
                print("loading?")
                await gogoanime.loadCurEp(series: series)
                print(series.curEp.id!)
            } else {
                print(series.curEp.id ?? "gah")
            }
        }
        .navigationBarTitle("Episode \(series.curEpIndex+1)/\(series.eps.count)", displayMode: .inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbarBackground(.visible, for: .bottomBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button() {
                    model.webView?.reload()
                } label: { Label("Reload", systemImage: "arrow.clockwise") }
                    .disabled(model.loadingWebView || series.curEp.loading_state != .done)
            }
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                    let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                    windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
                } label: {
                    HStack {
                        Image(systemName: "x.circle")
                    }
                }
            }

            ToolbarItem(placement: .bottomBar) {
                HStack {
                    Button("Prev") {
                        series.prevEpisode()
                        Task {
                            await gogoanime.loadCurEp(series: series)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                    Spacer()
                    Button("Get Info") {
                        showingInfo = true
                    }
                    .buttonStyle(.bordered)
                    .disabled(series.mal_url==nil)
                    Button("Next"){
                        series.nextEpisode()
                        Task {
                            await gogoanime.loadCurEp(series: series)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
            }
        }
    }
    
    func getPlayerURL() -> URL {
        //what the actual fuck is this line of code
        let server = gogoanimeServers[0]
        let playerUrl = server.1 + series.curEp.id!
        return URL(string: playerUrl)!
    }
}

struct EpisodePicker: View {
    @Binding var curEpisode : Int
    let maxEps: Int
    
    var body: some View {
        VStack{
            Picker("Episode", selection: $curEpisode) {
                ForEach(1...maxEps+1, id: \.self) { i in
                    Text(String(i)).tag(i-1)
                }
            }
        .pickerStyle(.wheel)
        .frame(width: 50, height: 70)
        .clipped()
        }
    }
}

//struct ServerPicker: View {
//    @Binding var selection: Int
//    let servers: [ServerInfo]
//    
//    var body: some View {
//        VStack{
//            Picker("Server", selection: $selection) {
//                ForEach(0..<servers.count, content: { index in
//                    Text(servers[index].name)
//                })
//            }.pickerStyle(.menu)
//        }
//    }
//}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
//            PlayerView(series: <#SeriesInfo#>)
        }
        .previewInterfaceOrientation(.portrait)
    }
}

