//
//  SwimWorkoutManager.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 7/17/25.
//


import Foundation

   struct SwimWorkoutManager
{
       static let shared = SwimWorkoutManager()

       func createSwimWorkout(name: String, distance: Double, duration: TimeInterval, strokes: [String], completion: @escaping (SwimWorkout?, Error?) -> Void)
       {
           let swimWorkout = SwimWorkout(
               id: UUID(),
               name: name,
               coach: nil,
               warmUp: [WorkoutSegment(yards: distance, type: "Swim", amount: 1, stroke: strokes.first ?? "Freestyle", time: duration)],
               mainSet: [],
               coolDown: [],
               createdViaWorkoutKit: false,
               source: nil
           )

           HealthKitManager.shared.saveWorkout(swimWorkout)
           {
               success, error in
               
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
   }
   
