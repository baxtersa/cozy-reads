//
//  XPLevelsTests.swift
//  CozyReadTests
//
//  Created by Samuel Baxter on 8/21/23.
//

import XCTest
@testable import CozyRead

final class XPLevelsTests: XCTestCase {
//    func testDefaultLevel() {
//        assert(XPLevels.shared.level == 1)
//        assert(XPLevels.shared.xp == 0)
//    }
    
    func testXPForLevels() {
        assert(XPLevels.xp(for: 1) == 0)
        XCTAssertEqual(XPLevels.xp(for: 2), 100)
        XCTAssertEqual(XPLevels.xp(for: 3), 300)
        XCTAssertEqual(XPLevels.xp(for: 4), 600)
        XCTAssertEqual(XPLevels.xp(for: 5), 1000)
        XCTAssertEqual(XPLevels.xp(for: 6), 1500)
        XCTAssertEqual(XPLevels.xp(for: 7), 2100)
        XCTAssertEqual(XPLevels.xp(for: 8), 2800)
        XCTAssertEqual(XPLevels.xp(for: 9), 3600)
        XCTAssertEqual(XPLevels.xp(for: 10), 4500)
    }
    
    func testLevelForXP() {
        XCTAssertEqual(XPLevels.level(for: 0), 1)
        XCTAssertEqual(XPLevels.level(for: 40), 1)
        XCTAssertEqual(XPLevels.level(for: 100), 2)
        XCTAssertEqual(XPLevels.level(for: 300), 3)
        XCTAssertEqual(XPLevels.level(for: 600), 4)
        XCTAssertEqual(XPLevels.level(for: 1000), 5)
        XCTAssertEqual(XPLevels.level(for: 1500), 6)
        XCTAssertEqual(XPLevels.level(for: 2100), 7)
        XCTAssertEqual(XPLevels.level(for: 2800), 8)
        XCTAssertEqual(XPLevels.level(for: 3600), 9)
        XCTAssertEqual(XPLevels.level(for: 4500), 10)
    }
}
