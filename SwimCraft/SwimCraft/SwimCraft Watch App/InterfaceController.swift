//
//  InterfaceController.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 7/9/25.
//


import WatchKit
import WatchConnectivity
import Foundation

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    @IBOutlet weak var workoutTable: WKInterfaceTable!
    var workouts: [SwimWorkout] = []

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed: \(error.localizedDescription)")
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        if let workoutData = message["workouts"] as? [[String: Any]] {
            workouts = workoutData.compactMap { dict -> SwimWorkout? in
                guard let idString = dict["id"] as? String,
                      let id = UUID(uuidString: idString),
                      let name = dict["name"] as? String,
                      let distance = dict["distance"] as? Double,
                      let duration = dict["duration"] as? Double,
                      let strokes = dict["strokes"] as? [String],
                      let createdViaWorkoutKit = dict["createdViaWorkoutKit"] as? Bool else {
                    return nil
                }
                let coach: Coach?
                if let coachDict = dict["coach"] as? [String: String],
                   let coachName = coachDict["name"],
                   let coachLevel = coachDict["level"],
                   let dateCompleted = coachDict["dateCompleted"],
                   let clubAbbr = coachDict["clubAbbr"],
                   let clubName = coachDict["clubName"],
                   let lmsc = coachDict["lmsc"] {
                    coach = Coach(name: coachName, level: coachLevel, dateCompleted: dateCompleted, clubAbbr: clubAbbr, clubName: clubName, lmsc: lmsc)
                } else {
                    coach = nil
                }
                return SwimWorkout(
                    id: id,
                    name: name,
                    coach: coach,
                    distance: distance,
                    duration: duration,
                    strokes: strokes,
                    createdViaWorkoutKit: createdViaWorkoutKit,
                    source: dict["source"] as? String
                )
            }
            DispatchQueue.main.async {
                self.updateTable()
            }
        }
    }

    func updateTable() {
        workoutTable.setNumberOfRows(workouts.count, withRowType: "WorkoutRow")
        for (index, workout) in workouts.enumerated() {
            if let row = workoutTable.rowController(at: index) as? WorkoutRowController {
                row.workoutLabel.setText(workout.name)
            }
        }
    }
}

class WorkoutRowController: NSObject {
    @IBOutlet weak var workoutLabel: WKInterfaceLabel!
}
