//
//  SharedModels.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 7/13/25.
//

import Foundation

  struct Coach: Codable
{
      let name: String
      let level: String
      let dateCompleted: Date
      let clubAbbr: String
      let clubName: String
      let lmsc: String
  }

  struct WorkoutSegment: Codable
{
      let yards: Double
      let type: String
      let amount: Int
      let stroke: String
      let time: TimeInterval
  }

  struct SwimWorkout: Codable
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
