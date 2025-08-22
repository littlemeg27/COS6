//
//  WorkoutListView.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 8/20/25.
//


import SwiftUI
import CoreData // Ensure this is imported for NSFetchRequest, entities, etc.

struct WorkoutListView: View {
    @Environment(\.managedObjectContext) private var context
    @State private var workouts: [SwimWorkout] = []
    @State private var showingCreation: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(workouts) { workout in
                    NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                        VStack(alignment: .leading) {
                            Text(workout.name)
                                .font(.headline)
                            Text("Distance: \(workout.distance) yards")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete { indices in
                    deleteWorkouts(at: indices)
                }
            }
            .navigationTitle("Workouts")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Workout") {
                        showingCreation = true
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Clear All") {
                        deleteAllWorkouts()
                    }
                }
            }
            .sheet(isPresented: $showingCreation) {
                WorkoutCreationView { newWorkout in
                    saveWorkout(newWorkout)
                    fetchWorkouts() // Refreshes list post-save
                }
            }
            .onAppear {
                fetchWorkouts()
            }
        }
    }
    
    private func fetchWorkouts() {
        HealthKitManager.shared.fetchWorkouts(context: context) { fetchedWorkouts, error in
            if let error = error {
                print("Error fetching workouts: \(error.localizedDescription)")
                // Fallback to Core Data if HealthKit fails
                DispatchQueue.main.async {
                    self.workouts = fetchFromCoreData()
                }
            } else {
                DispatchQueue.main.async {
                    self.workouts = fetchedWorkouts
                }
            }
        }
    }
    
    private func fetchFromCoreData() -> [SwimWorkout] {
        let request: NSFetchRequest<SwimWorkoutEntity> = SwimWorkoutEntity.fetchRequest()
        do {
            let entities = try context.fetch(request)
            return entities.map { entity in
                mapEntityToSwimWorkout(entity)
            }
        } catch {
            print("Error fetching from Core Data: \(error.localizedDescription)")
            return []
        }
    }
    
    private func mapEntityToSwimWorkout(_ entity: SwimWorkoutEntity) -> SwimWorkout {
        // Break up the mapping to help compiler
        let id = UUID(uuidString: entity.id ?? "") ?? UUID()
        let name = entity.name ?? "Unnamed"
        let coachName = entity.coachName ?? ""
        let coach = Coach(name: coachName, level: "", dateCompleted: Date(), clubAbbr: "", clubName: "", lmsc: "") // Fill in as needed
        
        let warmUpEntities = entity.warmUp?.array as? [WorkoutSegmentEntity] ?? []
        let warmUp = warmUpEntities.map { seg in
            WorkoutSegment(yards: seg.yards, type: seg.type ?? "", amount: Int(seg.amount), stroke: seg.stroke ?? "", time: seg.time)
        }
        
        let mainSetEntities = entity.mainSet?.array as? [WorkoutSegmentEntity] ?? []
        let mainSet = mainSetEntities.map { seg in
            WorkoutSegment(yards: seg.yards, type: seg.type ?? "", amount: Int(seg.amount), stroke: seg.stroke ?? "", time: seg.time)
        }
        
        let coolDownEntities = entity.coolDown?.array as? [WorkoutSegmentEntity] ?? []
        let coolDown = coolDownEntities.map { seg in
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
            date: Date() // Or map if stored
        )
    }
    
    private func saveWorkout(_ workout: SwimWorkout) {
        PersistenceController.shared.saveWorkout(workout)
        HealthKitManager.shared.saveWorkoutToHealthKit(workout: workout) { success, error in
            if let error = error {
                print("Error saving to HealthKit: \(error.localizedDescription)")
            }
        }
    }
    
    private func deleteAllWorkouts() {
        HealthKitManager.shared.deleteWorkouts(workouts, context: context) { success, error in
            if success {
                DispatchQueue.main.async {
                    self.workouts = []
                }
            } else if let error = error {
                print("Error deleting workouts: \(error.localizedDescription)")
            }
        }
    }
    
    private func deleteWorkouts(at offsets: IndexSet) {
        let workoutsToDelete = offsets.map { workouts[$0] }
        HealthKitManager.shared.deleteWorkouts(workoutsToDelete, context: context) { success, error in
            if success {
                DispatchQueue.main.async {
                    self.workouts.remove(atOffsets: offsets)
                }
            } else if let error = error {
                print("Error deleting workout: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    WorkoutListView()
        .environment(\.managedObjectContext, PersistenceController.shared.context)
}
