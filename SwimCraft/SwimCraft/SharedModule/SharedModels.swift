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
    let distance: Double
    let duration: TimeInterval
    let strokes: [String]
    let createdViaWorkoutKit: Bool
    let source: String?
}
