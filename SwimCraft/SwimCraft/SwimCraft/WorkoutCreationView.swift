//
//  WorkoutCreationView.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 8/20/25.
//


import SwiftUI

struct WorkoutCreationView: View {
    @State private var name: String = ""
    @State private var selectedCoach: Coach?
    @State private var coaches: [Coach] = []
    @State private var warmUpSegments: [WorkoutSegment] = [WorkoutSegment(yards: 0, type: "Drill", amount: 1, stroke: "Freestyle", time: 30)]
    @State private var mainSetSegments: [WorkoutSegment] = [WorkoutSegment(yards: 0, type: "Drill", amount: 1, stroke: "Freestyle", time: 30)]
    @State private var coolDownSegments: [WorkoutSegment] = [WorkoutSegment(yards: 0, type: "Drill", amount: 1, stroke: "Freestyle", time: 30)]
    let segmentTypes = ["Drill", "Swim", "Kick", "Pull", "Sprint", "Easy", "Fins"]
    let strokeTypes = ["Freestyle", "Backstroke", "Breaststroke", "Butterfly", "Individual Medley", "Not Free Style", "Choice"]
    let timeOptions: [TimeInterval] = [30, 60, 90, 120, 180]
    
    var onSave: (SwimWorkout) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Workout Name", text: $name)
                
                Picker("Coach", selection: $selectedCoach) {
                    ForEach(coaches, id: \.self) { coach in
                        Text("\(coach.name) (\(coach.level))").tag(coach as Coach?)
                    }
                }
                
                Section(header: Text("Warm Up")) {
                    ForEach($warmUpSegments) { $segment in
                        SegmentEditRow(segment: $segment, types: segmentTypes, strokes: strokeTypes, times: timeOptions)
                    }
                    Button(action: {
                        warmUpSegments.append(WorkoutSegment(yards: 0, type: segmentTypes[0], amount: 1, stroke: strokeTypes[0], time: timeOptions[0]))
                    }) {
                        AddSegmentRow()
                    }
                }
                
                Section(header: Text("Main Set")) {
                    ForEach($mainSetSegments) { $segment in
                        SegmentEditRow(segment: $segment, types: segmentTypes, strokes: strokeTypes, times: timeOptions)
                    }
                    Button(action: {
                        mainSetSegments.append(WorkoutSegment(yards: 0, type: segmentTypes[0], amount: 1, stroke: strokeTypes[0], time: timeOptions[0]))
                    }) {
                        AddSegmentRow()
                    }
                }
                
                Section(header: Text("Cool Down")) {
                    ForEach($coolDownSegments) { $segment in
                        SegmentEditRow(segment: $segment, types: segmentTypes, strokes: strokeTypes, times: timeOptions)
                    }
                    Button(action: {
                        coolDownSegments.append(WorkoutSegment(yards: 0, type: segmentTypes[0], amount: 1, stroke: strokeTypes[0], time: timeOptions[0]))
                    }) {
                        AddSegmentRow()
                    }
                }
            }
            .navigationTitle("Create Workout")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let workout = SwimWorkout(
                            id: UUID(),
                            name: name,
                            coach: selectedCoach,
                            warmUp: warmUpSegments,
                            mainSet: mainSetSegments,
                            coolDown: coolDownSegments,
                            createdViaWorkoutKit: false,
                            source: nil,
                            date: Date()
                        )
                        onSave(workout)
                    }
                    .disabled(name.isEmpty || warmUpSegments.allSatisfy { $0.yards == 0 } && mainSetSegments.allSatisfy { $0.yards == 0 } && coolDownSegments.allSatisfy { $0.yards == 0 })
                }
            }
            .onAppear {
                loadCoaches()
            }
        }
    }
    
    private func loadCoaches() {
        // Your existing loadCoaches logic, adapted to SwiftUI
        do {
            coaches = try loadCoaches(from: "CertifiedCoaches")
            selectedCoach = coaches.first
        } catch {
            coaches = [Coach(name: "Default Coach", level: "Level 1", dateCompleted: Date(), clubAbbr: "", clubName: "", lmsc: "")]
            selectedCoach = coaches.first
        }
    }
    
    // Your loadCoaches function here, moved from UIKit version
    private func loadCoaches(from resource: String) throws -> [Coach] {
        // Existing code...
    }
}

#Preview {
    WorkoutCreationView { _ in }
}
