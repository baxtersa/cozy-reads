//
//  BookDataModel.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/8/23.
//

import CoreData
import Foundation
import SwiftUI

public enum Genre : String {
    case fantasy = "Fantasy"
    case sci_fi = "Sci-fi"
    case contemporary = "Contemporary"
    case horror = "Horror"
}

public enum Year : Equatable {
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
}

public enum ReadType : String {
    case owned_physical = "Owned - Physical"
    case owned_ebook = "Owned - Apple Books"
    case libby = "Libby"
    case library = "Library"
}

public enum ParseError : Error {
    case noTitle
    case noAuthor
    case noGenre
}

@objc(BookCSVData)
public class BookCSVData : NSManagedObject, InitFromDictionary {
    @NSManaged public var title: String
    @NSManaged public var author: String
    @NSManaged public var series: String?

    @NSManaged public var rating: NSInteger
    @NSManaged public var dateAdded: Date?

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

        self.init(context: context)

        let rating = Int(from["Rating"] ?? "0") ?? 0

        self.title = title
        self.author = author
        self.series = from["Series"].flatMap{$0.isEmpty ? nil : $0}
        self.private_genre = genreString
        self.private_year = from["Year"] ?? ""
        self.rating = rating
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        self.dateAdded = dateFormatter.date(from: from["DateAdded"] ?? "")
        self.private_readType = from["ReadType"] ?? ""
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
}

public protocol InitFromDictionary {
    init(from: [String:String], context: NSManagedObjectContext) throws;
}

public class BookDataModel : ObservableObject {
    static let shared = BookDataModel()
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.dateAdded, order: .reverse)]) var books: FetchedResults<BookCSVData>
}
