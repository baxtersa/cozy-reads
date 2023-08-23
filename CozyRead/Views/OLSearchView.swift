//
//  OLSearchView.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/21/23.
//

import Foundation
import SwiftUI

struct OLSearchView : View {
    @State private var searchText: String = ""
    static private let searchUrlBase = URL(string: "https://openlibrary.org/search.json")
    static let coverUrlBase = URL(string: "https://covers.openlibrary.org/b/id/")

    @State private var isSearching: Bool = false
    @Binding var results: [SearchResult]
    @Binding var selection: Int?
    
    var body: some View {
        VStack(spacing: 20) {
            SearchBar(searchText: $searchText)
                .onSubmit {
                    if let url = OLSearchView.searchUrlBase?.appending(queryItems: [
                        URLQueryItem(name: "q", value: searchText)
                    ]) {
                        isSearching.toggle()
                        let request = URLSession.shared.dataTask(with: url) { data, response, error in
                            isSearching.toggle()
                            guard let data = data else { return }
                            let decoder = JSONDecoder()
                            if let json = try? decoder.decode(Results.self, from: data) {
                                results = json.docs
                            } else {
                                print("Failed to decode")
                            }
                        }
                        request.resume()
                    }
                }
                .onChange(of: searchText) { value in
                    if value.isEmpty {
                        results.removeAll()
                    }
                }
            if isSearching {
                ProgressView()
                    .progressViewStyle(.circular)
            }
            if !results.isEmpty {
                ScrollView {
                    ForEach(results) { result in
                        HStack(spacing: 10) {
                            if let cover = result.coverID,
                               let coverUrl = OLSearchView.coverUrlBase?.appending(path: "\(cover)-M.jpg") {
                                AsyncImage(
                                    url: coverUrl,
                                    content: { image in
                                        image
                                            .resizable()
                                    },
                                    placeholder: {
                                        ProgressView().progressViewStyle(.circular)
                                    }
                                )
                                .mask {
                                    Circle()
                                }
                                .frame(width: 70, height: 70)
                            }
                            VStack(alignment: .leading) {
                                Text(result.title)
                                    .font(.system(.title3))
                                HStack {
                                    Spacer()
                                    Text("by \(result.author)")
                                        .italic()
                                        .font(.system(.footnote))
                                }
                            }
                        }
                        .onTapGesture {
                            selection = result.id
                        }
                    }
                }
            }
        }
    }
}

struct OLSearchView_Previews : PreviewProvider {
    static private var index = 0
    @State static var results: [SearchResult] = [
        SearchResult(author: "Becky Chambers", title: "The Long Way to a Small, Angry Planet", coverID: 8902659, id: 1),
        SearchResult(author: "Becky Chambers", title: "The Long Way to a Small, Angry Planet", coverID: 8902659, id: 2),
        SearchResult(author: "Becky Chambers", title: "The Long Way to a Small, Angry Planet", coverID: 8902659, id: 3),
        SearchResult(author: "Becky Chambers", title: "The Long Way to a Small, Angry Planet", coverID: 8902659, id: 4),
        SearchResult(author: "Becky Chambers", title: "The Long Way to a Small, Angry Planet", coverID: 8902659, id: 5)
    ]
    @State static var selection: Int?
    
    static var previews: some View {
        Form {
            OLSearchView(results: $results, selection: $selection)
                .frame(maxHeight: 300)
        }
    }
}
