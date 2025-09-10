//
//  MonthlySummaryView.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 9/4/25.
//


import SwiftUI
import CoreData
import Charts

struct MonthlySummaryView: View
{
    @Environment(\.managedObjectContext) private var context
    @State private var totalYards: Double = 0.0
    @State private var dailyYards: [DailyYardage] = []
    @State private var showingWorkoutList = false
    @State private var showingWorkoutGenerator = false
    
    var body: some View
    {
        NavigationStack
        {
            VStack(alignment: .center, spacing: 20)
            {
                
                Text("Monthly Swimming Summary")
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color(customHex: "#16F4D0"))
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                
                Text("Total Yards Swam This Month: \(String(format: "%.0f", totalYards))")
                    .font(.title2)
                    .foregroundStyle(Color(customHex: "#16F4D0"))
                    .padding(.top, 10)
                

                if !dailyYards.isEmpty
                {
                    Chart(dailyYards)
                    {
                        BarMark(
                            x: .value("Day", $0.date, unit: .day),
                            y: .value("Yards", $0.yards)
                        )
                        .foregroundStyle(Color(customHex: "#16F4D0"))
                    }
                    .chartXAxis
                    {
                        AxisMarks(values: .stride(by: .day))
                        {
                            value in
                            AxisValueLabel(format: .dateTime.day(.twoDigits))
                                .foregroundStyle(Color(hex: "#F2F2F2"))
                        }
                    }
                    .frame(height: 300)
                    .padding()
                    .background(Color(customHex: "#F2F2F2").opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(radius: 5)
                }
                else
                {
                    Text("No workouts this month")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                        .padding(.top, 10)
                }
                
                Button("View All Workouts")
                {
                    showingWorkoutList = true
                }
                .font(.system(size: 15, weight: .bold))
                .frame(maxWidth: .infinity)
                .frame(minHeight: 50)
                .foregroundStyle(Color(customHex: "#153B50"))
                .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#16F4D0"), Color(hex: "#55F7DC")]), startPoint: .leading, endPoint: .trailing))
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .padding(.horizontal, 30)
                .padding(.vertical, 50)
                .shadow(radius: 2)
                
                Button("Generate Random Workout")
                {
                    showingWorkoutGenerator = true
                }
                .font(.system(size: 15, weight: .bold))
                .frame(maxWidth: .infinity)
                .frame(minHeight: 50)
                .foregroundStyle(Color(customHex: "#153B50"))
                .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#16F4D0"), Color(hex: "#55F7DC")]), startPoint: .leading, endPoint: .trailing))
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .padding(.horizontal, 20)
                .padding(.vertical, 15)
                .shadow(radius: 2)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .background(Color(customHex: "#153B50"))
            .ignoresSafeArea()
            .sheet(isPresented: $showingWorkoutList)
            {
                WorkoutListView()
            }
            .sheet(isPresented: $showingWorkoutGenerator)
            {
                RandomWorkoutGeneratorView
                {
                    newWorkout in
                    saveWorkout(newWorkout)
                }
            }
            .onAppear
            {
                fetchMonthlyData()
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
        fetchMonthlyData()
    }
    
    private func fetchMonthlyData()
    {
        let calendar = Calendar.current
        let now = Date()
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
              let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) else {
            return
        }
        
        print("Fetching workouts from \(startOfMonth) to \(endOfMonth)")
        
        let request: NSFetchRequest<SwimWorkoutEntity> = SwimWorkoutEntity.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfMonth as NSDate, endOfMonth as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do
        {
            let entities = try context.fetch(request)
            print("Fetched \(entities.count) workouts")
            for entity in entities
            {
                print("Workout on \(entity.date ?? Date()): \(calculateDistance(for: entity)) yards")
            }
            totalYards = entities.reduce(0.0) { $0 + calculateDistance(for: $1) }
            

            let groupedByDay = Dictionary(grouping: entities, by: { calendar.startOfDay(for: $0.date ?? now) })
            dailyYards = groupedByDay.map
            {
                date, workouts in
                DailyYardage(date: date, yards: workouts.reduce(0.0) { $0 + calculateDistance(for: $1) })
            }.sorted { $0.date < $1.date }
        }
        catch
        {
            print("Error fetching monthly workouts: \(error.localizedDescription)")
            totalYards = 0
            dailyYards = []
        }
    }
    
    private func calculateDistance(for entity: SwimWorkoutEntity) -> Double
    {
        let warmUpYards = (entity.warmUp?.allObjects as? [WorkoutSegmentEntity] ?? []).reduce(0.0) { $0 + ($1.yards ?? 0) * Double($1.amount) }
        let mainSetYards = (entity.mainSet?.allObjects as? [WorkoutSegmentEntity] ?? []).reduce(0.0) { $0 + ($1.yards ?? 0) * Double($1.amount) }
        let coolDownYards = (entity.coolDown?.allObjects as? [WorkoutSegmentEntity] ?? []).reduce(0.0) { $0 + ($1.yards ?? 0) * Double($1.amount) }
        return warmUpYards + mainSetYards + coolDownYards
    }
}

struct DailyYardage: Identifiable
{
    let id = UUID()
    let date: Date
    let yards: Double
}

#Preview
{
    MonthlySummaryView()
        .environment(\.managedObjectContext, PersistenceController.shared.context)
}
