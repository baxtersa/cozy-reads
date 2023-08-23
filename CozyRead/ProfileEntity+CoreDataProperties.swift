//
//  ProfileEntity+CoreDataProperties.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/23/23.
//
//

import Foundation
import CoreData


extension ProfileEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProfileEntity> {
        return NSFetchRequest<ProfileEntity>(entityName: "ProfileEntity")
    }

    @NSManaged public var name: String
    @NSManaged public var uuid: UUID

}

extension ProfileEntity : Identifiable {

}
