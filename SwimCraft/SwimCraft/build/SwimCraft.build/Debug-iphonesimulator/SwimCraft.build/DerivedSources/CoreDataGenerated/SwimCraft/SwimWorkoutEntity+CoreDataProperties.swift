//
//  SwimWorkoutEntity+CoreDataProperties.swift
//  
//
//  Created by Brenna Pavlinchak on 8/15/25.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension SwimWorkoutEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SwimWorkoutEntity> {
        return NSFetchRequest<SwimWorkoutEntity>(entityName: "SwimWorkoutEntity")
    }

    @NSManaged public var coachName: String?
    @NSManaged public var createdViaWorkoutKit: Bool
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var source: String?
    @NSManaged public var coolDown: WorkoutSegmentEntity?
    @NSManaged public var mainSet: WorkoutSegmentEntity?
    @NSManaged public var warmUp: WorkoutSegmentEntity?

}

extension SwimWorkoutEntity : Identifiable {

}
