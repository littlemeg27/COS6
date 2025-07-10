//
//  Swim Workout Model.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 7/9/25.
//

import Foundation

struct SwimWorkout
{
    let id: UUID
    let name: String
    let coach: Coach?
    let distance: Double
    let duration: TimeInterval
    let strokes: [String] 
    let createdViaWorkoutKit: Bool
}
