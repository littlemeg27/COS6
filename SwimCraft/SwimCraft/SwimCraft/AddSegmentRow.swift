//
//  AddSegmentRow.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 8/20/25.
//

import SwiftUI

struct AddSegmentRow: View
{
    var body: some View
    {
        Text("Add")
            .font(.system(size: 15, weight: .bold)) // Increased font size for bigger button
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12) // Added vertical padding to make the button taller
            .foregroundColor(Color(hex: "#153B50")) // Dark text for contrast on gradient
            .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#16F4D0"), Color(hex: "#429EA6")]), startPoint: .leading, endPoint: .trailing))
            .clipShape(Capsule()) // Pill shape like WorkoutListView buttons
            .shadow(radius: 2) // Subtle shadow for depth
            .accessibilityLabel("Add")
            .accessibilityHint("Tap to add a new workout segment")
            .contentShape(Rectangle())
    }
}

extension Color
{
    init(hex: String)
    {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var rgb: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgb)
        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue)
    }
}
