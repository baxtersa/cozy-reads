//
//  StarRating.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/8/23.
//

import Foundation
import SwiftUI

struct RatingStyleConfiguration {
    @Binding var rating: Int
    let maxRating = 5
}

protocol RatingStyle {
    associatedtype Body : View
    typealias Configuration = RatingStyleConfiguration
    
    func makeBody(configuration: Self.Configuration) -> Self.Body
}

struct GradientRatingStyle : RatingStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .leading, endPoint: .topTrailing)
                .mask {
                    HStack {
                        ForEach(1..<configuration.maxRating + 1, id: \.self) { value in
                            Image(systemName: "star")
                                .resizable()
                                .scaledToFit()
                                .symbolVariant(value <= configuration.rating ? .fill : .none)
                        }
                    }
                }
            HStack {
                ForEach(1..<configuration.maxRating + 1, id: \.self) { value in
                    Image(systemName: "star")
                        .resizable()
                        .scaledToFit()
                        .symbolVariant(value <= configuration.rating ? .fill : .none)
                        .foregroundColor(.clear)
                        .contentShape(Circle())
                        .onTapGesture {
                            if value != configuration.rating {
                                configuration.rating = value
                            } else {
                                configuration.rating = 0
                            }
                        }
                }
            }
        }
    }
}

struct SolidRatingStyle : RatingStyle {
    let color: Color?
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            ForEach(1..<configuration.maxRating + 1, id: \.self) { value in
                Image(systemName: "star")
                    .symbolVariant(value <= configuration.rating ? .fill : .none)
                    .foregroundColor(color)
                    .contentShape(Circle())
                    .onTapGesture {
                        if value != configuration.rating {
                            configuration.rating = value
                        } else {
                            configuration.rating = 0
                        }
                    }
            }
        }
    }
}
    
struct AnyRatingStyle: RatingStyle {
  private var _makeBody: (Configuration) -> AnyView

  init<S: RatingStyle>(style: S) {
    _makeBody = { configuration in
      AnyView(style.makeBody(configuration: configuration))
    }
  }

  func makeBody(configuration: Configuration) -> some View {
    _makeBody(configuration)
  }
}

struct RatingStyleKey : EnvironmentKey {
    static var defaultValue = AnyRatingStyle(style: GradientRatingStyle())
}

extension EnvironmentValues {
  var ratingStyle: AnyRatingStyle {
    get { self[RatingStyleKey.self] }
    set { self[RatingStyleKey.self] = newValue }
  }
}

extension View {
  func ratingStyle<S: RatingStyle>(_ style: S) -> some View {
    environment(\.ratingStyle, AnyRatingStyle(style: style))
  }
}

struct StarRating: View {
    @Environment(\.ratingStyle) var style
    @Binding var rating: Int

    var body: some View {
        style.makeBody(configuration: RatingStyleConfiguration(rating: $rating))
    }
}

struct StarRating_Previews : PreviewProvider {
    @State static private var rating: Int = 0
    
    static var previews: some View {
        StarRating(rating: $rating)
    }
}
