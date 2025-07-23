//
//  SwimWorkoutManager.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 7/17/25.
//


import Foundation

class SwimWorkoutManager
{
    static let shared = SwimWorkoutManager()
    
    func createSwimWorkout(name: String, distance: Double, duration: TimeInterval, strokes: [String], completion: @escaping (SwimWorkout?, Error?) -> Void)
    {
        let workout = SwimWorkout(
            id: UUID(),
            name: name,
            coach: nil,
            warmUp: [],
            mainSet: [WorkoutSegment(yards: distance, type: "Swim", amount: 1, stroke: strokes.first ?? "Freestyle", time: duration)],
            coolDown: [],
            createdViaWorkoutKit: true,
            source: "WorkoutKit"
        )
        completion(workout, nil)
    }
}
