//
//  CSVReader.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/7/23.
//

import CoreData
import Foundation

struct CSVReader {
    static func readCSV<T: InitFromDictionary>(fromContents: String, context: NSManagedObjectContext) -> [T] {
        let lines = fromContents.components(separatedBy: "\n")
        guard let headers: [String] = lines.first?.components(separatedBy: ",") else {
            return []
        }
        
        var results: [T] = []
        lines.dropFirst().forEach { line in
            let data = line.components(separatedBy: ",")
            var entry: [String:String] = [:]
            zip(headers, data).forEach { (category, item) in
                entry[category] = item
            }
            if let datum = try? T(from: entry, context: context) {
                results.append(datum)
            }
        }
        return results
    }

    static func readCSV<T: InitFromDictionary>(inputFile: String, context: NSManagedObjectContext) -> [T] {
        if let filepath = Bundle.main.path(forResource: inputFile, ofType: nil) {
            do {
                let fileContent = try String(contentsOfFile: filepath)
                return readCSV(fromContents: fileContent, context: context)
            } catch {
                print("error: \(error)") // to do deal with errors
            }
        } else {
            print("\(inputFile) could not be found")
        }
        return []
    }
}
