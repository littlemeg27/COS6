//
//  HealthKitManager.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 7/9/25.
//

import HealthKit
import Foundation

class HealthKitManager {
    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()

    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, NSError(domain: "HealthKit", code: -1, userInfo: [NSLocalizedDescriptionKey: "HealthKit not available on this device"]))
            return
        }

        let typesToShare: Set = [HKObjectType.workoutType(), HKQuantityType.quantityType(forIdentifier: .distanceSwimming)!]
        let typesToRead: Set = [HKObjectType.workoutType(), HKQuantityType.quantityType(forIdentifier: .distanceSwimming)!]

        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead, completion: completion)
    }

    func saveWorkout(_ swimWorkout: SwimWorkout, completion: @escaping (Bool, Error?) -> Void) {
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .swimming
        workoutConfiguration.locationType = .indoor

        let builder = HKWorkoutBuilder(
            healthStore: healthStore,
            configuration: workoutConfiguration,
            device: nil
        )

        let startDate = Date()
        let endDate = startDate.addingTimeInterval(swimWorkout.duration)

        builder.beginCollection(withStart: startDate) { success, error in
            guard success else {
                completion(false, error)
                return
            }

            let distanceQuantity = HKQuantity(unit: .meter(), doubleValue: swimWorkout.distance)
            let distanceSample = HKQuantitySample(
                type: HKQuantityType.quantityType(forIdentifier: .distanceSwimming)!,
                quantity: distanceQuantity,
                start: startDate,
                end: endDate
            )

            let warmUpData = swimWorkout.warmUp.map { ["yards": $0.yards, "type": $0.type, "amount": $0.amount, "stroke": $0.stroke, "time": $0.time] }
            let mainSetData = swimWorkout.mainSet.map { ["yards": $0.yards, "type": $0.type, "amount": $0.amount, "stroke": $0.stroke, "time": $0.time] }
            let coolDownData = swimWorkout.coolDown.map { ["yards": $0.yards, "type": $0.type, "amount": $0.amount, "stroke": $0.stroke, "time": $0.time] }

            builder.add([distanceSample]) { success, error in
                guard success else {
                    completion(false, error)
                    return
                }

                builder.addMetadata([
                    "name": swimWorkout.name,
                    "coach": swimWorkout.coach?.name ?? "None",
                    "strokes": swimWorkout.strokes.joined(separator: ","),
                    "createdViaWorkoutKit": swimWorkout.createdViaWorkoutKit,
                    "source": swimWorkout.source ?? "",
                    "warmUp": warmUpData,
                    "mainSet": mainSetData,
                    "coolDown": coolDownData
                ]) { success, error in
                    guard success else {
                        completion(false, error)
                        return
                    }

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
        let predicate = HKQuery.predicateForWorkouts(with: .swimming)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: .workoutType(), predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, samples, error in
            guard let samples = samples as? [HKWorkout] else {
                completion(nil, error ?? NSError(domain: "HealthKit", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to cast samples to HKWorkout"]))
                return
            }

            let workouts: [SwimWorkout] = samples.compactMap { workout -> SwimWorkout? in
                let strokes = (workout.metadata?["strokes"] as? String)?.components(separatedBy: ",") ?? []
                let createdViaWorkoutKit = workout.metadata?["createdViaWorkoutKit"] as? Bool ?? false
                let source = workout.metadata?["source"] as? String
                
                let warmUpData = workout.metadata?["warmUp"] as? [[String: Any]] ?? []
                let mainSetData = workout.metadata?["mainSet"] as? [[String: Any]] ?? []
                let coolDownData = workout.metadata?["coolDown"] as? [[String: Any]] ?? []
                
                let warmUp: [WorkoutSegment] = warmUpData.compactMap { dict in
                    guard let yards = dict["yards"] as? Double,
                          let type = dict["type"] as? String,
                          let amount = dict["amount"] as? Int,
                          let stroke = dict["stroke"] as? String,
                          let time = dict["time"] as? TimeInterval else { return nil }
                    return WorkoutSegment(yards: yards, type: type, amount: amount, stroke: stroke, time: time)
                }
                
                let mainSet: [WorkoutSegment] = mainSetData.compactMap { dict in
                    guard let yards = dict["yards"] as? Double,
                          let type = dict["type"] as? String,
                          let amount = dict["amount"] as? Int,
                          let stroke = dict["stroke"] as? String,
                          let time = dict["time"] as? TimeInterval else { return nil }
                    return WorkoutSegment(yards: yards, type: type, amount: amount, stroke: stroke, time: time)
                }
                
                let coolDown: [WorkoutSegment] = coolDownData.compactMap { dict in
                    guard let yards = dict["yards"] as? Double,
                          let type = dict["type"] as? String,
                          let amount = dict["amount"] as? Int,
                          let stroke = dict["stroke"] as? String,
                          let time = dict["time"] as? TimeInterval else { return nil }
                    return WorkoutSegment(yards: yards, type: type, amount: amount, stroke: stroke, time: time)
                }
                
                return SwimWorkout(
                    id: workout.uuid,
                    name: workout.metadata?["name"] as? String ?? "Swim Workout",
                    coach: nil,
                    warmUp: warmUp,
                    mainSet: mainSet,
                    coolDown: coolDown,
                    createdViaWorkoutKit: createdViaWorkoutKit,
                    source: source
                )
            }
            completion(workouts, error)
        }
        healthStore.execute(query)
    }
}
