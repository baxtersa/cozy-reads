//
//  DynamicStack.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/25/23.
//

import Foundation
import SwiftUI

struct DynamicStack<Content: View> : View {
    var alignment: Alignment = .topLeading
    var spacing: CGFloat? = nil
    
    @ViewBuilder let content: () -> Content

    @State private var orientation: UIDeviceOrientation = UIDevice.current.orientation

    var body: some View {
        let orientationChanged = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .makeConnectable()
            .autoconnect()

        if UIDevice.current.userInterfaceIdiom == .pad {
            Group {
                switch orientation {
                case .portrait, .portraitUpsideDown:
                    VStack(alignment: alignment.horizontal, spacing: spacing) {
                        content()
                    }
                case .landscapeLeft, .landscapeRight:
                    HStack(alignment: alignment.vertical, spacing: spacing) {
                        content()
                    }
                default:
                    VStack(alignment: alignment.horizontal, spacing: spacing) {
                        content()
                    }
                }
            }
            .onReceive(orientationChanged) { _ in
                orientation = UIDevice.current.orientation
            }
        } else {
            VStack(alignment: alignment.horizontal, spacing: spacing) {
                content()
            }
        }
    }
}

struct DynamicStack_Previews : PreviewProvider {
    static var previews: some View {
        DynamicStack(spacing: 40) {
            Text("abc")
            Text("123")
        }
    }
}
