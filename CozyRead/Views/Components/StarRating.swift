//
//  StarRating.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/8/23.
//

import Foundation
import SwiftUI

private struct Selected : View {
    @Environment(\.profileColor) private var profileColor

    @Binding var selection: Double?

    let numerator: Int
    let denominator: Int

    private var value: Double {
        Double(numerator) / Double(denominator)
    }
    
    var body: some View {
        Group {
            if selection == value {
                Text("\(numerator)/\(denominator)")
                    .padding()
                    .background {
                        Circle()
                            .fill(profileColor)
                    }
                    .foregroundColor(.white)
                    .onTapGesture {
                        selection = nil
                    }
            } else {
                Text("\(numerator)/\(denominator)")
                    .padding()
                    .background {
                        Circle()
                            .inset(by: 2.5)
                            .stroke(profileColor, lineWidth: 5)
                    }
                    .onTapGesture {
                        selection = value
                    }
            }
        }
        .font(.system(.title3))
    }
}

struct QuarterStars : View {
    let configuration: RatingStyleConfiguration
    
    @State private var selection: Double? = nil
    
    var body: some View {
        HStack {
            Selected(selection: $selection, numerator: 1, denominator: 4)
            Selected(selection: $selection, numerator: 1, denominator: 2)
            Selected(selection: $selection, numerator: 3, denominator: 4)
        }
        .padding()
    }
}

struct RatingStyleConfiguration {
    @Binding var rating: Double
    let maxRating = 5
}

protocol RatingStyle {
    associatedtype Body : View
    typealias Configuration = RatingStyleConfiguration
    
    func makeBody(configuration: Self.Configuration) -> Self.Body
}

private struct InternalRating : View {
    let configuration: RatingStyleConfiguration
    
    @State private var longTap: Bool = true
    
    var body: some View {
        HStack {
            ForEach(1..<configuration.maxRating + 1, id: \.self) { value in
                Image(systemName: "star")
                    .resizable()
                    .scaledToFit()
                    .symbolVariant(Double(value) <= configuration.rating ? .fill : .none)
                    .contentShape(Circle())
                    .onTapGesture {
                        if Double(value) != configuration.rating {
                            configuration.rating = Double(value)
                        } else {
                            configuration.rating = 0
                        }
                        let _ = print("tapped: ", configuration.rating, value)
                    }
                    .onLongPressGesture {
                        longTap.toggle()
                    }
            }
        }
        // TODO: Get quarter/half star ratings working
//        .popover(isPresented: $longTap) {
//            let view = QuarterStars(configuration: configuration)
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
                                .symbolVariant(Double(value) <= configuration.rating ? .fill : .none)
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
    @Binding var rating: Double

    var body: some View {
        style.makeBody(configuration: RatingStyleConfiguration(rating: $rating))
    }
}

struct StarRating_Previews : PreviewProvider {
    @State static private var rating: Double = 0
    
    static var previews: some View {
        StarRating(rating: $rating)
        
        QuarterStars(configuration: RatingStyleConfiguration(rating: $rating))
    }
}
