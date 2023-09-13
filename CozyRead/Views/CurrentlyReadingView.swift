//
//  CurrentlyReadingView.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/2/23.
//

import Foundation
import SwiftUI

struct CurrentlyReadingView : View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Currently Reading")
                .font(.system(.title2))
                .bold()

            ReadingList()
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal)
    }
}

struct CurrentlyReadingView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            CurrentlyReadingView()
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                .frame(height: 300)
        }
    }
}
