//
//  BookDataModel.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/8/23.
//

import CoreData
import Foundation
import SwiftUI

public enum Genre : String, CaseIterable, Hashable, Identifiable {
    case fantasy = "Fantasy"
    case sci_fi = "Sci-fi"
    case contemporary = "Contemporary"
    case horror = "Horror"
    case literary = "Literary Fiction"
    case nonfiction = "Nonfiction"
    case romance = "Romance"
    case historical = "Historical Fiction"
    case mystery = "Mystery"
    case magical_realism = "Magical Realism"
    case crime = "Crime"
    case thriller = "Thriller"
    case memoir = "Memoir"
    case biography = "Biography"
    case autobiography = "Autobiography"
    case poetry = "Poetry"
    case manga = "Manga"
    case comic = "Comic"
    case ya = "Young Adult"
    case middle_grade = "Middle Grade"
    
    public var id: Self { self }
}

extension Genre: Comparable {
    public static func < (lhs: Genre, rhs: Genre) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

public enum Year : Equatable, Hashable, Identifiable {
    case year(_: Int)
    case tbr
    case reading

    init?(from: String?) {
        guard let from = from else {
            return nil
        }

        switch from {
        case "TBR":
            self = .tbr
        case "Reading":
            self = .reading
        default:
            if let number = Int(from) {
                self = .year(number)
            } else {
                return nil
            }
        }
    }

    public var description: String {
        switch self {
        case .year(let num):
            return num.description
        case .reading:
            return "Reading"
        case .tbr:
            return "TBR"
        }
    }
    
    public var id: Self { self }
}

extension Year {
    static let defaultSelections: [Year] = [
        .tbr,
        .reading,
    ] + (0..<10).map {
        let current = Calendar.current.component(.year, from: .now)
        return .year(current - $0)
    }
}

extension Year: Comparable {
    static public func > (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.reading, _): return true
        case (.tbr, _): return false
        case (.year(let left), .year(let right)): return left > right
        case (.year(_), .tbr): return true
        case (.year(_), .reading): return false
        }
    }
}

public enum ReadType : String, CaseIterable, Hashable, Identifiable {
    case physical = "Physical"
    case ebook = "eBook"
    case audiobook = "Audiobook"

    public var id: Self { self }
    
    public init?(rawValue: String) {
        switch rawValue {
        case "Physical", "Owned - Physical", "Library":
            self = .physical
        case "eBook", "Owned - Apple Books", "Libby":
            self = .ebook
        case "Audiobook":
            self = .audiobook
        default:
            self = .physical
        }
    }
}

public enum ParseError : Error {
    case noTitle
    case noAuthor
    case noGenre
}

@objc(BookCSVData)
public class BookCSVData : NSManagedObject, InitFromDictionary, Identifiable {
    @NSManaged public var profile: ProfileEntity?
    
    @NSManaged public var title: String
    @NSManaged public var author: String
    @NSManaged public var series: String?

    @NSManaged public var rating: Double
    @NSManaged public var dateAdded: Date?
    @NSManaged public var dateCompleted: Date?
    @NSManaged public var dateStarted: Date?
    
    @NSManaged public var coverId: Int

    @NSManaged public var tags: [String]

    @NSManaged private var private_genre: String
    @nonobjc public var genre: Genre {
        Genre(rawValue: private_genre) ?? .fantasy
    }

    @NSManaged private var private_year: String
    @nonobjc public var year: Year {
        Year(from: private_year) ?? .tbr
    }

    @NSManaged private var private_readType: String
    @nonobjc public var readType: ReadType? {
        ReadType(rawValue: private_readType)
    }
    
    @nonobjc public required convenience init(managedContext: NSManagedObjectContext, year: Year? = nil, genre: Genre? = nil, readType: ReadType? = nil) {
        let entity = NSEntityDescription.entity(forEntityName: "BookCSVData", in: managedContext)!
        self.init(entity: entity, insertInto: managedContext)

        if let year = year {
            self.private_year = year.description
        } else {
            self.private_year = "TBR"
        }

        if let genre = genre {
            self.private_genre = genre.rawValue
        } else {
            self.private_genre = "Fantasy"
        }

        if let readType = readType {
            self.private_readType = readType.rawValue
        }
    }

    @nonobjc public required convenience init(from: [String:String], context: NSManagedObjectContext) throws {
        guard let title = from["Title"], !title.isEmpty else {
            throw ParseError.noTitle
        }
        guard let author = from["Author"], !author.isEmpty else {
            throw ParseError.noTitle
        }
        guard let genreString = from["Genre"] else {
            throw ParseError.noGenre
        }

        let entity = NSEntityDescription.entity(forEntityName: "BookCSVData", in: context)!
        self.init(entity: entity, insertInto: context)

        let rating = Double(from["Rating"] ?? "0") ?? 0
        
        if let tags = from["Tags"] {
            self.tags = tags.split(separator: ",").map{String($0)}
        }

        self.title = title
        self.author = author
        self.series = from["Series"].flatMap{$0.isEmpty ? nil : $0}
        self.private_genre = genreString
        if !self.tags.contains(where: { $0 == genreString }) {
            self.tags.append(genreString)
        }
        self.private_year = from["Year"] ?? ""
        self.rating = rating
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        self.dateAdded = dateFormatter.date(from: from["DateAdded"] ?? "")
        self.dateCompleted = dateFormatter.date(from: from["DateCompleted"] ?? "")
        self.dateStarted = dateFormatter.date(from: from["DateStarted"] ?? "")
        self.private_readType = from["ReadType"] ?? ""

        self.coverId = Int(from["CoverID"] ?? "0") ?? 0
    }
}

extension BookCSVData {
    @nonobjc class func fetchRequest(sortDescriptors: [SortDescriptor<BookCSVData>]? = nil, predicate: NSPredicate? = nil) -> NSFetchRequest<BookCSVData> {
        let request = NSFetchRequest<BookCSVData>(entityName: "BookCSVData");

        if let sort = sortDescriptors {
            request.sortDescriptors = sort.map{NSSortDescriptor($0)}
        }
        if let pred = predicate {
            request.predicate = pred
        }

        return request
    }
    
    @nonobjc static var getFetchRequest: NSFetchRequest<BookCSVData> {
        let request: NSFetchRequest<BookCSVData> = BookCSVData.fetchRequest()
        request.sortDescriptors = []
        
        return request
    }

    @nonobjc func setYear(_ year: Year) {
        self.private_year = year.description
    }

    @nonobjc func setGenre(_ genre: Genre) {
        self.private_genre = genre.rawValue
    }

    @nonobjc func setReadType(_ type: ReadType) {
        self.private_readType = type.rawValue
    }
}

extension BookCSVData {
    static let defaultTags: [String] = [
        "Fantasy",
        "Sci-fi",
        "Contemporary",
        "Horror",
        "Literary",
        "Nonfiction",
        "Romance",
        "Historical Fiction",
        "Mystery",
        "True Crime",
        "Thriller"
    ]
}

public protocol InitFromDictionary {
    init(from: [String:String], context: NSManagedObjectContext) throws;
}

public class BookDataModel : ObservableObject {
    static let shared = BookDataModel()
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.dateAdded, order: .reverse)]) var books: FetchedResults<BookCSVData>
}
