//
//  HealthKitManager.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 7/9/25.
//

import Foundation
import HealthKit
import CoreData

class HealthKitManager
{
    static let shared = HealthKitManager()
    
    let healthStore = HKHealthStore()
    
    func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Void)
    {
        guard HKHealthStore.isHealthDataAvailable() else
        {
            completion(false, NSError(domain: "HealthKitManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available on this device"]))
            return
        }
        
        let readTypes: Set<HKObjectType> = [
            HKObjectType.workoutType(),
            HKSeriesType.workoutRoute(),
            HKObjectType.quantityType(forIdentifier: .distanceSwimming)!,
            HKObjectType.quantityType(forIdentifier: .swimmingStrokeCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]
        
        let writeTypes: Set<HKSampleType> = [
            HKObjectType.workoutType()
        ]
        
        healthStore.requestAuthorization(toShare: writeTypes, read: readTypes)
        {
            success, error in
            completion(success, error)
        }
    }
    
    func saveWorkoutToHealthKit(workout: SwimWorkout, completion: @escaping (Bool, Error?) -> Void)
    {
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .swimming
        workoutConfiguration.swimmingLocationType = .pool
        
        let builder = HKWorkoutBuilder(healthStore: healthStore, configuration: workoutConfiguration, device: .local())
        
        builder.beginCollection(withStart: workout.date)
        {
            success, error in
            guard success else
            {
                completion(false, error)
                return
            }
            
            let distanceQuantity = HKQuantity(unit: HKUnit.meter(), doubleValue: workout.distance)
            let distanceSample = HKQuantitySample(type: HKQuantityType.quantityType(forIdentifier: .distanceSwimming)!, quantity: distanceQuantity, start: workout.date, end: workout.date.addingTimeInterval(workout.duration))
            
            let energyQuantity = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: workout.estimatedCalories)
            let energySample = HKQuantitySample(type: HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!, quantity: energyQuantity, start: workout.date, end: workout.date.addingTimeInterval(workout.duration))
            
            builder.add([distanceSample, energySample])
            {
                success, error in
                guard success else
                {
                    completion(false, error)
                    return
                }
                
                builder.endCollection(withEnd: workout.date.addingTimeInterval(workout.duration))
                {
                    success, error in
                    guard success else
                    {
                        completion(false, error)
                        return
                    }
                    
                    builder.finishWorkout
                    {
                        hkWorkout, error in
                        completion(hkWorkout != nil, error)
                    }
                }
            }
        }
    }
    
    func loadWorkouts(completion: @escaping ([HKWorkout]?, Error?) -> Void)
    {
        let predicate = HKQuery.predicateForWorkouts(with: .swimming)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: HKObjectType.workoutType(), predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor])
        {
            _, samples, error in
            completion(samples as? [HKWorkout], error)
        }
        
        healthStore.execute(query)
    }

    func fetchWorkouts(context: NSManagedObjectContext, completion: @escaping ([SwimWorkout], Error?) -> Void)
    {
        let predicate = HKQuery.predicateForWorkouts(with: .swimming)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: .workoutType(), predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor])
        {
            _, samples, error in
            print("Fetched samples: \(samples?.count ?? 0), error: \(error?.localizedDescription ?? "none")")

            if let allWorkouts = samples as? [HKWorkout]
            {
                for workout in allWorkouts
                {
                    print("HealthKit workout: ID=\(workout.metadata?["WorkoutID"] as? String ?? "N/A"), name=\(workout.metadata?[HKMetadataKeyWorkoutBrandName] as? String ?? "Unnamed"), activityType=\(workout.workoutActivityType.rawValue)")
                }
            }
            
            let workouts = (samples as? [HKWorkout])?.compactMap
            {
                hkWorkout -> SwimWorkout? in
                let workoutID = hkWorkout.metadata?["WorkoutID"] as? String ?? UUID().uuidString
                print("Processing workout: ID=\(workoutID), name=\(hkWorkout.metadata?[HKMetadataKeyWorkoutBrandName] as? String ?? "Unnamed")")
                
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SwimWorkoutEntity")
                fetchRequest.predicate = NSPredicate(format: "id == %@", workoutID)
                
                do {
                    guard let swimWorkoutEntity = try context.fetch(fetchRequest).first else
                    {
                        print("No Core Data entity found for workout ID: \(workoutID)")
                        return SwimWorkout(
                            id: UUID(uuidString: workoutID) ?? UUID(),
                            name: hkWorkout.metadata?[HKMetadataKeyWorkoutBrandName] as? String ?? "Unnamed Workout",
                            coach: nil,
                            warmUp: [],
                            mainSet: [],
                            coolDown: [],
                            createdViaWorkoutKit: hkWorkout.metadata?["CreatedViaWorkoutKit"] as? Bool ?? false,
                            source: hkWorkout.metadata?[HKMetadataKeyExternalUUID] as? String,
                            date: hkWorkout.startDate
                        )
                    }
                    
                    let warmUp = (swimWorkoutEntity.value(forKey: "warmUp") as? NSSet)?.allObjects.compactMap
                    {
                        entity -> WorkoutSegment? in
                        guard let entity = entity as? NSManagedObject else { return nil }
                        return WorkoutSegment(
                            yards: entity.value(forKey: "yards") as? Double,
                            type: entity.value(forKey: "type") as? String ?? "Swim",
                            amount: entity.value(forKey: "amount") as? Int,
                            stroke: entity.value(forKey: "stroke") as? String ?? "Freestyle",
                            time: entity.value(forKey: "time") as? TimeInterval
                        )
                    } ?? []
                    
                    let mainSet = (swimWorkoutEntity.value(forKey: "mainSet") as? NSSet)?.allObjects.compactMap
                    {
                        entity -> WorkoutSegment? in
                        guard let entity = entity as? NSManagedObject else { return nil }
                        return WorkoutSegment(
                            yards: entity.value(forKey: "yards") as? Double,
                            type: entity.value(forKey: "type") as? String ?? "Swim",
                            amount: entity.value(forKey: "amount") as? Int,
                            stroke: entity.value(forKey: "stroke") as? String ?? "Freestyle",
                            time: entity.value(forKey: "time") as? TimeInterval
                        )
                    } ?? []
                    
                    let coolDown = (swimWorkoutEntity.value(forKey: "coolDown") as? NSSet)?.allObjects.compactMap
                    {
                        entity -> WorkoutSegment? in
                        guard let entity = entity as? NSManagedObject else { return nil }
                        return WorkoutSegment(
                            yards: entity.value(forKey: "yards") as? Double,
                            type: entity.value(forKey: "type") as? String ?? "Swim",
                            amount: entity.value(forKey: "amount") as? Int,
                            stroke: entity.value(forKey: "stroke") as? String ?? "Freestyle",
                            time: entity.value(forKey: "time") as? TimeInterval
                        )
                    } ?? []
                    
                    let coachName = swimWorkoutEntity.value(forKey: "coachName") as? String
                    let coach = coachName != nil ? Coach(name: coachName!, level: "Level 1", dateCompleted: Date(), clubAbbr: "", clubName: "", lmsc: "") : nil
                    
                    return SwimWorkout(
                        id: UUID(uuidString: workoutID) ?? UUID(),
                        name: hkWorkout.metadata?[HKMetadataKeyWorkoutBrandName] as? String ?? "Unnamed Workout",
                        coach: coach,
                        warmUp: warmUp,
                        mainSet: mainSet,
                        coolDown: coolDown,
                        createdViaWorkoutKit: hkWorkout.metadata?["CreatedViaWorkoutKit"] as? Bool ?? false,
                        source: hkWorkout.metadata?[HKMetadataKeyExternalUUID] as? String,
                        date: hkWorkout.startDate
                    )
                }
                catch
                {
                    print("Error fetching Core Data entity for workout ID: \(workoutID), error: \(error.localizedDescription)")
                    return nil
                }
            }
            ?? []
            
            let uniqueWorkouts = Array(Set(workouts))
            print("Fetched \(uniqueWorkouts.count) unique workouts: \(uniqueWorkouts.map { $0.name })")

            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SwimWorkoutEntity")
            
            if let coreDataWorkouts = try? context.fetch(fetchRequest)
            {
                print("Core Data contains \(coreDataWorkouts.count) SwimWorkout entities")
                
                for entity in coreDataWorkouts
                {
                    print("Core Data workout: ID=\(entity.value(forKey: "id") as? String ?? "N/A"), name=\(entity.value(forKey: "name") as? String ?? "N/A")")
                }
            }
            
            completion(uniqueWorkouts, error)
        }
        healthStore.execute(query)
    }
    
    func deleteWorkouts(_ workouts: [SwimWorkout], context: NSManagedObjectContext, completion: @escaping (Bool, Error?) -> Void)
    {
        let workoutIDs = workouts.map { $0.id.uuidString }
        print("Attempting to delete \(workouts.count) workouts: \(workouts.map { $0.name })")
        
        let predicate = HKQuery.predicateForObjects(withMetadataKey: "WorkoutID", allowedValues: workoutIDs)
        let query = HKSampleQuery(sampleType: .workoutType(), predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil)
        {
            _, samples, error in
            
            guard let hkWorkouts = samples as? [HKWorkout], error == nil else
            {
                print("Error fetching workouts to delete: \(error?.localizedDescription ?? "Unknown error")")
                completion(false, error)
                return
            }
            
            self.healthStore.delete(hkWorkouts)
            {
                success, error in
                
                if success
                {
                    print("Successfully deleted \(hkWorkouts.count) HKWorkouts")
                    do
                    {
                        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SwimWorkoutEntity")
                        fetchRequest.predicate = NSPredicate(format: "id IN %@", workoutIDs)
                        let entities = try context.fetch(fetchRequest)
                        for entity in entities {
                            context.delete(entity)
                        }
                        try context.save()
                        let remainingRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SwimWorkoutEntity")
                        let remainingCount = (try? context.count(for: remainingRequest)) ?? 0
                        print("Successfully deleted \(entities.count) SwimWorkout entities, remaining count: \(remainingCount)")
                        completion(true, nil)
                    }
                    catch
                    {
                        print("Error deleting from Core Data: \(error.localizedDescription)")
                        completion(false, error)
                    }
                }
                else
                {
                    print("Error deleting HKWorkouts: \(error?.localizedDescription ?? "Unknown error")")
                    completion(false, error)
                }
            }
        }
        healthStore.execute(query)
    }
}
