//
//  File.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/31/23.
//

import Foundation
import SwiftUI

private struct ColorChoice : View {
    @Environment(\.dismiss) private var dismiss

    let color: Color
    @ObservedObject var profile: ProfileEntity

    var body: some View {
        Circle().fill(color)
            .onTapGesture {
                profile.color = SerializableColor(from: color)
                dismiss()
            }
            .frame(width: 60)
    }
}

struct ProfileColorPicker: View {
    static private let choices: [Color] = [
        Color("AccentColor"), .red, .blue, .green, .cyan, .indigo
    ]
    @ObservedObject var profile: ProfileEntity

    @State private var showPicker: Bool = false
    
    var body: some View {
        ZStack {
            Circle().stroke(.white, lineWidth: 10)
            Circle()
                .fill(profile.color?.color ?? ProfileColorKey.defaultValue)
                .onTapGesture {
                    showPicker.toggle()
                }
                .popover(isPresented: $showPicker) {
                    let view = FlexBox(data: Self.choices, spacing: 10) { color in
                        ColorChoice(color: color, profile: profile)
                    }
                        .padding()
                        .frame(width: 300, height: 200)
                    
                    if #available(iOS 16.4, *) {
                        view.presentationCompactAdaptation(.popover)
                    } else {
                        view
                    }
                }
        }
        .padding()
        .onChange(of: profile.color?.color) { _ in
            print("Profile \(profile.name): ", profile.color?.color)
        }
    }
}

struct ProfileColorPicker_Previews : PreviewProvider {
    static var profile: ProfileEntity = {
        let profile = ProfileEntity(context: PersistenceController.preview.container.viewContext)
        profile.name = "Sam"
        profile.uuid = UUID()
        
        profile.color = SerializableColor(from: .mint)

        return profile
    }()

    static var previews: some View {
        ProfileColorPicker(profile: profile)
    }
}
