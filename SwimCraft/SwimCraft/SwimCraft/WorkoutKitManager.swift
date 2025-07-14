//
//  WorkoutKitManager.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 7/11/25.
//

import WorkoutKit
import Foundation

struct WorkoutKitManager
{
    static let shared = WorkoutKitManager()

    func createWorkoutKitSwimWorkout(name: String, distance: Double, strokes: [String]) -> CustomWorkout
    {
        let distanceGoal = WorkoutGoal.distance(.init(value: distance, unit: .meters))
        let step = CustomWorkoutStep(goal: distanceGoal)
        let workout = CustomWorkout(
            displayName: name,
            activity: .swimming,
            location: .indoor,
            steps: [step]
        )
        return workout
    }

    func saveWorkoutKitWorkout(workout: CustomWorkout, strokes: [String], completion: @escaping (SwimWorkout?, Error?) -> Void)
    {
        Task
        {
            do
            {
                let plan = WorkoutPlan(workout: workout)
                try await WorkoutScheduler.shared.schedule(plan: plan, at: Date())
                let swimWorkout = SwimWorkout(
                    id: UUID(),
                    name: workout.displayName,
                    coach: nil,
                    distance: workout.steps
                        .compactMap { $0.goal as? WorkoutGoal.Distance }
                        .first?.value ?? 0,
                    duration: 0,
                    strokes: strokes,
                    createdViaWorkoutKit: true,
                    source: nil
                )
                HealthKitManager.shared.saveWorkout(swimWorkout) { success, error in
                    if success
                    {
                        completion(swimWorkout, nil)
                    }
                    else
                    {
                        completion(nil, error)
                    }
                }
            }
            catch
            {
                print("Error scheduling workout: \(error)")
                completion(nil, error)
            }
        }
    }
}
