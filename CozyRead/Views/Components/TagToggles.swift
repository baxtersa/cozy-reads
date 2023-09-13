//
//  TagToggles.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/17/23.
//

import Foundation
import SwiftUI

struct AddTag : View {
    @State private var typing: Bool = false
    @FocusState private var focusTagEntry: Bool
    @Binding var newTag: String
    
    var body: some View {
        if typing {
            TextField("Enter Tag", text: $newTag)
                .onSubmit {
                    typing.toggle()
                    newTag.removeAll()
                    focusTagEntry = false
                }
                .focused($focusTagEntry)
                .padding(5)
                .background(RoundedRectangle(cornerRadius: 5).fill(Color(white: 1, opacity: 0.2)))
        } else {
            Button {
                typing.toggle()
                focusTagEntry = true
            } label: {
                Text("Add Tag")
            }
            .buttonStyle(.bordered)
        }
    }
}

struct TagToggles : View {
    struct ToggleState : Hashable {
        let tag: String
        var state: Bool = false
    }

    @Binding var tags: [ToggleState]
    @State private var expand: Bool = false
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
                HStack {
                    AddTag(newTag: $newTag)
                        .onSubmit {
                            tags.append(ToggleState(tag: newTag, state: true))
                            newTag.removeAll()
                        }
                    let selectAll = tags.contains{ !$0.state }
                    Button {
                        if selectAll {
                            $tags.forEach{ $0.wrappedValue.state = true }
                        } else {
                            $tags.forEach{ $0.wrappedValue.state = false }
                        }
                    } label: {
                        let label = selectAll ?
                        "Select All" : "Unselect All"
                        Text(label)
                    }
                }
                .buttonStyle(.bordered)
            }
        }
    }
}

struct TagToggles_Previews : PreviewProvider {
    static var previews: some View {
        TagToggles(tags: Binding.constant(BookCSVData.defaultTags.map{TagToggles.ToggleState(tag: $0)}))
    }
}
