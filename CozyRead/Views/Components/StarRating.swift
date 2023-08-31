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

private struct InternalRating : View {
    let configuration: RatingStyleConfiguration
    
    @State private var longTap: Bool = false
    
    var body: some View {
        HStack {
            ForEach(1..<configuration.maxRating + 1, id: \.self) { value in
                Image(systemName: "star")
                    .resizable()
                    .scaledToFit()
                    .symbolVariant(value <= configuration.rating ? .fill : .none)
                    .contentShape(Circle())
                    .onTapGesture {
                        if value != configuration.rating {
                            configuration.rating = value
                        } else {
                            configuration.rating = 0
                        }
                    }
                    .onLongPressGesture {
                        longTap.toggle()
                    }
            }
        }
        // TODO: Get quarter/half star ratings working
//        .popover(isPresented: $longTap, arrowEdge: .top) {
//            let view = Text("Popover")
//                .foregroundColor(.blue)
//
//            if #available(iOS 16.4, *) {
//                view.presentationCompactAdaptation(.popover)
//            } else {
//                view
//            }
//        }
    }
}

struct GradientRatingStyle : RatingStyle {
    var colors: [Color] = [.blue, .purple]

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: colors), startPoint: .leading, endPoint: .topTrailing)
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
            InternalRating(configuration: configuration)
                .foregroundColor(.clear)
        }
    }
}

struct SolidRatingStyle : RatingStyle {
    let color: Color?
    
    func makeBody(configuration: Configuration) -> some View {
        InternalRating(configuration: configuration)
            .foregroundColor(color)
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
