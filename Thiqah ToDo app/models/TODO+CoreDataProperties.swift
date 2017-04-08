//
//  TODO+CoreDataProperties.swift
//  
//
//  Created by khaledannajar on 4/6/17.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension TODO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TODO> {
        return NSFetchRequest<TODO>(entityName: "TODO");
    }

    @NSManaged public var id: String?
    @NSManaged public var notes: String?
    @NSManaged public var title: String?

}
