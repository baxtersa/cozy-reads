//
//  CozyReadTests.swift
//  CozyReadTests
//
//  Created by Samuel Baxter on 8/1/23.
//

import XCTest
@testable import CozyRead

final class CSVReaderTests: XCTestCase {
    let persistence = PersistenceController.shared

    func testCSV() {
        let data : [BookCSVData] = CSVReader.readCSV(inputFile: "data.csv", context: PersistenceController.shared.container.viewContext)
        assert(!data.isEmpty)
    }
}
