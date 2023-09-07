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
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Currently Reading")
                    .font(.system(.title2))
                    .bold()
            }

            ReadingList()
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
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
