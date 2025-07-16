//
//  HealthKitManager.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 7/9/25.
//

import HealthKit
import SharedModule

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

        let typesToShare: Set = [HKObjectType.workoutType()]
        let typesToRead: Set = [HKObjectType.workoutType()]

        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead, completion: completion)
    }

    func saveWorkout(_ swimWorkout: SwimWorkout, completion: @escaping (Bool, Error?) -> Void)
    {
        let workout = HKWorkout(
            activityType: .swimming,
            start: Date(),
            end: Date().addingTimeInterval(swimWorkout.duration),
            duration: swimWorkout.duration,
            totalEnergyBurned: nil as HKQuantity?,
            totalDistance: HKQuantity(unit: .meter(), doubleValue: swimWorkout.distance),
            metadata: [
                "coach": swimWorkout.coach?.name ?? "WorkoutKit",
                "strokes": swimWorkout.strokes.joined(separator: ","),
                "createdViaWorkoutKit": swimWorkout.createdViaWorkoutKit,
                "source": swimWorkout.source ?? ""
            ]
        )

        healthStore.save(workout)
        {
            success, error in
            completion(success, error)
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
                let createdViaWorkoutKit = (workout.metadata?["createdViaWorkoutKit"] as? Bool) ?? (workout.metadata?["coach"] as? String == "WorkoutKit")
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
