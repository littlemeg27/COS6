//
//  InterfaceController.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 7/11/25.
//

import SwiftUI
import WatchConnectivity

struct ContentView: View {
    @StateObject private var sessionDelegate = SessionDelegate()

    var body: some View {
        List(sessionDelegate.workouts, id: \.id) { workout in
            Text(workout.name)
        }
        .onAppear {
            if WCSession.isSupported() {
                let session = WCSession.default
                session.delegate = sessionDelegate
                session.activate()
            }
        }
    }
}

class SessionDelegate: NSObject, WCSessionDelegate, ObservableObject {
    @Published var workouts: [SwimWorkout] = []

    func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed: \(error.localizedDescription)")
        } else {
            print("WCSession activated with state: \(state)")
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        if let workoutData = message["workouts"] as? [[String: Any]] {
            let newWorkouts = workoutData.compactMap { dict in
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
                self.workouts = newWorkouts
            }
        }
    }
}
