//
//  InterfaceController.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 7/9/25.
//

import WatchKit
import WatchConnectivity

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
    
    // Required WCSessionDelegate methods
    func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed: \(error.localizedDescription)")
        } else {
            print("WCSession activated with state: \(state)")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        if let workoutData = message["workouts"] as? [[String: Any]] {
            workouts = workoutData.compactMap { dict in
                guard let idString = dict["id"] as? String,
                      let id = UUID(uuidString: idString),
                      let name = dict["name"] as? String,
                      let distance = dict["distance"] as? Double,
                      let duration = dict["duration"] as? Double else {
                    return nil
                }
                return SwimWorkout(id: id, name: name, coach: nil, distance: distance, duration: duration, strokes: [], createdViaWorkoutKit: false)
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

// Ensure SwimWorkout is defined and available in the WatchKit Extension
struct SwimWorkout: Codable {
    let id: UUID
    let name: String
    let coach: Coach?
    let distance: Double
    let duration: Double
    let strokes: [String]
    let createdViaWorkoutKit: Bool
}

struct Coach: Codable {
    let name: String
    let level: String
    let dateCompleted: String
    let clubAbbr: String
    let clubName: String
    let lmsc: String
}
