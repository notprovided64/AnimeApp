import Foundation
import SwiftData
import SwiftSoup
import SwiftUI

enum gogoanimeURL: String {
    case host = "anitaku.to"
    case searchPath = "/search.html"
    case ajaxHost = "ajax.gogocdn.net"
    case ajaxPath = "/ajax/load-list-episode"
}

public enum Category: Int, Codable {
    case Airing
    case BoysLove
    case Comedy
    case Drama
    case Fantasy
    case Horror
    case Mecha
    case Mystery
    case Popular
    case Romance
    case Seinen
    case Shoujo
    case Shounen
    case SliceOfLife
    case Space
    case Sports
    case Supernatural
    case Thriller
    
    func getTitle() -> String {
        switch self {
        case .Popular:
            return "Popular"
        case .Airing:
            return "Airing"
        case .BoysLove:
            return "BL"
        case .Comedy:
            return "Comedy"
        case .Drama:
            return "Drama"
        case .Fantasy:
            return "Fantasy"
        case .Horror:
            return "Horror"
        case .Mecha:
            return "Mecha"
        case .Mystery:
            return "Mystery"
        case .Romance:
            return "Romance"
        case .Seinen:
            return "Seinen"
        case .Shoujo:
            return "Shoujo"
        case .Shounen:
            return "Shounen"
        case .SliceOfLife:
            return "Slice of Life"
        case .Space:
            return "Space"
        case .Sports:
            return "Sports"
        case .Supernatural:
            return "Supernatural"
        case .Thriller:
            return "Thriller"
        }
    }

    func getUrl() -> String {
        switch self {
        case .Popular:
            return "/popular.html"
        case .Airing:
            return "/new-season.html"
        case .BoysLove:
            return "/genre/shounen-ai"
        case .Comedy:
            return "/genre/comedy"
        case .Drama:
            return "/genre/drama"
        case .Fantasy:
            return "/genre/fantasy"
        case .Horror:
            return "/genre/horror"
        case .Mecha:
            return "/genre/mecha"
        case .Mystery:
            return "/genre/mystery"
        case .Romance:
            return "/genre/romance"
        case .Seinen:
            return "/genre/seinen"
        case .Shoujo:
            return "/genre/shoujo"
        case .Shounen:
            return "/genre/shounen"
        case .SliceOfLife:
            return "/genre/slice-of-life"
        case .Space:
            return "/genre/space"
        case .Sports:
            return "/genre/sports"
        case .Supernatural:
            return "/genre/supernatural"
        case .Thriller:
            return "/genre/thriller"
        }
    }
}


let gogoanimeServers = [
    ("embtaku", "https://embtaku.pro/streaming.php?id=")
]

enum ScrapingError : Error {
    case linkFormatError
    case animeItemFormatError
}


final class gogoanime {
    let name = "gogoanime"
    static var base_url: URLComponents {
        var urlcomps = URLComponents()
        urlcomps.scheme = "https"
        urlcomps.host = gogoanimeURL.host.rawValue
        return urlcomps
    }
    
    // link to series subpage -> list of episode ids
    static func getEpisodes(id: String) async throws -> [Episode]{
        var urlcomps = base_url
        urlcomps.path = id
        let url = urlcomps.url
        
        let doc = try await getDocument(url: url)
        
        let id = try doc.select("#movie_id").attr("value")
        return try await getEpisodeURLsFromMovieID(id: id)
    }
    
    //each gogo video element has an id associated with it that can be used with their api in order to get links to all episodes
    static func getEpisodeURLsFromMovieID(id: String) async throws -> [Episode] {
        var urlcomps = URLComponents()
        urlcomps.scheme = "https"
        urlcomps.host = gogoanimeURL.ajaxHost.rawValue
        urlcomps.path = gogoanimeURL.ajaxPath.rawValue
        urlcomps.queryItems = [
            URLQueryItem(name: "ep_start", value: "0"),
            URLQueryItem(name: "ep_end", value: "10000"),
            URLQueryItem(name: "id", value: id)
        ]
        let url = urlcomps.url
        print(url ?? "wtf")
        
        let doc = try await getDocument(url: url)
        
        let elements = try doc.select("a")
        
        return try elements.reversed().map { i in
            let link = try i.attr("href").trimmingCharacters(in: .whitespaces)
            return Episode(link)
        }
    }
    
    //takes url to specific episode from the ajax results and returns the unique episode id
    static func getIDFromURL(url: URL) async throws -> String {
        let doc = try await getDocument(url: url)
        let playerLink = try doc.select("iframe").first()!.attr("src")
        return try getEpisodeIDFromPlayerLink(string: playerLink)
    }
    
    //gets player link from video player url containing it
    static func getEpisodeIDFromPlayerLink(string: String) throws -> String {
        if let lower: Range<String.Index> = string.range(of: "id=") {
            if let upper = string.firstIndex(of: "&") {
                return String(string[lower.upperBound..<upper])
            }
        }
        throw ScrapingError.linkFormatError
    }
    
    static func search(query: String, page: Int, context: ModelContext) async throws -> [SeriesInfo]{
        var urlcomps = base_url
        urlcomps.path = gogoanimeURL.searchPath.rawValue
        urlcomps.queryItems = [
            URLQueryItem(name: "keyword", value: query),
            URLQueryItem(name: "page", value: String(page))
        ]
        let url = urlcomps.url
        
        let doc = try await getDocument(url: url)
        guard let items = try doc.select(".items").first() else {
            return []
        }
        
        return try getFromItems(items: items, context: context)
    }
    
    static func getCategory(category: Category, page: Int, context: ModelContext) async throws -> [SeriesInfo] {
        var urlcomps = base_url
        urlcomps.path = category.getUrl()
        urlcomps.queryItems = [
            URLQueryItem(name: "page", value: String(page))
        ]
        let url = urlcomps.url
        
        let doc = try await getDocument(url: url)
        guard let items = try doc.select(".items").first() else {
            return []
        }
        
        return try getFromItems(items: items, context: context)
    }
    
    static func getFromItems(items: Element, context: ModelContext, category: Category? = nil) throws -> [SeriesInfo] {
        var series = [SeriesInfo]()
        
        for anime in try items.select("li") {
            guard let a = try anime.select("a").first() else {
                throw ScrapingError.animeItemFormatError
            }
            let link = try a.attr("href")
            
            let descriptor = FetchDescriptor<SeriesInfo>(predicate: #Predicate { $0.id == link })
            let cacheMatch = try context.fetch(descriptor).first
            
            if let cacheMatch {
                series.append(cacheMatch)
            } else {
                let title = try a.attr("title")
                let img = try anime.select("img").attr("src")
                
                let new_series = SeriesInfo(id: link, name: title, image: img)
                if let category {
                    new_series.categoriesRawValues.append(category.rawValue)
                }
                
                series.append(new_series)
            }
        }
        return series
    }
    
    @MainActor
    static func loadCurEp(series: SeriesInfo) async {
        await loadEpisode(series: series, index: series.curEpIndex)
    }
    
    @MainActor
    static func loadEpisode(series: SeriesInfo, index: Int) async {
        do {
            var episode = series.eps[index]
            if (episode.loading_state == .loading) || (episode.loading_state == .done) {
                return
            }
            
            episode.loading_state = .loading
            series.eps[index] = episode
            
            let gogo_url = URL(string: "https://" + gogoanimeURL.host.rawValue + episode.url)!
            
            episode.id = try await getIDFromURL(url: gogo_url)
            episode.loading_state = .done
            
            series.eps[index] = episode
        } catch {
            var episode = series.eps[index]
            episode.loading_state = .failed
            series.eps[index] = episode
            
            print("error occured : \(error)")
        }
    }
    
    //change this to load episode links also don't show indicator anymore on episoderow
    //auto download for series with less than 24eps
    static func loadAllEps(series: SeriesInfo) async {
        await withTaskGroup(of: Void.self) { group in
            for index in (0..<series.eps.count) {
                group.addTask {
                    await self.loadEpisode(series: series, index: index)
                }
            }
        }
    }
    
    @MainActor
    static func getEpisodes(series: SeriesInfo) async {
        if series.loading_state == .loading {
            return
        }
        
        do {
            series.loading_state = .loading
            let new_eps = try await self.getEpisodes(id: series.id).filter({ !series.eps.contains($0) })
            series.eps.append(contentsOf: new_eps)
            series.loading_state = .done
            series.dateSinceLastUpdate = Date()
        }  catch {
            print("wee woo wee woo bad bad bad bad")
            series.loading_state = .failed
        }
    }
    
}

func getDocument(url: URL?) async throws -> Document {
    let (data, _) = try await URLSession.shared.data(from: url!)
    let html = String(data: data, encoding: .utf8)!
    return try SwiftSoup.parse(html)
}
