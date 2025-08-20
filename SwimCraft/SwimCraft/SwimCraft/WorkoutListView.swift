//
//  WorkoutListView.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 8/20/25.
//


import SwiftUI
import CoreData

struct WorkoutListView: View
{
    @Environment(\.managedObjectContext) private var context
    @State private var workouts: [SwimWorkout] = []
    @State private var showingCreation: Bool = false
    
    var body: some View
    {
        NavigationStack
        {
            List
            {
                ForEach(workouts) { workout in
                    NavigationLink(destination: WorkoutDetailView(workout: workout))
                    {
                        VStack(alignment: .leading)
                        {
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
            .toolbar
            {
                ToolbarItem(placement: .navigationBarTrailing)
                {
                    Button("Add Workout")
                    {
                        showingCreation = true
                    }
                }
                ToolbarItem(placement: .navigationBarLeading)
                {
                    Button("Clear All")
                    {
                        deleteAllWorkouts()
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
    }
    
    private func fetchWorkouts()
    {
        HealthKitManager.shared.fetchWorkouts(context: context)
        {
            fetchedWorkouts, error in
            
            if let error = error
            {
                print("Error fetching workouts: \(error.localizedDescription)")
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
    
    private func deleteAllWorkouts() {
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
            }
            else if let error = error
            {
                print("Error deleting workout: \(error.localizedDescription)")
            }
        }
    }
}
