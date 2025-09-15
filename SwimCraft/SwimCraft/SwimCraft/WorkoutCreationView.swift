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
    let timeOptions: [TimeInterval] = [5, 10, 15, 20,25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100, 105, 110, 120, 125, 130, 135, 140, 145, 150, 155, 160, 165, 170, 175, 180]
    
    var onSave: (SwimWorkout) -> Void
    
    var body: some View
    {
        NavigationStack
        {
            ZStack
            {
                LinearGradient(gradient: Gradient(colors: [Color(customHex: "#153B50"), Color(customHex: "#153B50")]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                    .foregroundColor(Color(hex: "#16F4D0"))
                
                Form
                {
                    VStack
                    {
                        TextField("Workout Name", text: $name)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(Color(customHex: "#429EA6"))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.black.opacity(0.1), radius: 5)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    
                    VStack
                    {
                        Picker("Coach", selection: $selectedCoach)
                        {
                            ForEach(coaches, id: \.self)
                            {
                                coach in
                                Text("\(coach.name) (\(coach.level))").tag(coach as Coach?)
                            }
                        }
                    }
                    .padding()
                    .background(Color(customHex: "#429EA6"))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.black.opacity(0.1), radius: 5)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    
                    Section(header: Text("Warm Up").font(.title2.bold()))
                    {
                        ForEach($warmUpSegments)
                        {
                            $segment in
                            SegmentEditRow(segment: $segment, types: segmentTypes, strokes: strokeTypes, times: timeOptions)
                                .padding(.vertical, 7)
                                .background(Color(customHex: "#ECEBE4"))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: Color.black.opacity(0.1), radius: 5)
                        }
                        Button(action:
                                {
                            warmUpSegments.append(WorkoutSegment(yards: 0, type: segmentTypes[0], amount: 1, stroke: strokeTypes[0], time: timeOptions[0]))
                        })
                        {
                            AddSegmentRow()
                        }
                        .padding()
                        .background(Color(customHex: "#ECEBE4"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: Color.black.opacity(0.05), radius: 3)
                    }
                    .listRowBackground(Color.clear)
                    
                    Section(header: Text("Main Set").font(.title2.bold()))
                    {
                        ForEach($mainSetSegments)
                        {
                            $segment in
                            SegmentEditRow(segment: $segment, types: segmentTypes, strokes: strokeTypes, times: timeOptions)
                                .padding(.vertical, 7)
                                .background(Color(customHex: "#ECEBE4"))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: Color.black.opacity(0.05), radius: 3)
                        }
                        Button(action:
                                {
                            mainSetSegments.append(WorkoutSegment(yards: 0, type: segmentTypes[0], amount: 1, stroke: strokeTypes[0], time: timeOptions[0]))
                        })
                        {
                            AddSegmentRow()
                        }
                        .padding()
                        .background(Color(customHex: "#ECEBE4"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: Color.black.opacity(0.05), radius: 3)
                    }
                    .listRowBackground(Color.clear)
                    
                    Section(header: Text("Cool Down").font(.title2.bold()))
                    {
                        ForEach($coolDownSegments)
                        {
                            $segment in
                            SegmentEditRow(segment: $segment, types: segmentTypes, strokes: strokeTypes, times: timeOptions)
                                .padding(.vertical, 7)
                                .background(Color(customHex: "#ECEBE4"))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: Color.black.opacity(0.05), radius: 3)
                        }
                        Button(action:
                                {
                            coolDownSegments.append(WorkoutSegment(yards: 0, type: segmentTypes[0], amount: 1, stroke: strokeTypes[0], time: timeOptions[0]))
                        })
                        {
                            AddSegmentRow()
                        }
                        .padding()
                        .background(Color(customHex: "#ECEBE4"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: Color.black.opacity(0.05), radius: 3)
                    }
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .toolbar
                {
                    ToolbarItem(placement: .principal)
                    {
                        Text("Create Workout")
                            .padding(.top, 60)
                            .font(.largeTitle.bold())
                            .foregroundStyle(Color(customHex: "#16F4D0"))
                            .shadow(radius: 2)
                    }
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
                        .foregroundStyle(Color(customHex: "#16F4D0"))
                    }
                }
                .onAppear
                {
                    loadCoaches()
                }
                .listSectionSpacing(3)
                .environment(\.defaultMinListRowHeight, 30)
            }
            .foregroundStyle(Color(customHex: "#16F4D0"))
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
