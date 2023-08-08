//
//  TBRView.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/3/23.
//

import Foundation
import SwiftUI

struct TBRView : View {
    @Environment(\.managedObjectContext) var viewContext

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Currently Reading")
                .font(.system(.title))
                .padding(.leading, 10)
            CurrentlyReadingView()
            TBRListView()
                .environment(\.managedObjectContext, viewContext)
        }
        .background(Color("BackgroundColor"))
    }
}

struct TBRView_Previews : PreviewProvider {
    static var previews: some View {
        TBRView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
