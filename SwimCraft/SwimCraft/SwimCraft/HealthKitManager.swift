//
//  HealthKitManager.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 7/9/25.
//

import HealthKit

class HealthKitManager
{
    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()

    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void)
    {
        guard HKHealthStore.isHealthDataAvailable() else
        {
            completion(false, NSError(domain: "HealthKit", code: -1, userInfo: [NSLocalizedDescriptionKey: "HealthKit not available on this device"]))
            return
        }

        let typesToShare: Set = [HKObjectType.workoutType(), HKQuantityType.quantityType(forIdentifier: .distanceSwimming)!]
        let typesToRead: Set = [HKObjectType.workoutType(), HKQuantityType.quantityType(forIdentifier: .distanceSwimming)!]

        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead, completion: completion)
    }

    func saveWorkout(_ swimWorkout: SwimWorkout, completion: @escaping (Bool, Error?) -> Void)
    {
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
            guard success else
            {
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

            builder.add([distanceSample]) { success, error in
                guard success else
                {
                    completion(false, error)
                    return
                }

                builder.addMetadata([
                    "name": swimWorkout.name, // Added name to metadata
                    "coach": swimWorkout.coach?.name ?? "None",
                    "strokes": swimWorkout.strokes.joined(separator: ","),
                    "createdViaWorkoutKit": swimWorkout.createdViaWorkoutKit,
                    "source": swimWorkout.source ?? ""
                ])
                {
                    success, error in
                    guard success else
                    {
                        completion(false, error)
                        return
                    }

                    builder.endCollection(withEnd: endDate) { success, error in
                        guard success else
                        {
                            completion(false, error)
                            return
                        }

                        builder.finishWorkout
                        {
                            workout, error in
                            completion(workout != nil, error)
                        }
                    }
                }
            }
        }
    }

    func fetchWorkouts(completion: @escaping ([SwimWorkout]?, Error?) -> Void)
    {
        let predicate = HKQuery.predicateForWorkouts(with: .swimming)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: .workoutType(), predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor])
        {
            _, samples, error in
            let workouts = samples?.compactMap
            {
                sample -> SwimWorkout? in
                guard let workout = sample as? HKWorkout else { return nil }
                let strokes = (workout.metadata?["strokes"] as? String)?.components(separatedBy: ",") ?? []
                let createdViaWorkoutKit = (workout.metadata?["createdViaWorkoutKit"] as? Bool) ?? (workout.metadata?["coach"] as? String == "None")
                return SwimWorkout(
                    id: workout.uuid,
                    name: workout.metadata?["name"] as? String ?? "Swim Workout",
                    coach: nil,
                    distance: workout.totalDistance?.doubleValue(for: .meter()) ?? 0,
                    duration: workout.duration,
                    strokes: strokes,
                    createdViaWorkoutKit: createdViaWorkoutKit,
                    source: workout.metadata?["source"] as? String
                )
            }
            completion(workouts, error)
        }
        healthStore.execute(query)
    }
}
