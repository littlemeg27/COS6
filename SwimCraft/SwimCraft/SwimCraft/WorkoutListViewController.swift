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
    @IBOutlet weak var createButton: UIButton?
    @IBOutlet weak var shareButton: UIButton?
    
    var workouts: [SwimWorkout] = []
    private var session: WCSession?
    private var isSelectingForShare = false
    
    private let dateFormatter: DateFormatter =
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()

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
                    else if let error = error
                    {
                        print("Error fetching workouts: \(error)")
                    }
                }
            }
            else if let error = error
            {
                print("HealthKit authorization failed: \(error)")
            }
        }
        
        tableView.register(WorkoutListTableViewCell.self, forCellReuseIdentifier: "WorkoutCell")
        
        createButton?.accessibilityLabel = "Add Workout"
        createButton?.accessibilityHint = "Tap to create a new swim workout"
        shareButton?.accessibilityLabel = "Share Workout"
        shareButton?.accessibilityHint = "Tap to select and share a workout"
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
                "coach": workout.coach.map
                {
                    [
                        "name": $0.name,
                        "level": $0.level,
                        "dateCompleted": self.dateFormatter.string(from: $0.dateCompleted),
                        "clubAbbr": $0.clubAbbr,
                        "clubName": $0.clubName,
                        "lmsc": $0.lmsc
                    ]
                }
                as Any,
                "source": workout.source ?? "",
                "warmUp": workout.warmUp.map { ["yards": $0.yards, "type": $0.type, "amount": $0.amount, "stroke": $0.stroke, "time": $0.time] },
                "mainSet": workout.mainSet.map { ["yards": $0.yards, "type": $0.type, "amount": $0.amount, "stroke": $0.stroke, "time": $0.time] },
                "coolDown": workout.coolDown.map { ["yards": $0.yards, "type": $0.type, "amount": $0.amount, "stroke": $0.stroke, "time": $0.time] }
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
        return workouts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutCell", for: indexPath) as! WorkoutListTableViewCell
        let workout = workouts[indexPath.row]
        cell.configure(with: workout)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if isSelectingForShare
        {
            shareWorkout(workouts[indexPath.row])
            isSelectingForShare = false
            tableView.deselectRow(at: indexPath, animated: true)
        }
        else
        {
            performSegue(withIdentifier: "toWorkoutDetail", sender: indexPath)
        }
    }

    @IBAction func addWorkoutTapped(_ sender: UIBarButtonItem)
    {
        performSegue(withIdentifier: "toWorkoutCreation", sender: nil)
    }

    @IBAction func shareWorkoutTapped(_ sender: UIBarButtonItem)
    {
        isSelectingForShare = true
        let alert = UIAlertController(title: "Share Workout", message: "Select a workout to share", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel)
                        {
            _ in
            self.isSelectingForShare = false
        })
        present(alert, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "toWorkoutDetail", let destination = segue.destination as? WorkoutDetailViewController, let indexPath = sender as? IndexPath
        {
            destination.workout = workouts[indexPath.row]
        }
        else if segue.identifier == "toWorkoutCreation", let destination = segue.destination as? WorkoutCreationViewController
        {
            destination.onSave =
            {
                workout in
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
        Warm Up: \(workout.warmUp.map { "\($0.amount)x \($0.yards) yards \($0.stroke) (\($0.type), \(Int($0.time)) sec)" }.joined(separator: "\n"))
        Main Set: \(workout.mainSet.map { "\($0.amount)x \($0.yards) yards \($0.stroke) (\($0.type), \(Int($0.time)) sec)" }.joined(separator: "\n"))
        Cool Down: \(workout.coolDown.map { "\($0.amount)x \($0.yards) yards \($0.stroke) (\($0.type), \(Int($0.time)) sec)" }.joined(separator: "\n"))
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
