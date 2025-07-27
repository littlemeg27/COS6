//
//  HealthKitManager.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 7/9/25.
//

import HealthKit

class HealthKitManager {
    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()
    
    private init() {}
    
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, NSError(domain: "HealthKit", code: -1, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available on this device"]))
            return
        }
        
        let typesToShare: Set = [HKObjectType.workoutType()]
        let typesToRead: Set = [HKObjectType.workoutType(), HKQuantityType.quantityType(forIdentifier: .distanceSwimming)!]
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            completion(success, error)
        }
    }
    
    func saveWorkout(_ swimWorkout: SwimWorkout, completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, NSError(domain: "HealthKit", code: -1, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available on this device"]))
            return
        }
        
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .swimming
        
        let builder = HKWorkoutBuilder(healthStore: healthStore, configuration: workoutConfiguration, device: .local())
        
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(swimWorkout.duration)
        
        builder.beginCollection(withStart: startDate) { success, error in
            guard success else {
                completion(false, error)
                return
            }
            
            // Add metadata
            var metadata: [String: Any] = [
                "WorkoutName": swimWorkout.name,
                "CoachName": swimWorkout.coach?.name ?? "None",
                "Strokes": swimWorkout.strokes.joined(separator: ", ")
            ]
            
            metadata["WarmUpSegments"] = swimWorkout.warmUp.map { "\($0.amount)x \($0.yards) yards \($0.stroke) (\($0.type), \(Int($0.time)) sec)" }.joined(separator: ";")
            metadata["MainSetSegments"] = swimWorkout.mainSet.map { "\($0.amount)x \($0.yards) yards \($0.stroke) (\($0.type), \(Int($0.time)) sec)" }.joined(separator: ";")
            metadata["CoolDownSegments"] = swimWorkout.coolDown.map { "\($0.amount)x \($0.yards) yards \($0.stroke) (\($0.type), \(Int($0.time)) sec)" }.joined(separator: ";")
            
            builder.addMetadata(metadata) { success, error in
                guard success else {
                    completion(false, error)
                    return
                }
                
                // Add distance sample
                let distanceQuantity = HKQuantity(unit: HKUnit.meter(), doubleValue: swimWorkout.distance)
                let distanceSample = HKQuantitySample(
                    type: HKQuantityType.quantityType(forIdentifier: .distanceSwimming)!,
                    quantity: distanceQuantity,
                    start: startDate,
                    end: endDate
                )
                
                builder.add([distanceSample]) { success, error in
                    guard success else {
                        completion(false, error)
                        return
                    }
                    
                    // Finish workout
                    builder.endCollection(withEnd: endDate) { success, error in
                        guard success else {
                            completion(false, error)
                            return
                        }
                        
                        builder.finishWorkout { workout, error in
                            completion(workout != nil, error)
                        }
                    }
                }
            }
        }
    }
    
    func fetchWorkouts(completion: @escaping ([SwimWorkout]?, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(nil, NSError(domain: "HealthKit", code: -1, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available on this device"]))
            return
        }
        
        let predicate = HKQuery.predicateForWorkouts(with: .swimming)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: .workoutType(), predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, samples, error in
            guard let workouts = samples as? [HKWorkout], error == nil else {
                completion(nil, error)
                return
            }
            
            let swimWorkouts = workouts.map { workout -> SwimWorkout in
                let metadata = workout.metadata ?? [:]
                let name = metadata["WorkoutName"] as? String ?? "Unnamed Workout"
                let coachName = metadata["CoachName"] as? String
                let coach = coachName != nil ? Coach(name: coachName!, level: "Unknown", dateCompleted: workout.startDate, clubAbbr: "", clubName: "", lmsc: "") : nil
                
                let warmUpSegments = (metadata["WarmUpSegments"] as? String)?.split(separator: ";").map { self.parseSegment(String($0)) } ?? []
                let mainSetSegments = (metadata["MainSetSegments"] as? String)?.split(separator: ";").map { self.parseSegment(String($0)) } ?? []
                let coolDownSegments = (metadata["CoolDownSegments"] as? String)?.split(separator: ";").map { self.parseSegment(String($0)) } ?? []
                
                return SwimWorkout(
                    id: workout.uuid,
                    name: name,
                    coach: coach,
                    warmUp: warmUpSegments,
                    mainSet: mainSetSegments,
                    coolDown: coolDownSegments,
                    createdViaWorkoutKit: false,
                    source: nil
                )
            }
            
            completion(swimWorkouts, nil)
        }
        
        healthStore.execute(query)
    }
    
    private func parseSegment(_ segmentString: String) -> WorkoutSegment {
        // Simplified parsing: assumes format "amountx yards stroke (type, time sec)"
        let components = segmentString.components(separatedBy: " ")
        let amount = Int(components[0].replacingOccurrences(of: "x", with: "")) ?? 1
        let yards = Double(components[1]) ?? 0
        let stroke = components[2]
        let type = components[4].replacingOccurrences(of: "(", with: "")
        let time = TimeInterval(components[5].replacingOccurrences(of: "sec)", with: "")) ?? 30
        
        return WorkoutSegment(yards: yards, type: type, amount: amount, stroke: stroke, time: time)
    }
}
