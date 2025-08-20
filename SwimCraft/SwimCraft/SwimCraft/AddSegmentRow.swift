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
            .font(.system(size: 16, weight: .bold))
            .frame(maxWidth: .infinity)
            .foregroundColor(Color(hex: "#293241"))
            .background(Color(hex: "#98C1D9"))
            .accessibilityLabel("Add")
            .accessibilityHint("Tap to add a new workout segment")
            .contentShape(Rectangle()) // Make the entire row tappable
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
