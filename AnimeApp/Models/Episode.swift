import Foundation

//enum Episode: Codable {
//    case url(string: String)
//    case id(string: String)
//}

struct Episode: Codable, Equatable {
    static func == (lhs: Episode, rhs: Episode) -> Bool {
        return
            lhs.url == rhs.url
    }

    let url: String
    
    var id: String? = nil
    var loading_state: LoadingState = .new
    
    var watched: Bool = false
    
    init(_ url: String) {
        self.url = url
    }
}
