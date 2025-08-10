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

struct SwimWorkout: Hashable {
    var id: UUID
    var name: String
    var coach: Coach?
    var warmUp: [WorkoutSegment]
    var mainSet: [WorkoutSegment]
    var coolDown: [WorkoutSegment]
    var createdViaWorkoutKit: Bool
    var source: String?
    
    var distance: Double {
        [warmUp, mainSet, coolDown].flatMap { $0 }.reduce(0) { $0 + ($1.yards ?? 0) }
    }
    
    var duration: TimeInterval {
        [warmUp, mainSet, coolDown].flatMap { $0 }.reduce(0) { $0 + ($1.time ?? 0) }
    }
    
    var strokes: [String] {
        Array(Set([warmUp, mainSet, coolDown].flatMap { $0 }.map { $0.stroke }))
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: SwimWorkout, rhs: SwimWorkout) -> Bool {
        lhs.id == rhs.id
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
