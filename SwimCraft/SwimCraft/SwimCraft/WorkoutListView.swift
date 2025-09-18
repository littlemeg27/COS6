//
//  WorkoutListView.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 8/20/25.
//


import SwiftUI
import CoreData
import UIKit

extension Color
{
    init(customHex: String)
    {
        let scanner = Scanner(string: customHex)
        _ = scanner.scanString("#")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

struct WorkoutListView: View
{
    @Environment(\.managedObjectContext) private var context
    @State private var workouts: [SwimWorkout] = []
    @State private var showingCreation: Bool = false
    
    var body: some View
    {
        NavigationStack
        {
            ZStack
            {
                LinearGradient(gradient: Gradient(colors: [Color(customHex: "#153B50"), Color(customHex: "#153B50")]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                List
                {
                    ForEach(workouts)
                    {
                        workout in
                        WorkoutRow(workout: workout)
                            .padding(.vertical, 4)
                    }
                    .onDelete
                    {
                        indices in
                        deleteWorkouts(at: indices)
                    }
                }
                .listStyle(.plain)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .scrollContentBackground(.hidden)
                .tint(Color(customHex: "#153B50"))
                .toolbar
                {
                    ToolbarItem(placement: .principal)
                    {
                        Text("Workouts")
                            .font(.largeTitle.bold())
                            .foregroundStyle(Color(customHex: "#16F4D0"))
                            .shadow(radius: 2)
                    }
                    ToolbarItem(placement: .topBarTrailing)
                    {
                        Button(action: { showingCreation = true })
                        {
                            Label("Add Workout", systemImage: "plus.circle.fill")
                                .imageScale(.large)
                                .font(.headline)
                                .foregroundStyle(.black, Color(customHex: "#16F4D0"))
                                .background(LinearGradient(gradient: Gradient(colors: [Color(customHex: "#429EA6"), Color(customHex: "#429EA6")]), startPoint: .leading, endPoint: .trailing))
                                .clipShape(Capsule())
                                .shadow(radius: 2)
                                .imageScale(.large)
                        }
                    }
                    ToolbarItem(placement: .topBarLeading)
                    {
                        Button(action: { deleteAllWorkouts() })
                        {
                            Label("Clear All", systemImage: "trash.circle.fill")
                                .imageScale(.large)
                                .font(.headline)
                                .foregroundStyle(.black, Color(customHex: "#16F4D0"))
                                .background(LinearGradient(gradient: Gradient(colors: [Color(customHex: "#429EA6"), Color(customHex: "#429EA6")]), startPoint: .leading, endPoint: .trailing))
                                .clipShape(Capsule())
                                .shadow(radius: 2)
                                
                        }
                    }
                }
                .sheet(isPresented: $showingCreation)
                {
                    WorkoutCreationView
                    {
                        newWorkout in
                        saveWorkout(newWorkout)
                        fetchWorkouts()
                    }
                }
                .onAppear
                {
                    fetchWorkouts()
                }
            }
            .foregroundStyle(Color(customHex: "#429EA6"))
        }
    }
    
    struct WorkoutRow: View
    {
        let workout: SwimWorkout
        
        var body: some View
        {
            NavigationLink(destination: WorkoutDetailView(workout: workout))
            {
                VStack(alignment: .leading, spacing: 8)
                {
                    Text(workout.name)
                        .font(.headline.bold())
                        .foregroundStyle(Color(customHex: "#153B50"))
                    HStack
                    {
                        Text("Distance: \(String(format: "%.0f", workout.distance)) yards")
                            .font(.subheadline)
                            .foregroundStyle(Color(customHex: "#153B50"))
                        Spacer()
                        Text("Created: \(workout.date.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundStyle(Color(customHex: "#153B50")) 
                    }
                }
                .padding()
                .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#ECEBE4"), Color(hex: "#D9D9D9")]), startPoint: .leading, endPoint: .trailing))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
            .swipeActions(edge: .trailing)
            {
                if let pdfURL = WorkoutListView.generatePDF(for: workout)
                {
                    ShareLink(item: pdfURL, subject: Text(workout.name), message: Text("Check out this workout!"))
                    {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    .tint(Color(customHex: "#153B50"))
                }
            }
        }
    }
    
    static private func generatePDF(for workout: SwimWorkout) -> URL?
    {
        let pageWidth = 612.0
        let pageHeight = 792.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let fullText = """
        Workout Name: \(workout.name)
        Coach: \(workout.coach?.name ?? "None")
        Distance: \(workout.distance) yards
        Duration: \(Int(workout.duration / 60)) minutes
        Date: \(workout.date.formatted(date: .abbreviated, time: .omitted))
        
        Warm Up:
        \(workout.warmUp.map
        {
            segment in
            "\(segment.amount ?? 1) x \(segment.yards ?? 0) \(segment.stroke) \(segment.type) on \(Int(segment.time ?? 0)) sec"
        }.joined(separator: "\n"))
        
        Main Set:
        \(workout.mainSet.map
        {
            segment in
            "\(segment.amount ?? 1) x \(segment.yards ?? 0) \(segment.stroke) \(segment.type) on \(Int(segment.time ?? 0)) sec"
        }.joined(separator: "\n"))
        
        Cool Down:
        \(workout.coolDown.map
        {
            segment in
            "\(segment.amount ?? 1) x \(segment.yards ?? 0) \(segment.stroke) \(segment.type) on \(Int(segment.time ?? 0)) sec"
        }.joined(separator: "\n"))
        """
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        
        let data = renderer.pdfData
        {
            (context) in
            context.beginPage()
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.black
            ]
            let attributedText = NSAttributedString(string: fullText, attributes: attributes)
            attributedText.draw(in: CGRect(x: 20, y: 20, width: pageWidth - 40, height: pageHeight - 40))
        }
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(workout.name).pdf")
        do
        {
            try data.write(to: tempURL)
            return tempURL
        }
        catch
        {
            print("Error generating PDF: \(error)")
            return nil
        }
    }
    
    private func fetchWorkouts()
    {
        HealthKitManager.shared.fetchWorkouts(context: context)
        {
            fetchedWorkouts, error in
            
            if let error = error
            {
                print("Error fetching workouts: \(error.localizedDescription)")
                DispatchQueue.main.async
                {
                    self.workouts = fetchFromCoreData()
                }
            }
            else
            {
                DispatchQueue.main.async
                {
                    self.workouts = fetchedWorkouts
                }
            }
        }
    }
    
    private func fetchFromCoreData() -> [SwimWorkout]
    {
        let request: NSFetchRequest<SwimWorkoutEntity> = SwimWorkoutEntity.fetchRequest()
        do
        {
            let entities = try context.fetch(request)
            return entities.map
            {
                entity in
                mapEntityToSwimWorkout(entity)
            }
        }
        catch
        {
            print("Error fetching from Core Data: \(error.localizedDescription)")
            return []
        }
    }
    
    private func mapEntityToSwimWorkout(_ entity: SwimWorkoutEntity) -> SwimWorkout
    {
        let id = UUID(uuidString: entity.id ?? "") ?? UUID()
        let name = entity.name ?? "Unnamed"
        let coachName = entity.coachName ?? ""
        let coach = Coach(name: coachName, level: "", dateCompleted: Date(), clubAbbr: "", clubName: "", lmsc: "")
        
        let warmUpEntities = entity.warmUp?.allObjects as? [WorkoutSegmentEntity] ?? []
        let warmUp = warmUpEntities.map
        {
            seg in
            WorkoutSegment(yards: seg.yards, type: seg.type ?? "", amount: Int(seg.amount), stroke: seg.stroke ?? "", time: seg.time)
        }
        
        let mainSetEntities = entity.mainSet?.allObjects as? [WorkoutSegmentEntity] ?? []
        let mainSet = mainSetEntities.map
        {
            seg in
            WorkoutSegment(yards: seg.yards, type: seg.type ?? "", amount: Int(seg.amount), stroke: seg.stroke ?? "", time: seg.time)
        }
        
        let coolDownEntities = entity.coolDown?.allObjects as? [WorkoutSegmentEntity] ?? []
        let coolDown = coolDownEntities.map
        {
            seg in
            WorkoutSegment(yards: seg.yards, type: seg.type ?? "", amount: Int(seg.amount), stroke: seg.stroke ?? "", time: seg.time)
        }
        
        return SwimWorkout(
            id: id,
            name: name,
            coach: coach,
            warmUp: warmUp,
            mainSet: mainSet,
            coolDown: coolDown,
            createdViaWorkoutKit: entity.createdViaWorkoutKit,
            source: entity.source,
            date: entity.date ?? Date()
        )
    }
    
    private func saveWorkout(_ workout: SwimWorkout)
    {
        PersistenceController.shared.saveWorkout(workout)
        HealthKitManager.shared.saveWorkoutToHealthKit(workout: workout)
        {
            success, error in
            
            if let error = error
            {
                print("Error saving to HealthKit: \(error.localizedDescription)")
            }
        }
    }
    
    private func deleteAllWorkouts()
    {
        HealthKitManager.shared.deleteWorkouts(workouts, context: context)
        {
            success, error in
            
            if success
            {
                DispatchQueue.main.async
                {
                    self.workouts = []
                }
            }
            else if let error = error
            {
                print("Error deleting workouts: \(error.localizedDescription)")
            }
        }
    }
    
    private func deleteWorkouts(at offsets: IndexSet)
    {
        let workoutsToDelete = offsets.map { workouts[$0] }
        HealthKitManager.shared.deleteWorkouts(workoutsToDelete, context: context)
        {
            success, error in
            
            if success
            {
                DispatchQueue.main.async
                {
                    self.workouts.remove(atOffsets: offsets)
                }
            } else if let error = error
            {
                print("Error deleting workout: \(error.localizedDescription)")
            }
        }
    }
}

#Preview
{
    WorkoutListView()
        .environment(\.managedObjectContext, PersistenceController.shared.context)
}
