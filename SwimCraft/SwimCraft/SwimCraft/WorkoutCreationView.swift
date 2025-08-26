//
//  WorkoutCreationView.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 8/20/25.
//

import SwiftUI

struct WorkoutCreationView: View
{
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var selectedCoach: Coach?
    @State private var coaches: [Coach] = []
    @State private var warmUpSegments: [WorkoutSegment] = [WorkoutSegment(yards: 0, type: "Drill", amount: 1, stroke: "Freestyle", time: 30)]
    @State private var mainSetSegments: [WorkoutSegment] = [WorkoutSegment(yards: 0, type: "Drill", amount: 1, stroke: "Freestyle", time: 30)]
    @State private var coolDownSegments: [WorkoutSegment] = [WorkoutSegment(yards: 0, type: "Drill", amount: 1, stroke: "Freestyle", time: 30)]
    let segmentTypes = ["Drill", "Swim", "Kick", "Pull", "Sprint", "Easy", "Fins"]
    let strokeTypes = ["Freestyle", "Backstroke", "Breaststroke", "Butterfly", "Individual Medley", "Not Free Style", "Choice"]
    let timeOptions: [TimeInterval] = [10,20, 30, 60, 90, 120, 180]
    
    var onSave: (SwimWorkout) -> Void
    
    var body: some View
    {
        NavigationStack
        {
            Form
            {
                TextField("Workout Name", text: $name)
                    .multilineTextAlignment(.center)
                
                Picker("Coach", selection: $selectedCoach)
                {
                    ForEach(coaches, id: \.self)
                    {
                        coach in
                        Text("\(coach.name) (\(coach.level))").tag(coach as Coach?)
                    }
                }
                
                Section(header: Text("Warm Up"))
                {
                    ForEach($warmUpSegments)
                    {
                        $segment in
                        SegmentEditRow(segment: $segment, types: segmentTypes, strokes: strokeTypes, times: timeOptions)
                    }
                    Button(action:
                            {
                        warmUpSegments.append(WorkoutSegment(yards: 0, type: segmentTypes[0], amount: 1, stroke: strokeTypes[0], time: timeOptions[0]))
                    })
                    {
                        AddSegmentRow()
                    }
                }
                .foregroundStyle(Color(hex: "#902D41"))
                
                Section(header: Text("Main Set"))
                {
                    ForEach($mainSetSegments)
                    {
                        $segment in
                        SegmentEditRow(segment: $segment, types: segmentTypes, strokes: strokeTypes, times: timeOptions)
                    }
                    Button(action:
                            {
                        mainSetSegments.append(WorkoutSegment(yards: 0, type: segmentTypes[0], amount: 1, stroke: strokeTypes[0], time: timeOptions[0]))
                    })
                    {
                        AddSegmentRow()
                    }
                }
                .foregroundStyle(Color(hex: "#902D41"))
                
                Section(header: Text("Cool Down"))
                {
                    ForEach($coolDownSegments)
                    {
                        $segment in
                        SegmentEditRow(segment: $segment, types: segmentTypes, strokes: strokeTypes, times: timeOptions)
                    }
                    Button(action:
                            {
                        coolDownSegments.append(WorkoutSegment(yards: 0, type: segmentTypes[0], amount: 1, stroke: strokeTypes[0], time: timeOptions[0]))
                    })
                    {
                        AddSegmentRow()
                    }
                }
                .foregroundStyle(Color(hex: "#902D41"))
            }
            .navigationTitle("Create Workout")
            .toolbar
            {
                ToolbarItem(placement: .topBarTrailing)
                {
                    Button("Save")
                    {
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
                        dismiss()
                    }
                    .disabled(name.isEmpty || warmUpSegments.allSatisfy { $0.yards == 0 } && mainSetSegments.allSatisfy { $0.yards == 0 } && coolDownSegments.allSatisfy { $0.yards == 0 })
                    .foregroundStyle(Color(hex: "#902D41"))
                
                }
            }
            .onAppear
            {
                loadCoaches()
            }
            .listSectionSpacing(4)
            .environment(\.defaultMinListRowHeight, 30)
            .scrollContentBackground(.hidden)
            .background(Color(hex: "#31AFD4"))
        }
    }
    
    private func loadCoaches()
    {
        do
        {
            coaches = try loadCoaches(from: "CertifiedCoaches")
            selectedCoach = coaches.first
        }
        catch
        {
            coaches = [Coach(name: "Default Coach", level: "Level 1", dateCompleted: Date(), clubAbbr: "", clubName: "", lmsc: "")]
            selectedCoach = coaches.first
        }
    }
    
    private func loadCoaches(from resource: String) throws -> [Coach]
    {
        guard let url = Bundle.main.url(forResource: resource, withExtension: "csv") else
        {
            print("Error: Could not find \(resource).csv in bundle")
            throw NSError(domain: "SwimCraft", code: -1, userInfo: [NSLocalizedDescriptionKey: "Coach resource not found"])
        }
        
        print("loadCoaches: Found file at \(url)")
        
        let data = try String(contentsOf: url, encoding: .utf8)
        
        print("loadCoaches: Loaded \(data.count) characters of data")
        
        var coaches: [Coach] = []
        let rows = data.components(separatedBy: .newlines).filter { !$0.isEmpty }
        
        guard !rows.isEmpty else
        {
            print("Error: CSV file is empty")
            throw NSError(domain: "SwimCraft", code: -2, userInfo: [NSLocalizedDescriptionKey: "CSV file is empty"])
        }
        let expectedHeader = ["Coach", "Level", "Date Completed", "Club Abbr", "Club Name", "LMSC"]
        let header = rows[0].components(separatedBy: ",")
        
        guard header == expectedHeader else
        {
            print("Error: Invalid CSV header: \(header)")
            throw NSError(domain: "SwimCraft", code: -3, userInfo: [NSLocalizedDescriptionKey: "Invalid CSV header"])
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for row in rows.dropFirst()
        {
            let columns = row.components(separatedBy: ",")
            guard columns.count == 6 else
            {
                print("Warning: Skipping invalid row: \(row)")
                continue
            }
            
            let name = columns[0].trimmingCharacters(in: .whitespaces)
            let level = columns[1].trimmingCharacters(in: .whitespaces)
            let dateString = columns[2].trimmingCharacters(in: .whitespaces)
            let clubAbbr = columns[3].trimmingCharacters(in: .whitespaces)
            let clubName = columns[4].trimmingCharacters(in: .whitespaces)
            let lmsc = columns[5].trimmingCharacters(in: .whitespaces)
            guard !name.isEmpty, !level.isEmpty, let date = dateFormatter.date(from: dateString) else
            {
                print("Warning: Skipping invalid coach data: \(row)")
                continue
            }
            let coach = Coach(name: name, level: level, dateCompleted: date, clubAbbr: clubAbbr, clubName: clubName, lmsc: lmsc)
            coaches.append(coach)
        }
        print("loadCoaches: Parsed \(coaches.count) coaches")
        return coaches
    }
}

#Preview
{
    WorkoutCreationView { _ in }
}
