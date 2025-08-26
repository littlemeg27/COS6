//
//  WorkoutDetailView.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 8/20/25.
//

import SwiftUI

struct WorkoutDetailView: View
{
    let workout: SwimWorkout
    
    var body: some View
    {
        List
        {
            Text("Name: \(workout.name)")
            Text("Coach: \(workout.coach?.name ?? "None")")
            Text("Distance: \(workout.distance) yards")
            Text("Duration: \(Int(workout.duration / 60)) minutes")
            
            Section(header: Text("Warm Up"))
            {
                ForEach(workout.warmUp, id: \.id)
                {
                    segment in
                    SegmentRow(segment: segment)
                }
            }
            .foregroundStyle(Color(hex: "#902D41"))
            
            Section(header: Text("Main Set"))
            {
                ForEach(workout.mainSet, id: \.id)
                {
                    segment in
                    SegmentRow(segment: segment)
                }
            }
            .foregroundStyle(Color(hex: "#902D41"))
            
            Section(header: Text("Cool Down"))
            {
                ForEach(workout.coolDown, id: \.id)
                {
                    segment in
                    SegmentRow(segment: segment)
                }
            }
            .foregroundStyle(Color(hex: "#902D41"))
        }
        .listRowBackground(Color(hex: "#004FFF"))
        .navigationTitle(workout.name)
        .background(Color(hex: "#31AFD4"))
        .scrollContentBackground(.hidden)
    }
}

struct SegmentRow: View
{
    let segment: WorkoutSegment
    
    var body: some View
    {
        Text("\(segment.amount ?? 1) x \(segment.yards ?? 0) \(segment.stroke) \(segment.type)")
    }
}

#Preview
{
    WorkoutDetailView(workout: SwimWorkout(id: UUID(), name: "Sample Workout", coach: nil, warmUp: [], mainSet: [], coolDown: [], createdViaWorkoutKit: false, source: nil, date: Date()))
}

