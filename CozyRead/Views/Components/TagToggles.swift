//
//  TagToggles.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/17/23.
//

import Foundation
import SwiftUI

struct TagToggles : View {
    struct ToggleState : Hashable {
        let tag: String
        var state: Bool = false
    }

    @Binding var tags: [ToggleState]
    @State private var expand: Bool = true
    @State private var newTag: String = ""

    var body: some View {
        VStack {
            HStack {
                Text("Tags")
                Spacer()
                Image(systemName: "chevron.right")
                    .rotationEffect(Angle(degrees: expand ? 90 : 0))
                    .animation(.easeInOut(duration: 0.2), value: expand)
                    .transformEffect(.identity)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                expand.toggle()
            }
            if expand {
                FlexBox(data: $tags, spacing: 10) { $toggle in
                    Toggle(toggle.tag, isOn: $toggle.state)
                        .toggleStyle(.button)
                        .buttonStyle(.borderedProminent)
                }
                AddTag(newTag: $newTag)
                    .onSubmit {
                        tags.append(ToggleState(tag: newTag, state: true))
                        newTag.removeAll()
                    }
            }
        }
    }
}

struct TagToggles_Previews : PreviewProvider {
    static var previews: some View {
        TagToggles(tags: Binding.constant(BookCSVData.defaultTags.map{TagToggles.ToggleState(tag: $0)}))
    }
}
