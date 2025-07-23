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
    let dateCompleted: Date
    let clubAbbr: String
    let clubName: String
    let lmsc: String
}

struct WorkoutSegment
{
    let yards: Double
    let type: String
    let amount: Int
    let stroke: String
    let time: TimeInterval
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
        let warmUpDistance = warmUp.reduce(0.0) { $0 + $1.yards * Double($1.amount) }
        let mainSetDistance = mainSet.reduce(0.0) { $0 + $1.yards * Double($1.amount) }
        let coolDownDistance = coolDown.reduce(0.0) { $0 + $1.yards * Double($1.amount) }
        return warmUpDistance + mainSetDistance + coolDownDistance
    }
    
    var duration: TimeInterval
    {
        let warmUpDuration = warmUp.reduce(0.0) { $0 + $1.time * Double($1.amount) }
        let mainSetDuration = mainSet.reduce(0.0) { $0 + $1.time * Double($1.amount) }
        let coolDownDuration = coolDown.reduce(0.0) { $0 + $1.time * Double($1.amount) }
        return warmUpDuration + mainSetDuration + coolDownDuration
    }
    
    var strokes: [String]
    {
        Array(Set(warmUp.map { $0.stroke } + mainSet.map { $0.stroke } + coolDown.map { $0.stroke }))
    }
}
