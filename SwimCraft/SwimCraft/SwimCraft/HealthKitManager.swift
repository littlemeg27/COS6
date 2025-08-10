//
//  HealthKitManager.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 7/9/25.
//

import Foundation
import HealthKit
import CoreData

class HealthKitManager {
    private let healthStore = HKHealthStore()
    static let shared = HealthKitManager()
    
    // MARK: - Authorization
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit not available on this device")
            completion(false, NSError(domain: "HealthKit", code: -1, userInfo: [NSLocalizedDescriptionKey: "HealthKit not available"]))
            return
        }
        
        let typesToShare: Set = [HKObjectType.workoutType()]
        let typesToRead: Set = [HKObjectType.workoutType()]
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            print("HealthKit authorization \(success ? "succeeded" : "failed"), error: \(error?.localizedDescription ?? "none")")
            completion(success, error)
        }
    }
    
    // MARK: - Save Workout
    func saveWorkout(_ workout: SwimWorkout, context: NSManagedObjectContext, completion: @escaping (Bool, Error?) -> Void) {
        var metadata: [String: Any] = [
            HKMetadataKeyWorkoutBrandName: workout.name,
            "WorkoutID": workout.id.uuidString
        ]
        if let source = workout.source {
            metadata[HKMetadataKeyExternalUUID] = source
        }
        metadata["CreatedViaWorkoutKit"] = workout.createdViaWorkoutKit
        
        let warmUpDistance = workout.warmUp.reduce(0.0) { $0 + ($1.yards ?? 0) }
        let mainSetDistance = workout.mainSet.reduce(0.0) { $0 + ($1.yards ?? 0) }
        let coolDownDistance = workout.coolDown.reduce(0.0) { $0 + ($1.yards ?? 0) }
        let totalDistance = warmUpDistance + mainSetDistance + coolDownDistance
        
        let warmUpDuration = workout.warmUp.reduce(0.0) { $0 + ($1.time ?? 0) }
        let mainSetDuration = workout.mainSet.reduce(0.0) { $0 + ($1.time ?? 0) }
        let coolDownDuration = workout.coolDown.reduce(0.0) { $0 + ($1.time ?? 0) }
        let totalDuration = warmUpDuration + mainSetDuration + coolDownDuration
        
        let hkWorkout = HKWorkout(
            activityType: .swimming,
            start: Date(),
            end: Date().addingTimeInterval(totalDuration),
            workoutEvents: nil,
            totalEnergyBurned: nil,
            totalDistance: HKQuantity(unit: .meter(), doubleValue: totalDistance),
            metadata: metadata
        )
        
        healthStore.save(hkWorkout) { success, error in
            if success {
                print("Successfully saved HKWorkout: \(workout.name), ID: \(workout.id.uuidString)")
                do {
                    let workoutEntity = NSEntityDescription.insertNewObject(forEntityName: "SwimWorkoutEntity", into: context)
                    workoutEntity.setValue(workout.id.uuidString, forKey: "id")
                    workoutEntity.setValue(workout.name, forKey: "name")
                    workoutEntity.setValue(workout.coach?.name, forKey: "coachName")
                    workoutEntity.setValue(workout.createdViaWorkoutKit, forKey: "createdViaWorkoutKit")
                    workoutEntity.setValue(workout.source, forKey: "source")
                    
                    let warmUpEntities = workout.warmUp.map { segment in
                        let segmentEntity = NSEntityDescription.insertNewObject(forEntityName: "WorkoutSegmentEntity", into: context)
                        segmentEntity.setValue(segment.type, forKey: "type")
                        segmentEntity.setValue(segment.stroke, forKey: "stroke")
                        segmentEntity.setValue(segment.yards, forKey: "yards")
                        segmentEntity.setValue(segment.amount, forKey: "amount")
                        segmentEntity.setValue(segment.time, forKey: "time")
                        return segmentEntity
                    }
                    let mainSetEntities = workout.mainSet.map { segment in
                        let segmentEntity = NSEntityDescription.insertNewObject(forEntityName: "WorkoutSegmentEntity", into: context)
                        segmentEntity.setValue(segment.type, forKey: "type")
                        segmentEntity.setValue(segment.stroke, forKey: "stroke")
                        segmentEntity.setValue(segment.yards, forKey: "yards")
                        segmentEntity.setValue(segment.amount, forKey: "amount")
                        segmentEntity.setValue(segment.time, forKey: "time")
                        return segmentEntity
                    }
                    let coolDownEntities = workout.coolDown.map { segment in
                        let segmentEntity = NSEntityDescription.insertNewObject(forEntityName: "WorkoutSegmentEntity", into: context)
                        segmentEntity.setValue(segment.type, forKey: "type")
                        segmentEntity.setValue(segment.stroke, forKey: "stroke")
                        segmentEntity.setValue(segment.yards, forKey: "yards")
                        segmentEntity.setValue(segment.amount, forKey: "amount")
                        segmentEntity.setValue(segment.time, forKey: "time")
                        return segmentEntity
                    }
                    
                    workoutEntity.setValue(NSSet(array: warmUpEntities), forKey: "warmUp")
                    workoutEntity.setValue(NSSet(array: mainSetEntities), forKey: "mainSet")
                    workoutEntity.setValue(NSSet(array: coolDownEntities), forKey: "coolDown")
                    
                    try context.save()
                    print("Successfully saved SwimWorkout to Core Data: \(workout.name)")
                    
                    // Debug Core Data count
                    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SwimWorkoutEntity")
                    let count = try? context.count(for: fetchRequest)
                    print("Core Data SwimWorkout count: \(count ?? 0)")
                    
                    completion(true, nil)
                } catch {
                    print("Error saving to Core Data: \(error.localizedDescription)")
                    completion(false, error)
                }
            } else {
                print("Error saving HKWorkout: \(error?.localizedDescription ?? "Unknown error")")
                completion(false, error)
            }
        }
    }
    
    // MARK: - Fetch Workouts
    func fetchWorkouts(context: NSManagedObjectContext, completion: @escaping ([SwimWorkout], Error?) -> Void) {
        let predicate = HKQuery.predicateForWorkouts(with: .swimming)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: .workoutType(), predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, samples, error in
            print("Fetched samples: \(samples?.count ?? 0), error: \(error?.localizedDescription ?? "none")")
            
            // Debug all workouts in HealthKit
            if let allWorkouts = samples as? [HKWorkout] {
                for workout in allWorkouts {
                    print("HealthKit workout: ID=\(workout.metadata?["WorkoutID"] as? String ?? "N/A"), name=\(workout.metadata?[HKMetadataKeyWorkoutBrandName] as? String ?? "Unnamed"), activityType=\(workout.workoutActivityType.rawValue)")
                }
            }
            
            let workouts = (samples as? [HKWorkout])?.compactMap { hkWorkout -> SwimWorkout? in
                let workoutID = hkWorkout.metadata?["WorkoutID"] as? String ?? UUID().uuidString
                print("Processing workout: ID=\(workoutID), name=\(hkWorkout.metadata?[HKMetadataKeyWorkoutBrandName] as? String ?? "Unnamed")")
                
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SwimWorkoutEntity")
                fetchRequest.predicate = NSPredicate(format: "id == %@", workoutID)
                
                do {
                    guard let swimWorkoutEntity = try context.fetch(fetchRequest).first else {
                        print("No Core Data entity found for workout ID: \(workoutID)")
                        return SwimWorkout(
                            id: UUID(uuidString: workoutID) ?? UUID(),
                            name: hkWorkout.metadata?[HKMetadataKeyWorkoutBrandName] as? String ?? "Unnamed Workout",
                            coach: nil,
                            warmUp: [],
                            mainSet: [],
                            coolDown: [],
                            createdViaWorkoutKit: hkWorkout.metadata?["CreatedViaWorkoutKit"] as? Bool ?? false,
                            source: hkWorkout.metadata?[HKMetadataKeyExternalUUID] as? String
                        )
                    }
                    
                    let warmUp = (swimWorkoutEntity.value(forKey: "warmUp") as? NSSet)?.allObjects.compactMap { entity -> WorkoutSegment? in
                        guard let entity = entity as? NSManagedObject else { return nil }
                        return WorkoutSegment(
                            yards: entity.value(forKey: "yards") as? Double,
                            type: entity.value(forKey: "type") as? String ?? "Swim",
                            amount: entity.value(forKey: "amount") as? Int,
                            stroke: entity.value(forKey: "stroke") as? String ?? "Freestyle",
                            time: entity.value(forKey: "time") as? TimeInterval
                        )
                    } ?? []
                    
                    let mainSet = (swimWorkoutEntity.value(forKey: "mainSet") as? NSSet)?.allObjects.compactMap { entity -> WorkoutSegment? in
                        guard let entity = entity as? NSManagedObject else { return nil }
                        return WorkoutSegment(
                            yards: entity.value(forKey: "yards") as? Double,
                            type: entity.value(forKey: "type") as? String ?? "Swim",
                            amount: entity.value(forKey: "amount") as? Int,
                            stroke: entity.value(forKey: "stroke") as? String ?? "Freestyle",
                            time: entity.value(forKey: "time") as? TimeInterval
                        )
                    } ?? []
                    
                    let coolDown = (swimWorkoutEntity.value(forKey: "coolDown") as? NSSet)?.allObjects.compactMap { entity -> WorkoutSegment? in
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
                        source: hkWorkout.metadata?[HKMetadataKeyExternalUUID] as? String
                    )
                } catch {
                    print("Error fetching Core Data entity for workout ID: \(workoutID), error: \(error.localizedDescription)")
                    return nil
                }
            } ?? []
            
            let uniqueWorkouts = Array(Set(workouts))
            print("Fetched \(uniqueWorkouts.count) unique workouts: \(uniqueWorkouts.map { $0.name })")
            
            // Debug Core Data contents
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SwimWorkoutEntity")
            if let coreDataWorkouts = try? context.fetch(fetchRequest) {
                print("Core Data contains \(coreDataWorkouts.count) SwimWorkout entities")
                for entity in coreDataWorkouts {
                    print("Core Data workout: ID=\(entity.value(forKey: "id") as? String ?? "N/A"), name=\(entity.value(forKey: "name") as? String ?? "N/A")")
                }
            }
            
            completion(uniqueWorkouts, error)
        }
        healthStore.execute(query)
    }
    
    // MARK: - Delete Workouts
    func deleteWorkouts(_ workouts: [SwimWorkout], context: NSManagedObjectContext, completion: @escaping (Bool, Error?) -> Void) {
        let workoutIDs = workouts.map { $0.id.uuidString }
        print("Attempting to delete \(workouts.count) workouts: \(workouts.map { $0.name })")
        
        let predicate = HKQuery.predicateForObjects(withMetadataKey: "WorkoutID", allowedValues: workoutIDs)
        let query = HKSampleQuery(sampleType: .workoutType(), predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            guard let hkWorkouts = samples as? [HKWorkout], error == nil else {
                print("Error fetching workouts to delete: \(error?.localizedDescription ?? "Unknown error")")
                completion(false, error)
                return
            }
            
            self.healthStore.delete(hkWorkouts) { success, error in
                if success {
                    print("Successfully deleted \(hkWorkouts.count) HKWorkouts")
                    do {
                        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SwimWorkoutEntity")
                        fetchRequest.predicate = NSPredicate(format: "id IN %@", workoutIDs)
                        let entities = try context.fetch(fetchRequest)
                        for entity in entities {
                            context.delete(entity)
                        }
                        try context.save()
                        print("Successfully deleted \(entities.count) SwimWorkout entities, remaining count: \(try? context.count(for: NSFetchRequest(entityName: "SwimWorkoutEntity")) ?? 0)")
                        completion(true, nil)
                    } catch {
                        print("Error deleting from Core Data: \(error.localizedDescription)")
                        completion(false, error)
                    }
                } else {
                    print("Error deleting HKWorkouts: \(error?.localizedDescription ?? "Unknown error")")
                    completion(false, error)
                }
            }
        }
        healthStore.execute(query)
    }
}
