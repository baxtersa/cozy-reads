//
//  SearchBar.swift
//  CozyRead
//
//  Created by Samuel Baxter on 9/7/23.
//

import Foundation
import SwiftUI

struct SearchBar : View {
    @Binding var searchText: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("Search", text: $searchText)
            Spacer()
            if !searchText.isEmpty {
                Image(systemName: "xmark.circle")
                    .onTapGesture {
                        searchText.removeAll()
                    }
            }
        }
        .padding(.all, 8)
        .background(RoundedRectangle(cornerRadius: 10).opacity(0.08))
    }
}

struct SearchBar_Previews : PreviewProvider {
    static var previews: some View {
        VStack {
            SearchBar(searchText: .constant("Searching"))
            
            SearchBar(searchText: .constant("Searching"))
        }
    }
}
