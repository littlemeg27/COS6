//
//  SharedModels.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 7/13/25.
//

import Foundation

public struct WorkoutSegment: Hashable, Identifiable
{
    public var id = UUID()
    public var yards: Double?
    public var type: String
    public var amount: Int?
    public var stroke: String
    public var time: TimeInterval?
    
    public init(id: UUID = UUID(), yards: Double?, type: String, amount: Int?, stroke: String, time: TimeInterval?)
    {
        self.id = id
        self.yards = yards
        self.type = type
        self.amount = amount
        self.stroke = stroke
        self.time = time
    }
    
    public func hash(into hasher: inout Hasher)
    {
        hasher.combine(id)
        hasher.combine(type)
        hasher.combine(stroke)
        hasher.combine(yards)
        hasher.combine(amount)
        hasher.combine(time)
    }
    
    public static func == (lhs: WorkoutSegment, rhs: WorkoutSegment) -> Bool
    {
        lhs.id == rhs.id &&
        lhs.type == rhs.type &&
        lhs.stroke == rhs.stroke &&
        lhs.yards == rhs.yards &&
        lhs.amount == rhs.amount &&
        lhs.time == rhs.time
    }
}

public struct SwimWorkout: Hashable, Identifiable
{
    public let id: UUID
    public let name: String
    public let coach: Coach?
    public let warmUp: [WorkoutSegment]
    public let mainSet: [WorkoutSegment]
    public let coolDown: [WorkoutSegment]
    public let createdViaWorkoutKit: Bool
    public let source: String?
    public let date: Date
    
    public var distance: Double
    {
        (warmUp + mainSet + coolDown).reduce(0) { $0 + ($1.yards ?? 0) }
    }
    
    public var duration: TimeInterval
    {
        (warmUp + mainSet + coolDown).reduce(0) { $0 + ($1.time ?? 0) }
    }
    
    public var strokes: [String]
    {
        Array(Set((warmUp + mainSet + coolDown).compactMap { $0.stroke }))
    }
    
    public var estimatedCalories: Double
    {
        return distance * 0.5
    }
    
    public func hash(into hasher: inout Hasher)
    {
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
    
    public static func == (lhs: SwimWorkout, rhs: SwimWorkout) -> Bool
    {
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

public struct Coach: Hashable
{
    public var name: String
    public var level: String
    public var dateCompleted: Date
    public var clubAbbr: String
    public var clubName: String
    public var lmsc: String
    
    public func hash(into hasher: inout Hasher)
    {
        hasher.combine(name)
        hasher.combine(level)
        hasher.combine(dateCompleted)
        hasher.combine(clubAbbr)
        hasher.combine(clubName)
        hasher.combine(lmsc)
    }
    
    public static func == (lhs: Coach, rhs: Coach) -> Bool
    {
        lhs.name == rhs.name &&
        lhs.level == rhs.level &&
        lhs.dateCompleted == rhs.dateCompleted &&
        lhs.clubAbbr == rhs.clubAbbr &&
        lhs.clubName == rhs.clubName &&
        lhs.lmsc == rhs.lmsc
    }
}
