//
//  OLSearchResult.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/21/23.
//

import Foundation

struct Throwable<T: Decodable>: Decodable {
    let result: Result<T, Error>

    init(from decoder: Decoder) throws {
        result = Result(catching: { try T(from: decoder) })
    }
}

struct Results: Decodable {
    enum CodingKeys: String, CodingKey {
        case docs = "docs"
        case numFound = "numFound"
    }

    let docs: [SearchResult]
    let numFound: Int
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.docs = try container.decode([Throwable<SearchResult>].self, forKey: .docs).compactMap{try? $0.result.get()}
        self.numFound = try container.decode(Int.self, forKey: .numFound)
    }
}

struct SearchResult: Identifiable {
    let author: String
    let title: String
    let coverID: Int?
    var pages: Int? = nil
    
    let id: Int
}

extension SearchResult: Decodable {
    enum CodingKeys: String, CodingKey {
        case title = "title"
        case author = "author_name"
        case cover = "cover_i"
        case isbn = "isbn"
        case pages = "number_of_pages_median"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        //            let container = try decoder.container(keyedBy: CodingKeys.self)
        //            self.id = try container.decode(Int.self, forKey: .id)
        //            self.podcastID = try container.decode(Int.self, forKey: .podcastID)
        //            let duration = try container.decode(Int.self, forKey: .duration)
        //            self.duration = .milliseconds(duration)
        //            self.title = try container.decode(String.self, forKey: .title)
        //            self.date = try container.decode(Date.self, forKey: .date)
        //            self.url = try container.decode(URL.self, forKey: .url)

        self.author = try container.decode([String].self, forKey: .author).first ?? "Unknown"
        self.title = try container.decode(String.self, forKey: .title)
        self.coverID = try? container.decode(Int.self, forKey: .cover)
        self.pages = try? container.decode(Int.self, forKey: .pages)

        self.id = try container.decode([String].self, forKey: .isbn).first?.hash ?? Int.random(in: 0..<Int.max)
    }
}

