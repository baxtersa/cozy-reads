//
//  StoryReel.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/29/23.
//

import Combine
import Foundation
import SwiftUI

class StoryTimer: ObservableObject {
    
    @Published var progress: Double
    @Published var activeSegment: Int

    private var interval: TimeInterval
    private var max: Int
    private let publisher: Timer.TimerPublisher
    private var cancellable: Cancellable?
    
    
    init(items: Int, interval: TimeInterval) {
        self.max = items
        self.progress = 0
        self.activeSegment = 0
        self.interval = interval
        self.publisher = Timer.publish(every: 0.1, on: .main, in: .default)
    }
    
    func start() {
        self.cancellable = self.publisher.autoconnect().sink(receiveValue: {  _ in
            var newProgress = self.progress + (0.1 / self.interval)
            if Int(newProgress) >= self.max { newProgress = 0 }
            self.progress = newProgress
            self.activeSegment = Int(newProgress * Double(self.max)) / Int(self.max)
        })
    }
    
    func cancel() {
        self.cancellable?.cancel()
    }
    
    func advance(by num: Int) {
        let newProgress = Swift.max((Int(self.progress) + num) % self.max , 0)
        self.progress = Double(newProgress)
    }
}

struct StoryReelProgress : View {
    var progress: CGFloat

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(Color.white.opacity(0.3))
                    .cornerRadius(5)
                
                Rectangle()
                    .frame(width: geometry.size.width * progress, alignment: .leading)
                    .foregroundColor(Color.white.opacity(0.9))
                    .cornerRadius(5)
            }
        }
    }
}

struct StoryReel : View {
    @ObservedObject private var storyTimer: StoryTimer
    
    private let inputViews: [AnyView]

    init<V: View>(interval: TimeInterval = 3.0, @ViewBuilder content: @escaping () -> V) {
        let cv = content()
        self.inputViews = [AnyView(cv)]
        self.storyTimer = StoryTimer(items: inputViews.count, interval: interval)
    }

    init<V0: View, V1: View>(interval: TimeInterval = 3.0, @ViewBuilder content: @escaping () -> TupleView<(V0, V1)>) {
        let cv = content().value
        self.inputViews = [AnyView(cv.0), AnyView(cv.1)]
        self.storyTimer = StoryTimer(items: inputViews.count, interval: interval)
    }

    init<V0: View, V1: View, V2: View>(interval: TimeInterval = 3.0, @ViewBuilder content: @escaping () -> TupleView<(V0, V1, V2)>) {
        let cv = content().value
        self.inputViews = [AnyView(cv.0), AnyView(cv.1), AnyView(cv.2)]
        self.storyTimer = StoryTimer(items: inputViews.count, interval: interval)
    }

    init<V0: View, V1: View, V2: View, V3: View>(interval: TimeInterval = 3.0, @ViewBuilder content: @escaping () -> TupleView<(V0, V1, V2, V3)>) {
        let cv = content().value
        self.inputViews = [AnyView(cv.0), AnyView(cv.1), AnyView(cv.2), AnyView(cv.3)]
        self.storyTimer = StoryTimer(items: inputViews.count, interval: interval)
    }

    init<V0: View, V1: View, V2: View, V3: View, V4: View>(interval: TimeInterval = 3.0, @ViewBuilder content: @escaping () -> TupleView<(V0, V1, V2, V3, V4)>) {
        let cv = content().value
        self.inputViews = [AnyView(cv.0), AnyView(cv.1), AnyView(cv.2), AnyView(cv.3), AnyView(cv.4)]
        self.storyTimer = StoryTimer(items: inputViews.count, interval: interval)
    }

    init<V0: View, V1: View, V2: View, V3: View, V4: View, V5: View>(interval: TimeInterval = 3.0, @ViewBuilder content: @escaping () -> TupleView<(V0, V1, V2, V3, V4, V5)>) {
        let cv = content().value
        self.inputViews = [AnyView(cv.0), AnyView(cv.1), AnyView(cv.2), AnyView(cv.3), AnyView(cv.4), AnyView(cv.5)]
        self.storyTimer = StoryTimer(items: inputViews.count, interval: interval)
    }

    init<V0: View, V1: View, V2: View, V3: View, V4: View, V5: View, V6: View>(interval: TimeInterval = 3.0, @ViewBuilder content: @escaping () -> TupleView<(V0, V1, V2, V3, V4, V5, V6)>) {
        let cv = content().value
        self.inputViews = [AnyView(cv.0), AnyView(cv.1), AnyView(cv.2), AnyView(cv.3), AnyView(cv.4), AnyView(cv.5), AnyView(cv.6)]
        self.storyTimer = StoryTimer(items: inputViews.count, interval: interval)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            inputViews[storyTimer.activeSegment]
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            HStack {
                ForEach(inputViews.indices) { index in
                    let progress = min(max((CGFloat(self.storyTimer.progress) - CGFloat(index)), 0.0) , 1.0)
                    StoryReelProgress(progress: progress)
                        .frame(height: 4, alignment: .leading)
                        .animation(.linear, value: progress)
                }
            }
            .padding(.horizontal)

            HStack(alignment: .center, spacing: 0) {
                Rectangle()
                    .foregroundColor(.clear)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        storyTimer.advance(by: -1)
                }
                Rectangle()
                    .foregroundColor(.clear)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        storyTimer.advance(by: 1)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear { storyTimer.start() }
        .onDisappear { storyTimer.cancel() }

    }
}

struct StoryReel_Previews : PreviewProvider {
    static var previews: some View {
        StoryReel(interval: 1) {
            Text("Screen 1")
//            Text("Screen 2")
//            Text("Screen 3")
            Image(systemName: "book")
                .resizable()
                .frame(maxHeight: .infinity)
                .scaledToFit()
        }
        .background(.blue)
    }
}
