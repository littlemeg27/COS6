//
//  SegmentEditRow.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 8/20/25.
//

import SwiftUI

struct SegmentEditRow: View {
    @Binding var segment: WorkoutSegment
    let types: [String]
    let strokes: [String]
    let times: [TimeInterval]
    
    var body: some View {
        HStack {
            TextField("Yards", value: $segment.yards, formatter: NumberFormatter())
                .keyboardType(.numberPad)
                .frame(width: 80)
                .border(Color.gray)
            
            Menu {
                ForEach(types, id: \.self) { type in
                    Button(type) {
                        segment.type = type
                    }
                }
            } label: {
                Text(segment.type)
                    .frame(width: 100)
                    .border(Color.gray)
            }
            
            TextField("Amount", value: $segment.amount, formatter: NumberFormatter())
                .keyboardType(.numberPad)
                .frame(width: 80)
                .border(Color.gray)
            
            Menu {
                ForEach(strokes, id: \.self) { stroke in
                    Button(stroke) {
                        segment.stroke = stroke
                    }
                }
            } label: {
                Text(segment.stroke)
                    .frame(width: 120)
                    .border(Color.gray)
            }
            
            Menu {
                ForEach(times, id: \.self) { time in
                    Button("\(Int(time)) sec") {
                        segment.time = time
                    }
                }
            } label: {
                Text("\(Int(segment.time ?? 30)) sec")
                    .frame(width: 80)
                    .border(Color.gray)
            }
        }
        .padding()
    }
}
