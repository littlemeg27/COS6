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
                .listRowBackground(Color(hex: "#429EA6"))
                .foregroundStyle(Color(hex: "#153B50"))
            
            Text("Coach: \(workout.coach?.name ?? "None")")
                .listRowBackground(Color(hex: "#429EA6"))
                .foregroundStyle(Color(hex: "#153B50"))
            
            Text("Distance: \(String(format: "%.2f", workout.distance)) yards")
                .listRowBackground(Color(hex: "#429EA6"))
                .foregroundStyle(Color(hex: "#153B50"))
            
            Text("Duration: \(String(format: "%.2f", workout.duration / 60)) minutes")
                .listRowBackground(Color(hex: "#429EA6"))
                .foregroundStyle(Color(hex: "#153B50"))
            
            Section(header: Text("Warm Up"))
            {
                ForEach(workout.warmUp, id: \.id)
                {
                    segment in
                    SegmentRow(segment: segment)
                }
                .listRowBackground(Color(hex: "#429EA6"))
                .foregroundStyle(Color(hex: "#153B50"))
            }
            
            Section(header: Text("Main Set"))
            {
                ForEach(workout.mainSet, id: \.id)
                {
                    segment in
                    SegmentRow(segment: segment)
                }
                .listRowBackground(Color(hex: "#429EA6"))
                .foregroundStyle(Color(hex: "#153B50"))
            }
            
            Section(header: Text("Cool Down"))
            {
                ForEach(workout.coolDown, id: \.id)
                {
                    segment in
                    SegmentRow(segment: segment)
                }
                .listRowBackground(Color(hex: "#429EA6"))
                .foregroundStyle(Color(hex: "#153B50"))
            }
            
        }
        .listRowBackground(Color(hex: "#429EA6"))
        .navigationTitle(workout.name)
        .background(Color(hex: "#CC998D"))
        .foregroundStyle(Color(hex: "#153B50"))
        .scrollContentBackground(.hidden)
    }
}

struct SegmentRow: View
{
    let segment: WorkoutSegment
    
    var body: some View
    {
        Text("\(segment.amount ?? 1) x \(String(format: "%.2f", segment.yards ?? 0)) \(segment.stroke) \(segment.type)")
    }
}

#Preview
{
    WorkoutDetailView(workout: SwimWorkout(id: UUID(), name: "Sample Workout", coach: nil, warmUp: [], mainSet: [], coolDown: [], createdViaWorkoutKit: false, source: nil, date: Date()))
}
