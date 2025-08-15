//
//  WorkoutSegmentEntity+CoreDataProperties.swift
//  
//
//  Created by Brenna Pavlinchak on 8/15/25.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension WorkoutSegmentEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkoutSegmentEntity> {
        return NSFetchRequest<WorkoutSegmentEntity>(entityName: "WorkoutSegmentEntity")
    }

    @NSManaged public var amount: Int32
    @NSManaged public var stroke: String?
    @NSManaged public var time: Double
    @NSManaged public var type: String?
    @NSManaged public var yards: Double

}

extension WorkoutSegmentEntity : Identifiable {

}
