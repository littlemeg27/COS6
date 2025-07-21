//
//  SharedModels.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 7/13/25.
//

import Foundation

struct Coach
{
    let name: String
    let level: String
    let dateCompleted: String
    let clubAbbr: String
    let clubName: String
    let lmsc: String
}

struct SwimWorkout
{
    let id: UUID
    let name: String
    let coach: Coach?
    let warmUp: [WorkoutSegment]
    let mainSet: [WorkoutSegment]
    let coolDown: [WorkoutSegment]
    let createdViaWorkoutKit: Bool
    let source: String?
    
    var distance: Double
    {
        (warmUp + mainSet + coolDown).reduce(0) { $0 + $1.yards }
    }
    
    var duration: TimeInterval
    {
        (warmUp + mainSet + coolDown).reduce(0) { $0 + $1.time * Double($1.amount) }
    }
    
    var strokes: [String]
    {
        Array(Set((warmUp + mainSet + coolDown).map { $0.stroke }))
    }
}

struct WorkoutSegment
{
    let yards: Double
    let type: String // Drill, Swim, Kick
    let amount: Int // number of reps
    let stroke: String // Freestyle, Backstroke
    let time: TimeInterval // interval time in seconds
}
