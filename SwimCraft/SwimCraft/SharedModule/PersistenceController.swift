//
//  PersistenceController.swift
//  SharedModule
//
//  Created by Brenna Pavlinchak on 8/10/25.
//

import Foundation
import CoreData

struct PersistenceController
{
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    var context: NSManagedObjectContext
    {
        return container.viewContext
    }
    
    init()
    {
        let bundle = Bundle.main
        print("Using bundle: \(bundle.bundleIdentifier ?? "nil") at path: \(bundle.bundlePath)")
        
        let momdResources = bundle.urls(forResourcesWithExtension: "momd", subdirectory: nil)
        print("Available .momd resources in bundle: \(momdResources ?? [])")
        
        guard let modelURL = bundle.url(forResource: "SwimCraft", withExtension: "momd") else
        {
            print("Error: Failed to find SwimCraft.momd in bundle: \(bundle.bundlePath)")
            fatalError("Failed to load Core Data model named SwimCraft")
        }
        print("Found modelURL: \(modelURL)")
        
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else
        {
            print("Error: Failed to initialize NSManagedObjectModel with URL: \(modelURL)")
            fatalError("Failed to load Core Data model named SwimCraft")
        }
        print("Initialized managedObjectModel successfully")
        
        container = NSPersistentContainer(name: "SwimCraft", managedObjectModel: managedObjectModel)
        container.loadPersistentStores
        {
            _, error in
            
            if let error = error as NSError?
            {
                print("Core Data failed to load: \(error), \(error.userInfo)")
            }
            else
            {
                print("Core Data loaded successfully")
            }
        }
    }
    
    func saveWorkout(_ workout: SwimWorkout)
    {
        let workoutEntity = NSEntityDescription.insertNewObject(forEntityName: "SwimWorkoutEntity", into: context)
        workoutEntity.setValue(workout.id.uuidString, forKey: "id")
        workoutEntity.setValue(workout.name, forKey: "name")
        workoutEntity.setValue(workout.coach?.name, forKey: "coachName")
        workoutEntity.setValue(workout.createdViaWorkoutKit, forKey: "createdViaWorkoutKit")
        workoutEntity.setValue(workout.source, forKey: "source")
        
        let warmUpSet = NSSet(array: workout.warmUp.map
                              {
            segment in
            let segmentEntity = NSEntityDescription.insertNewObject(forEntityName: "WorkoutSegmentEntity", into: context)
            segmentEntity.setValue(segment.yards, forKey: "yards")
            segmentEntity.setValue(segment.type, forKey: "type")
            segmentEntity.setValue(segment.amount, forKey: "amount")
            segmentEntity.setValue(segment.stroke, forKey: "stroke")
            segmentEntity.setValue(segment.time, forKey: "time")
            return segmentEntity
        })
        workoutEntity.setValue(warmUpSet, forKey: "warmUp")
        
        let mainSetSet = NSSet(array: workout.mainSet.map
                               {
            segment in
            let segmentEntity = NSEntityDescription.insertNewObject(forEntityName: "WorkoutSegmentEntity", into: context)
            segmentEntity.setValue(segment.yards, forKey: "yards")
            segmentEntity.setValue(segment.type, forKey: "type")
            segmentEntity.setValue(segment.amount, forKey: "amount")
            segmentEntity.setValue(segment.stroke, forKey: "stroke")
            segmentEntity.setValue(segment.time, forKey: "time")
            return segmentEntity
        })
        workoutEntity.setValue(mainSetSet, forKey: "mainSet")
        
        let coolDownSet = NSSet(array: workout.coolDown.map
                                {
            segment in
            let segmentEntity = NSEntityDescription.insertNewObject(forEntityName: "WorkoutSegmentEntity", into: context)
            segmentEntity.setValue(segment.yards, forKey: "yards")
            segmentEntity.setValue(segment.type, forKey: "type")
            segmentEntity.setValue(segment.amount, forKey: "amount")
            segmentEntity.setValue(segment.stroke, forKey: "stroke")
            segmentEntity.setValue(segment.time, forKey: "time")
            return segmentEntity
        })
        workoutEntity.setValue(coolDownSet, forKey: "coolDown")
        
        do
        {
            try context.save()
            print("Successfully saved SwimWorkout to Core Data: \(workout.name)")
        }
        catch
        {
            print("Failed to save SwimWorkout to Core Data: \(error.localizedDescription)")
        }
    }
}
