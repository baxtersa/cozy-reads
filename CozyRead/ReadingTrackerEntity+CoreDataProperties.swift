//
//  ReadingTrackerEntity+CoreDataProperties.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/24/23.
//
//

import Foundation
import CoreData


extension ReadingTrackerEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReadingTrackerEntity> {
        return NSFetchRequest<ReadingTrackerEntity>(entityName: "ReadingTrackerEntity")
    }

    @NSManaged public var date: Date?
    @NSManaged public var profile: ProfileEntity?

}

extension ReadingTrackerEntity : Identifiable {

}
