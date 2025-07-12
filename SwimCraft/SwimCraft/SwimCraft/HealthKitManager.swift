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
    
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        let typesToShare: Set = [HKObjectType.workoutType()]
        let typesToRead: Set = [HKObjectType.workoutType()]
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead, completion: completion)
    }
    
    func saveWorkout(_ swimWorkout: SwimWorkout, completion: @escaping (Bool, Error?) -> Void) {
        let workout = HKWorkout(
            activityType: .swimming,
            start: Date(),
            end: Date().addingTimeInterval(swimWorkout.duration),
            duration: swimWorkout.duration,
            totalEnergyBurned: nil,
            totalDistance: HKQuantity(unit: .meter(), doubleValue: swimWorkout.distance),
            metadata: ["coach": swimWorkout.coach?.name ?? "WorkoutKit"]
        )
        
        healthStore.save(workout)
        {
            success, error in
            completion(success, error)
        }
    }
    
    func fetchWorkouts(completion: @escaping ([SwimWorkout]?, Error?) -> Void) {
        let predicate = HKQuery.predicateForWorkouts(with: .swimming)
        let query = HKSampleQuery(sampleType: .workoutType(), predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            let workouts = samples?.compactMap { sample -> SwimWorkout? in
                guard let workout = sample as? HKWorkout else { return nil }
                return SwimWorkout(
                    id: workout.uuid,
                    name: "Swim Workout",
                    coach: nil, // Coach data may not persist in HealthKit
                    distance: workout.totalDistance?.doubleValue(for: .meter()) ?? 0,
                    duration: workout.duration,
                    strokes: [],
                    createdViaWorkoutKit: workout.metadata?["coach"] as? String == "WorkoutKit"
                )
            }
            completion(workouts, error)
        }
        healthStore.execute(query)
    }
}
