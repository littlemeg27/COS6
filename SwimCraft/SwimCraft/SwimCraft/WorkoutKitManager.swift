//
//  WorkoutKitManager.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 7/11/25.
//

import WorkoutKit
import Foundation

struct WorkoutKitManager {
    static let shared = WorkoutKitManager()
    
    func createWorkoutKitSwimWorkout(name: String, distance: Double, strokes: [String]) -> CustomWorkout {
        let distanceStep = WorkoutStep(
            activity: .swimming,
            goal: .distance(distance, unit: .meters)
        )
        
        let workout = CustomWorkout(
            activity: .swimming,
            location: .indoor,
            displayName: name,
            intervals: [distanceStep]
        )
        
        return workout
    }
    
    func saveWorkoutKitWorkout(workout: CustomWorkout, completion: @escaping (SwimWorkout?, Error?) -> Void) {
        Task {
            do {
                let plan = WorkoutPlan.single(workout)
                try await WorkoutScheduler.shared.schedule(plan, at: nil)
                
                let swimWorkout = SwimWorkout(
                    id: UUID(),
                    name: workout.displayName,
                    coach: nil, // No coach for WorkoutKit
                    distance: workout.intervals
                        .compactMap { $0.goal as? WorkoutStepGoal.Distance }
                        .first?.value ?? 0,
                    duration: 0,
                    strokes: [], // Strokes not directly supported
                    createdViaWorkoutKit: true
                )
                
                HealthKitManager.shared.saveWorkout(swimWorkout) { success, error in
                    if success {
                        completion(swimWorkout, nil)
                    } else {
                        completion(nil, error)
                    }
                }
            } catch {
                print("Error scheduling workout: \(error)")
                completion(nil, error)
            }
        }
    }
}
