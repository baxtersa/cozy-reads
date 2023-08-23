//
//  ProfileView.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/21/23.
//

import Foundation
import SwiftUI

struct ProfileView : View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Profile")
                .font(.system(.title2))
            
            XPProgressView()
                .frame(height: 30)
//                .xpProgressStyle(.badge)
        }
        .padding(.horizontal)
    }
}

struct ProfileView_Previews : PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
