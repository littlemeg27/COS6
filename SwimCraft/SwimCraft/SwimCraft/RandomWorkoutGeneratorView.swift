//
//  RandomWorkoutGeneratorView.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 9/5/25.
//

import SwiftUI

struct RandomWorkoutGeneratorView: View
{
    @Environment(\.dismiss) private var dismiss
    @State private var generatedWorkout: SwimWorkout?
    let onSave: (SwimWorkout) -> Void
    
    var body: some View
    {
        ZStack
        {
            LinearGradient(gradient: Gradient(colors: [Color(customHex: "#153B50"), Color(customHex: "#153B50")]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack()
            {
                Text("Generate Random Workout")
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color(customHex: "#16F4D0"))
                    .padding(.top, 50)
                    .padding(.bottom, 40)
                
                if let workout = generatedWorkout
                {
                    WorkoutDetailView(workout: workout)
                    
                    Button("Save Workout")
                    {
                        onSave(workout)
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 50)
                    .foregroundStyle(Color(customHex: "#153B50"))
                    .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#16F4D0"), Color(hex: "#55f7dc")]), startPoint: .leading, endPoint: .trailing))
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .padding()
                }
                else
                {
                    Text("Tap to generate a random swim workout")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                        .padding(.bottom, 40)
                }
                
                Button("Generate")
                {
                    generatedWorkout = createRandomWorkout()
                }
                .font(.system(size: 15, weight: .bold))
                .frame(maxWidth: .infinity)
                .frame(minHeight: 50)
                .foregroundStyle(Color(customHex: "#153B50"))
                .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#16F4D0"), Color(hex: "#55f7dc")]), startPoint: .leading, endPoint: .trailing))
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .padding()
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}

private func createRandomWorkout() -> SwimWorkout
{
    let segmentTypes = ["Drill", "Swim", "Kick", "Pull", "Sprint", "Easy", "Fins"]
    let strokeTypes = ["Freestyle", "Backstroke", "Breaststroke", "Butterfly", "Individual Medley", "Choice"]
    let yardOptions = [50.0, 100.0, 150.0, 200.0, 250.0, 300.0]
    let amountOptions = [1, 2, 3, 4]
    let timeOptions = [30.0, 45.0, 60.0, 90.0]
    
    func randomSegments(count: Int) -> [WorkoutSegment] {
        (0..<count).map { _ in
            WorkoutSegment(
                yards: yardOptions.randomElement() ?? 100.0,
                type: segmentTypes.randomElement() ?? "Swim",
                amount: amountOptions.randomElement() ?? 1,
                stroke: strokeTypes.randomElement() ?? "Freestyle",
                time: timeOptions.randomElement() ?? 60.0
            )
        }
    }
    
    return SwimWorkout(
        id: UUID(),
        name: "Random Workout \(Date().formatted(date: .abbreviated, time: .omitted))",
        coach: nil, // Or random coach if available
        warmUp: randomSegments(count: Int.random(in: 2...4)),
        mainSet: randomSegments(count: Int.random(in: 4...6)),
        coolDown: randomSegments(count: Int.random(in: 2...3)),
        createdViaWorkoutKit: false,
        source: "Random Generator",
        date: Date()
    )
}

#Preview
{
    RandomWorkoutGeneratorView { _ in }
}
