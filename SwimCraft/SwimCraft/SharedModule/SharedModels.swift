//
//  SharedModels.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 7/13/25.
//

import Foundation

struct WorkoutSegment: Hashable {
    var yards: Double?
    var type: String
    var amount: Int?
    var stroke: String
    var time: TimeInterval?
    
    init(yards: Double?, type: String, amount: Int?, stroke: String, time: TimeInterval?) {
        self.yards = yards
        self.type = type
        self.amount = amount
        self.stroke = stroke
        self.time = time
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(stroke)
        hasher.combine(yards)
        hasher.combine(amount)
        hasher.combine(time)
    }
    
    static func == (lhs: WorkoutSegment, rhs: WorkoutSegment) -> Bool {
        lhs.type == rhs.type &&
        lhs.stroke == rhs.stroke &&
        lhs.yards == rhs.yards &&
        lhs.amount == rhs.amount &&
        lhs.time == rhs.time
    }
}

struct SwimWorkout: Hashable {  // Add Hashable conformance
    let id: UUID
    let name: String
    let coach: Coach?
    let warmUp: [WorkoutSegment]
    let mainSet: [WorkoutSegment]
    let coolDown: [WorkoutSegment]
    let createdViaWorkoutKit: Bool
    let source: String?
    let date: Date
    
    var distance: Double {
        (warmUp + mainSet + coolDown).reduce(0) { $0 + ($1.yards ?? 0) }
    }
    
    var duration: TimeInterval {
        (warmUp + mainSet + coolDown).reduce(0) { $0 + ($1.time ?? 0) }
    }
    
    var strokes: [String] {
        Array(Set((warmUp + mainSet + coolDown).compactMap { $0.stroke }))
    }
    
    var estimatedCalories: Double {
        return distance * 0.5
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(coach)
        hasher.combine(warmUp)
        hasher.combine(mainSet)
        hasher.combine(coolDown)
        hasher.combine(createdViaWorkoutKit)
        hasher.combine(source)
        hasher.combine(date)
    }
    
    static func == (lhs: SwimWorkout, rhs: SwimWorkout) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.coach == rhs.coach &&
        lhs.warmUp == rhs.warmUp &&
        lhs.mainSet == rhs.mainSet &&
        lhs.coolDown == rhs.coolDown &&
        lhs.createdViaWorkoutKit == rhs.createdViaWorkoutKit &&
        lhs.source == rhs.source &&
        lhs.date == rhs.date
    }
}

struct Coach: Hashable {
    var name: String
    var level: String
    var dateCompleted: Date
    var clubAbbr: String
    var clubName: String
    var lmsc: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(level)
        hasher.combine(dateCompleted)
        hasher.combine(clubAbbr)
        hasher.combine(clubName)
        hasher.combine(lmsc)
    }
    
    static func == (lhs: Coach, rhs: Coach) -> Bool {
        lhs.name == rhs.name &&
        lhs.level == rhs.level &&
        lhs.dateCompleted == rhs.dateCompleted &&
        lhs.clubAbbr == rhs.clubAbbr &&
        lhs.clubName == rhs.clubName &&
        lhs.lmsc == rhs.lmsc
    }
}
