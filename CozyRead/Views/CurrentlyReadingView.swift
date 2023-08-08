//
//  CurrentlyReadingView.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/2/23.
//

import Foundation
import SwiftUI

struct CurrentlyReadingView : View {
    private let reading = ReadingModel(title: "Record of a Spaceborn Few", author: "Becky Chambers", bookCoverUrl: URL(string: "https://pictures.abebooks.com/isbn/9780062699220-us-300.jpg"))
    
    var body: some View {
        VStack {
            CurrentlyReadingTile(data: reading)
        }
    }
}

struct CurrentlyReadingView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentlyReadingView()
    }
}
