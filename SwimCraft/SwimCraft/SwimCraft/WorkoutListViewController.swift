//
//  WorkoutListViewController.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 7/9/25.
//

import UIKit
import WatchConnectivity

class WorkoutListViewController: UITableViewController
{
    var workouts: [SwimWorkout] = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        HealthKitManager.shared.fetchWorkouts { fetchedWorkouts, error in
            if let fetchedWorkouts = fetchedWorkouts
            {
                self.workouts = fetchedWorkouts
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        workouts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutCell", for: indexPath)
        let workout = workouts[indexPath.row]
        cell.textLabel?.text = workout.name
        cell.detailTextLabel?.text = "Coach: \(workout.coach?.name ?? "WorkoutKit")"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        shareWorkout(workouts[indexPath.row])
    }
    
    @IBAction func addWorkoutTapped(_ sender: UIBarButtonItem)
    {
        performSegue(withIdentifier: "toWorkoutDetail", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "toWorkoutDetail",let destination = segue.destination as? WorkoutDetailViewController
        {
            destination.onSave =
            
            { workout in
                self.workouts.append(workout)
                HealthKitManager.shared.saveWorkout(workout)
                { _, _ in }
                self.tableView.reloadData()
            }
        }
    }
    
    class WorkoutListViewController: UITableViewController
    {
        var workouts: [SwimWorkout] = []
        
        func sendWorkoutsToWatch()
        {
            if WCSession.isSupported()
            {
                let session = WCSession.default
                session.delegate = self
                session.activate()
                let workoutData = workouts.map { ["id": $0.id.uuidString, "name": $0.name, "distance": $0.distance, "duration": $0.duration] }
                
                session.sendMessage(["workouts": workoutData], replyHandler: nil)
                { error in
                    print("Error sending to Watch: \(error.localizedDescription)")
                }
            }
        }
    }

    extension WorkoutListViewController: WCSessionDelegate {
        func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {}
        func sessionDidBecomeInactive(_ session: WCSession) {}
        func sessionDidDeactivate(_ session: WCSession) {}
    }
}
