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
        ZStack
        {
            LinearGradient(gradient: Gradient(colors: [Color(customHex: "#153B50"), Color(customHex: "#429EA6").opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            ScrollView
            {
                VStack(spacing: 16)
                {
                    VStack(alignment: .leading, spacing: 12)
                    {
                        Text(workout.name)
                            .font(.largeTitle.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Coach: \(workout.coach?.name ?? "None")")
                            .font(.title3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        HStack
                        {
                            Text("Distance: \(String(format: "%.2f", workout.distance)) yards")
                                .font(.subheadline)
                            Spacer()
                            Text("Duration: \(String(format: "%.2f", workout.duration / 60)) minutes")
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                    .background(Color(customHex: "#ECEBE4"))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.black.opacity(0.1), radius: 5)

                    Text("Warm Up")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .leading, spacing: 8)
                    {
                        ForEach(workout.warmUp, id: \.id)
                        {
                            segment in
                            SegmentRow(segment: segment)
                        }
                    }
                    .padding()
                    .background(Color(customHex: "#ECEBE4"))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.black.opacity(0.1), radius: 5)

                    Text("Main Set")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .leading, spacing: 8)
                    {
                        ForEach(workout.mainSet, id: \.id)
                        {
                            segment in
                            SegmentRow(segment: segment)
                        }
                    }
                    .padding()
                    .background(Color(customHex: "#ECEBE4"))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.black.opacity(0.1), radius: 5)

                    Text("Cool Down")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .leading, spacing: 8)
                    {
                        ForEach(workout.coolDown, id: \.id)
                        {
                            segment in
                            SegmentRow(segment: segment)
                        }
                    }
                    .padding()
                    .background(Color(customHex: "#ECEBE4"))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.black.opacity(0.1), radius: 5)
                }
                .padding()
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
        .foregroundStyle(Color(customHex: "#153B50"))
    }
}

struct SegmentRow: View
{
    let segment: WorkoutSegment
    
    var body: some View
    {
        Text("\(segment.amount ?? 1) x \(String(format: "%.2f", segment.yards ?? 0)) \(segment.stroke) \(segment.type)")
            .font(.body)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 4)
    }
}

#Preview {
    WorkoutDetailView(workout: SwimWorkout(id: UUID(), name: "Sample Workout", coach: nil, warmUp: [], mainSet: [], coolDown: [], createdViaWorkoutKit: false, source: nil, date: Date()))
}
