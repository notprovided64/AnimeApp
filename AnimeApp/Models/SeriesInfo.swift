import Foundation
import SwiftSoup
import SwiftData


//TODO implement class methods for removing, adding, refreshing

enum AiringStatus: Codable {
    case upcoming
    case ongoing
    case complete
}

struct FetchedPagedMetadata {
    var page: Int = 1
    var doneLoading: Bool = false
    
    var lastRefresh: Date?
}

//todo add extra metadata from anidb
@Model
final class SeriesInfo: Identifiable, Codable, Equatable {
    
    @Attribute(.unique) let id: String
    let name: String
    let image: String
    
    var mal_url: String?
    
    var dateAdded: Date
    var dateWatched: Date?
    var dateSinceLastUpdate: Date?

    var eps = [Episode]()
    var curEpIndex: Int = 0
    
    var saved: Bool = false
    
    //fix this when swiftdata becomes not stupid
    var categoriesRawValues =  [Int]()
    var categories: [Category] {
        categoriesRawValues.map {
            .init(rawValue: $0)!
        }
    }
    
    var curEp: Episode {
        eps[curEpIndex]
    }
    
    var loading_state: LoadingState = LoadingState.new
    
    init(id: String, name: String, image: String) {
        self.id = id
        self.name = name
        self.image = image
        self.dateAdded = Date()
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case image
        case eps
        case curEpIndex
        case mal_url
        case saved
        case loading_state
        case categoriesRawValues
        case dateAdded
        case dateWatched
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        image = try values.decode(String.self, forKey: .image)
        eps = try values.decode([Episode].self, forKey: .eps)
        curEpIndex = try values.decode(Int.self, forKey: .curEpIndex)
        mal_url = try values.decodeIfPresent(String.self, forKey: .mal_url)
        saved = try values.decode(Bool.self, forKey: .saved)
        loading_state = try values.decode(LoadingState.self, forKey: .loading_state)
        categoriesRawValues = try values.decode([Int].self, forKey: .categoriesRawValues)
        dateAdded = try values.decode(Date.self, forKey: .dateAdded)
        dateWatched = try values.decode(Date.self, forKey: .dateWatched)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(image, forKey: .image)
        try container.encode(eps, forKey: .eps)
        try container.encode(curEpIndex, forKey: .curEpIndex)
        try container.encode(mal_url, forKey: .mal_url)
        try container.encode(saved, forKey: .saved)
        try container.encode(loading_state, forKey: .loading_state)
        try container.encode(categoriesRawValues, forKey: .categoriesRawValues)
        try container.encode(dateAdded, forKey: .dateAdded)
        try container.encode(dateWatched, forKey: .dateWatched)
    }
    
    func nextEpisode() {
        if curEpIndex != eps.count-1 {
            curEpIndex += 1
        }
    }
    
    func prevEpisode() {
        if curEpIndex != 0 {
            curEpIndex -= 1

        }
    }
    
    func markCurEp() {
        if !eps.isEmpty {
            eps[curEpIndex].watched = true
        }
    }
    
    func clearWatchHistory() {
        eps.modifyEach({$0.watched = false})
    }
    
    func isCached(context: ModelContext) -> Bool {
        let descriptor = FetchDescriptor<SeriesInfo>(predicate: #Predicate { $0.id == self.id })
        do {
            let is_cached = try context.fetch(descriptor).count == 1
            return is_cached
        } catch {
            return true
        }
    }
    
    func cache(context: ModelContext) {
        if self.isCached(context: context) {
           return
        }
        
        context.insert(self)
    }
    
//    func getCategories() -> [Category] {
//        return categories.map {
//            Category(rawValue: $0)!
//        }
//    }
}
