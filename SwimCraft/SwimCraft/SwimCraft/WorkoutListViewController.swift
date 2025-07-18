//
//  WorkoutListViewController.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 7/9/25.
//

import UIKit
import WatchConnectivity
import Foundation

class WorkoutListViewController: UITableViewController, WCSessionDelegate
{
    var workouts: [SwimWorkout] = []
    private var session: WCSession?

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if WCSession.isSupported()
        {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
        HealthKitManager.shared.requestAuthorization
        {
            success, error in
            
            if success
            {
                HealthKitManager.shared.fetchWorkouts
                {
                    fetchedWorkouts, error in
                    
                    if let fetchedWorkouts = fetchedWorkouts
                    {
                        self.workouts = fetchedWorkouts
                        self.tableView.reloadData()
                    }
                }
            }
            else if let error = error
            {
                print("HealthKit authorization failed: \(error)")
            }
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?)
    {
        if let error = error
        {
            print("WCSession activation failed: \(error)")
        }
        else
        {
            sendWorkoutsToWatch()
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}

    func sendWorkoutsToWatch()
    {
        guard let session = session, session.isReachable else
        {
            print("Watch session not reachable")
            return
        }
        let workoutData = workouts.map
        {
            workout in
            [
                "id": workout.id.uuidString,
                "name": workout.name,
                "distance": workout.distance,
                "duration": workout.duration,
                "strokes": workout.strokes,
                "createdViaWorkoutKit": workout.createdViaWorkoutKit,
                "coach": workout.coach.map {
                    [
                        "name": $0.name,
                        "level": $0.level,
                        "dateCompleted": $0.dateCompleted,
                        "clubAbbr": $0.clubAbbr,
                        "clubName": $0.clubName,
                        "lmsc": $0.lmsc
                    ]
                }
                as Any,
                "source": workout.source ?? ""
            ]
        }
        session.sendMessage(["workouts": workoutData], replyHandler: nil)
        {
            error in
            print("Error sending workouts to watch: \(error)")
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
        cell.detailTextLabel?.text = "Coach: \(workout.coach?.name ?? "None")"
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        performSegue(withIdentifier: "toWorkoutDetail", sender: indexPath)
    }

    @IBAction func addWorkoutTapped(_ sender: UIBarButtonItem)
    {
        performSegue(withIdentifier: "toWorkoutCreation", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "toWorkoutDetail", let destination = segue.destination as? WorkoutDetailViewController, let indexPath = sender as? IndexPath
        {
            destination.workout = workouts[indexPath.row]
        }
        else if segue.identifier == "toWorkoutCreation", let destination = segue.destination as? WorkoutCreationViewController
        {
            destination.onSave = { workout in
                self.workouts.append(workout)
                HealthKitManager.shared.saveWorkout(workout)
                {
                    success, error in
                    
                    if success
                    {
                        self.tableView.reloadData()
                        self.sendWorkoutsToWatch()
                    }
                    else if let error = error
                    {
                        print("Error saving workout: \(error)")
                    }
                }
            }
        }
    }

    func shareWorkout(_ workout: SwimWorkout)
    {
        let shareText = """
        Swim Workout: \(workout.name)
        Distance: \(workout.distance) meters
        Duration: \(Int(workout.duration / 60)) minutes
        Strokes: \(workout.strokes.joined(separator: ", "))
        Coach: \(workout.coach?.name ?? "None")
        """
        let activityController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }

    @IBAction func addWorkoutKitWorkoutTapped(_ sender: UIButton)
    {
        SwimWorkoutManager.shared.createSwimWorkout(
            name: "Sprint Swim",
            distance: 1000,
            duration: 3600,
            strokes: ["Freestyle"]
        )
        {
            swimWorkout, error in
            
            if let swimWorkout = swimWorkout
            {
                self.workouts.append(swimWorkout)
                self.tableView.reloadData()
                self.sendWorkoutsToWatch()
            }
            else if let error = error
            {
                print("Error creating swim workout: \(error)")
            }
        }
    }
}
