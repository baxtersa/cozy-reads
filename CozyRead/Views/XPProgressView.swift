//
//  XPProgressView.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/22/23.
//

import Foundation
import SpriteKit
import SwiftUI

struct Shake: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}

struct Bounce: GeometryEffect {
    var amount: CGFloat = 1.2
    var bouncesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        let factor = amount - amount * sin(animatableData * .pi * CGFloat(bouncesPerUnit))
        ProjectionTransform(CGAffineTransform(scaleX: factor, y: factor))
        return ProjectionTransform(CGAffineTransform(scaleX: factor, y: factor))
    }
}

class LevelMagicScene : SKScene {
    static let shared = LevelMagicScene()

    private let emitter = SKEmitterNode(fileNamed: "Level.sks")

    override func didMove(to view: SKView) {
        guard let emitter = emitter else { return }

        self.addChild(emitter)
        emitter.particleSize = CGSize(width: 1000, height: 1000)

        emitter.numParticlesToEmit = 20
    }

    override func didChangeSize(_ oldSize: CGSize) {
        guard let emitter = emitter else { return }
        emitter.particlePosition = CGPoint(x: size.width / 2, y: size.height / 2)
        emitter.particlePositionRange = CGVector(dx: size.width / 2, dy: size.height / 2)
    }

    func reset() {
        guard let emitter = emitter else { return }
        emitter.resetSimulation()
    }
}

extension UIScreen {
    static let screenSize = UIScreen.main.bounds.size
}

struct XPProgressStyleConfiguration {
    var readingDays: FetchedResults<ReadingTrackerEntity>
    var books: FetchedResults<BookCSVData>
    
    var levelMagicScene: SKScene {
        let scene = LevelMagicScene.shared
        scene.backgroundColor = .clear
        scene.size = UIScreen.screenSize
        scene.scaleMode = .fill
        return scene
    }
}

protocol XPProgressStyle {
    associatedtype Body : View
    typealias Configuration = XPProgressStyleConfiguration
    
    func makeBody(configuration: Self.Configuration) -> Self.Body
}

struct BarXPProgressStyle : XPProgressStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            let xp = configuration.xp
            let level = configuration.level
            let thisLevel = Configuration.xp(for: level)
            let nextLevel = Configuration.xp(for: level + 1)
            let _ = print("XP \(xp)/\(nextLevel)")
            HStack(alignment: .lastTextBaseline) {
                Text("XP \(xp)/\(nextLevel)")
                    .font(.system(.caption))
                    .italic()
                Spacer()
                Text("Level")
                    .italic()
                ZStack {
                    let scene = configuration.levelMagicScene.copy()
//                    SpriteView(scene: scene as! SKScene, options: [.allowsTransparency])
//                        .ignoresSafeArea(.all)
//                        .frame(width: 20, height: 40)
//                        .offset(x: 5, y: -30)
//                        .onChange(of: level) { _ in
//                            LevelMagicScene.shared.reset()
//                        }
                    
                    Text("\(level)")
                        .bold()
                        .foregroundColor(.accentColor)
                        .animation(.default, value: level)
                }
            }
            .font(.system(.title2))
            
            let _ = print(xp, thisLevel, nextLevel)
            ProgressView(value: Double(xp - thisLevel), total: Double(nextLevel - thisLevel))
                .progressViewStyle(.linear)
                .modifier(Shake(animatableData: CGFloat(xp)))
                .animation(.default.repeatCount(3).speed(6), value: xp)

        }
        .padding(.vertical)
    }
}

struct BadgeXPProgressStyle : XPProgressStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            let level = configuration.level
//            SpriteView(scene: configuration.levelMagicScene, options: [.allowsTransparency])
//                .ignoresSafeArea(.all)
//                .frame(width: 20, height: 40)
//                .offset(y: -30)
//                .onChange(of: level) { _ in
//                    LevelMagicScene.shared.reset()
//                }
            
            Circle()
                .foregroundColor(.accentColor)
            
            VStack {
                Text("LVL")
                    .foregroundColor(.white)
                    .font(.system(.footnote))
                    .bold()
                Text("\(configuration.level)")
                    .foregroundColor(.white)
                    .font(.system(.title2))
                    .bold()
                    .lineLimit(1)
            }
        }
        .frame(width: 45)
    }
}

struct AnyXPProgressStyle: XPProgressStyle {
  private var _makeBody: (Configuration) -> AnyView

  init<S: XPProgressStyle>(style: S) {
    _makeBody = { configuration in
      AnyView(style.makeBody(configuration: configuration))
    }
  }

  func makeBody(configuration: Configuration) -> some View {
    _makeBody(configuration)
  }
}

struct XPProgressStyleKey : EnvironmentKey {
    static var defaultValue = AnyXPProgressStyle(style: BarXPProgressStyle())
}

extension EnvironmentValues {
  var xpProgressStyle: AnyXPProgressStyle {
    get { self[XPProgressStyleKey.self] }
    set { self[XPProgressStyleKey.self] = newValue }
  }
}

extension View {
  func xpProgressStyle<S: XPProgressStyle>(_ style: S) -> some View {
    environment(\.xpProgressStyle, AnyXPProgressStyle(style: style))
  }
}

struct XPProgressView : View {
    @Environment(\.xpProgressStyle) var style
    @FetchRequest(sortDescriptors: [SortDescriptor(\.date)])
    private var readingDays: FetchedResults<ReadingTrackerEntity>
    @FetchRequest(fetchRequest: BookCSVData.getFetchRequest)
    private var books: FetchedResults<BookCSVData>

    var body: some View {
        style.makeBody(configuration: XPProgressStyleConfiguration(readingDays: readingDays, books: books))
    }
}

extension XPProgressStyleConfiguration {
    private struct Values {
        static let dayRead = 10
        static let consecutiveWeek = 100
        static let consecutiveMonth = 1000

        static let finishedBook = 500
    }
}

extension XPProgressStyleConfiguration {
    var xp: Int {
        var booksReadXP = 0
        var totalDaysXP: Int = 0
        var streakXP: Int = 0
        
        booksReadXP = books.reduce(0, { acc, book in
            if case .year = book.year {
                return acc + Values.finishedBook
            } else {
                return acc
            }
        })
        
        totalDaysXP = readingDays.count * Values.dayRead
        
        let grouped = readingDays
            .compactMap{$0.date}
            .reduce(into: [[Date]]()) { acc, date in
                if let latestGroup: [Date] = acc.last,
                   let latestDate: Date = latestGroup.last,
                   let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: date),
                   latestDate == yesterday {
                    acc[acc.count - 1].append(date)
                } else {
                    acc.append([date])
                }
            }
        
        var xp = 0
        for group in grouped {
            switch group.count {
            case let value where value > 30: xp += Values.consecutiveMonth
            case let value where value > 7: xp += Values.consecutiveWeek
            default: ()
            }
        }
        streakXP = xp
        
        return booksReadXP + totalDaysXP + streakXP
    }
    
    var level: Int {
        Self.level(for: xp)
    }
    
    static func xp(for level: Int) -> Int {
        return Int((pow(Double(level), 2) + Double(level)) / 2 * 100 - (Double(level) * 100))
    }
    
    static func level(for xp: Int) -> Int {
        Int((50.0 + sqrt(2500 + 200 * Double(xp))) / 100.0)
    }
}

extension XPProgressStyle where Self == BadgeXPProgressStyle {
    static var badge: BadgeXPProgressStyle { get { BadgeXPProgressStyle() } }
}

struct XPProgressView_Previews : PreviewProvider {
    static var previews: some View {
        VStack {
            XPProgressView()
            Button {
//                additionalXP += 10
            } label: {
                Text("Add XP")
            }
            XPProgressView()
                .xpProgressStyle(.badge)
        }
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .padding(.horizontal)
    }
}
