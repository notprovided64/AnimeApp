import SwiftUI

struct PosterView: View {
    let url: String
    let rounded: Bool
    
    var body: some View {
        AsyncImage(url: URL(string: url)) { image in
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
        .cornerRadius(rounded ? 10 : 0)
        .padding([.top, .horizontal], 10)
        .shadow(radius: 5)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct PosterView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            PosterView(url: "https://gogocdn.net/cover/ousama-ranking.png", rounded: false)
            PosterView(url: "https://gogocdn.net/cover/ousama-ranking.png", rounded: true)
            PosterView(url: "https://pbs.twimg.com/ext_tw_video_thumb/1358478108475740162/pu/img/eQzcGDYOfc7osh4k?format=jpg&name=large", rounded: false)
        }
    }
}
