//
//  CreateWorkoutKitSwimWorkout.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 7/9/25.
//

import WorkoutKit

func createWorkoutKitSwimWorkout(name: String, distance: Double, strokes: [String]) -> CustomWorkout
{
    let swimActivity = WorkoutActivity(.swimming)
    let distanceGoal = WorkoutGoal.distance(.meters(distance))
    let workout = CustomWorkout(activity: swimActivity, location: .pool, displayName: name, goal: distanceGoal)
    return workout
}

func saveWorkoutKitWorkout(workout: CustomWorkout)
{
    Task
    {
        do
        {
            try await WorkoutScheduler.shared.schedule(workout: workout)
            let swimWorkout = SwimWorkout(
                id: UUID(),
                name: workout.displayName,
                coach: nil,
                distance: (workout.goal as? WorkoutGoal.Distance)?.value ?? 0,
                duration: 0,
                strokes: [],
                createdViaWorkoutKit: true
            )
        }
        catch
        {
            print("Error scheduling workout: \(error)")
        }
    }
}
