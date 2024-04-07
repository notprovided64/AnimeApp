//
//  myanimelist.swift
//  AnimeApp
//
//  Created by Preston Clayton on 2/2/24.
//

import Foundation
import SwiftSoup

let mal_base_url = "https://myanimelist.net"

func getMalLink(series: SeriesInfo) async {
    do {
        let encodedName = series.name.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
        let url = URL(string: "/search/all?cat=all&q=\(encodedName ?? "")", relativeTo: URL(string: mal_base_url))
        let doc: Document = try await getDocument(url: url)

        let results = try doc.select("article").first()!
        series.mal_url = try results.select("a").first()!.attr("href")
        print("\(series.name) mal link: \(series.mal_url ?? "!_error_!")")
    } catch {
        print("failed to get mal link: \(error)")
    }
}
