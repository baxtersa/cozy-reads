//
//  StarRating.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/8/23.
//

import Foundation
import SwiftUI

struct StarRating: View {
    @Binding var rating: Int
    private let maxRating = 5
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .leading, endPoint: .topTrailing)
                .mask {
                    HStack {
                        ForEach(1..<maxRating + 1, id: \.self) { value in
                            Image(systemName: "star")
                                .symbolVariant(value <= rating ? .fill : .none)
                        }
                    }
                }
            HStack {
                ForEach(1..<maxRating + 1, id: \.self) { value in
                    Image(systemName: "star")
                        .symbolVariant(value <= rating ? .fill : .none)
                        .foregroundColor(.clear)
                        .contentShape(Circle())
                        .onTapGesture {
                            if value != rating {
                                rating = value
                            } else {
                                rating = 0
                            }
                            print(rating)
                        }
                }
            }
        }
    }
}

struct StarRating_Previews : PreviewProvider {
    @State static private var rating: Int = 0

    static var previews: some View {
        StarRating(rating: $rating)
    }
}
