//
//  YearlyGoalEntity+CoreDataProperties.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/28/23.
//
//

import Foundation
import CoreData


extension YearlyGoalEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<YearlyGoalEntity> {
        return NSFetchRequest<YearlyGoalEntity>(entityName: "YearlyGoalEntity")
    }

    @NSManaged private var year: Int
    @nonobjc public var targetYear: Year { .year(year) }
    func setYear(year: Int) {
        self.year = year
    }
    
    @NSManaged public var goal: Int
    @NSManaged public var profile: ProfileEntity?

}

extension YearlyGoalEntity : Identifiable {

}
