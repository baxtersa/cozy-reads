//
//  FlexBox.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/17/23.
//

import Foundation
import SwiftUI

extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometry in
                preference(key: SizePreferenceKey.self, value: geometry.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

struct FlexBox<Data: RandomAccessCollection, Content: View> : View where Data.Element : Hashable {
    let data: Data
    let spacing: CGFloat
    let content: (Data.Element) -> Content
    @State private var availableWidth: CGFloat = 0

    init(data: Data, spacing: CGFloat, content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.spacing = spacing
        self.content = content
    }

    init<C>(data: Binding<C>, spacing: CGFloat, content: @escaping (Binding<C.Element>) -> Content) where Data == [C.Element], C: MutableCollection, C: RandomAccessCollection {
        self.data = Array(data.wrappedValue)
        self.spacing = spacing
        self.content = {(c: C.Element) in
            let binding = Binding(
                get: { c },
                set: { value in
                    if let element = data.first(where: {$0.wrappedValue == c}) {
                        element.wrappedValue = value
                    }
                }
            )
            return content(binding)
        }
    }

    var body: some View {
        ZStack {
            Color.clear.frame(height: 1)
                .readSize { size in
                    availableWidth = size.width
                }
            FlexBoxInternal(
                data: data,
                content: content,
                availableWidth: availableWidth,
                spacing: spacing
            )
        }
    }
}

private struct FlexBoxInternal<Data: RandomAccessCollection, Content: View> : View where Data.Element : Hashable {
    let data: Data
    let content: (Data.Element) -> Content
    let availableWidth: CGFloat
    let spacing: CGFloat

    @State private var elementsSize: [Data.Element: CGSize] = [:]

    var body: some View {
        VStack(alignment: .center, spacing: spacing) {
            ForEach(computeRows(), id: \.self) { row in
                HStack(spacing: spacing) {
                    ForEach(row, id: \.self) { element in
                        content(element)
                            .fixedSize()
                            .readSize { size in
                                elementsSize[element] = size
                            }
                    }
                }
            }
        }
    }

    private func computeRows() -> [[Data.Element]] {
        var rows: [[Data.Element]] = [[]]
        var currentRow = 0
        var remainingWidth = availableWidth

        for element in data {
            let elementSize = elementsSize[element, default: CGSize(width: availableWidth, height: 1)]

            if remainingWidth - (elementSize.width + spacing) >= 0 {
                rows[currentRow].append(element)
            } else {
                currentRow = currentRow + 1
                rows.append([element])
                remainingWidth = availableWidth
            }

            remainingWidth = remainingWidth - (elementSize.width + spacing)
        }

        return rows
    }
}

struct FlexBox_Previws : PreviewProvider {
    static var previews: some View {
        FlexBox(data: "The Long Way to a Small, Angry Planet by Becky Chambers is one of my all-time favorite novels.".split(separator: " "), spacing: 10) { text in
            Text(text)
                .padding(5)
                .background(RoundedRectangle(cornerRadius: 5).fill(Color("BackgroundColor")))
        }
    }
}
