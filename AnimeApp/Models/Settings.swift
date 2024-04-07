//
//  Settings.swift
//  AnimeApp
//
//  Created by Preston Clayton on 2/1/24.
//

import Foundation

public struct RowViewSetting: Identifiable, RawRepresentable {
    public var id: String {
        type.rawValue
    }
    
    let type: RowViewType
    var on: Bool
    
    public var rawValue: String {
        return type.rawValue + "/" + (on ? "on" : "off")
    }
    
    init(type: RowViewType, on: Bool) {
        self.type = type
        self.on = on
    }

    public init?(rawValue: String) {
        let test = rawValue.components(separatedBy: "/")
        
        if test.count != 2 {
            return nil
        }
        
        self.type = RowViewType(rawValue: test[0])!
        switch test[1] {
        case "on":
            self.on = true
        case "off":
            self.on = false
        default:
            return nil
        }
    }

}

public enum RowViewType: Codable, RawRepresentable {

    case recent
    case category(_ category: Category)
    case saved
    
    func getTitle() -> String {
        switch self {
        case .recent:
           return "Recently Watched"
        case .category(let category):
            return category.getTitle()
        case .saved:
            return "Saved"
        }
    }

    public var rawValue: String {
        switch self {
        case .recent:
           return "recent"
        case .category(let category):
            return "category_\(category.rawValue)"
        case .saved:
            return "saved"
        }
    }

    public init?(rawValue: String) {
        switch rawValue {
        case "recent":
            self = .recent
            
        case let value where value.hasPrefix("category_"):
            let id = String(value.dropFirst(9))
            guard let category = Category(rawValue: Int(id)!) else {
                return nil
            }
            self = .category(category)
            
        case "saved":
            self = .saved
            
        default:
            return nil
        }
    }
}

extension Array: RawRepresentable where Element == RowViewSetting {
    
    public init?(rawValue: String) {
        self = rawValue.components(separatedBy: "|").compactMap({ RowViewSetting(rawValue: $0) })
    }
    
    public var rawValue: String {
        return self.map({$0.rawValue}).joined(separator: "|")
    }
    
}

let defaultHomeScreen: [RowViewSetting] = [
    RowViewSetting(type: .recent, on: true),
    RowViewSetting(type: .category(.Airing), on: true),
    RowViewSetting(type: .category(.Popular), on: true),
    RowViewSetting(type: .category(.BoysLove), on: true),
    RowViewSetting(type: .category(.Drama), on: false),
    RowViewSetting(type: .category(.Fantasy), on: false),
    RowViewSetting(type: .category(.Horror), on: false),
    RowViewSetting(type: .category(.Mecha), on: false),
    RowViewSetting(type: .category(.Mystery), on: false),
    RowViewSetting(type: .category(.Romance), on: false),
    RowViewSetting(type: .category(.Seinen), on: false),
    RowViewSetting(type: .category(.Shoujo), on: false),
    RowViewSetting(type: .category(.Shounen), on: false),
    RowViewSetting(type: .category(.SliceOfLife), on: false),
    RowViewSetting(type: .category(.Space), on: false),
    RowViewSetting(type: .category(.Sports), on: false),
    RowViewSetting(type: .category(.Supernatural), on: false),
    RowViewSetting(type: .category(.Thriller), on: false),
    RowViewSetting(type: .saved, on: true)
]
