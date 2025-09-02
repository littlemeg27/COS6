//
//  SegmentEditRow.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 8/20/25.
//

import SwiftUI

struct SegmentEditRow: View
{
    @Binding var segment: WorkoutSegment
    let types: [String]
    let strokes: [String]
    let times: [TimeInterval]
    
    
    var body: some View
    {
        HStack
        {
            TextField("Yards", value: $segment.yards, formatter: NumberFormatter()) // Text for Yards
                .keyboardType(.numberPad)
                .frame(width: 50, height: 25)
                .border(Color(hex: "#ECEBE4"))
                .multilineTextAlignment(.center)
            
            Menu //Menu for Type
            {
                ForEach(types, id: \.self)
                {
                    type in
                    Button(type)
                    {
                        segment.type = type
                    }
                }
            }
            label: //Menu for Strokes
            {
                Text(segment.type)
                    .frame(width: 60)
                    .border(Color(hex: "#ECEBE4"))
            }
            
            TextField("Amount", value: $segment.amount, formatter: NumberFormatter()) // Text for Amount
                .keyboardType(.numberPad)
                .frame(width: 50, height: 25)
                .border(Color(hex: "#ECEBE4"))
                .multilineTextAlignment(.center)
            
            Menu //Menu for Strokes
            {
                ForEach(strokes, id: \.self)
                {
                    stroke in
                    Button(stroke)
                    {
                        segment.stroke = stroke
                    }
                }
            }
        label:
            {
                Text(segment.stroke)
                    .frame(width: 100)
                    .border(Color(hex: "#ECEBE4"))
            }
            
            Menu //Menu for Time
            {
                ForEach(times, id: \.self)
                {
                    time in
                    Button("\(Int(time)) sec")
                    {
                        segment.time = time
                    }
                }
            }
        label:
            {
                Text("\(Int(segment.time ?? 30)) sec")
                    .frame(width: 80)
                    .border(Color(hex: "#ECEBE4"))
            }
        }
        .padding()
        .frame(height: 25)
    }
}
