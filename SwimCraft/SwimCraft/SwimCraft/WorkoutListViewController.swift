//
//  WorkoutListViewController.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 7/9/25.
//

import UIKit

class WorkoutListViewController: UITableViewController {
    var workouts: [SwimWorkout] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        HealthKitManager.shared.fetchWorkouts { fetchedWorkouts, error in
            if let fetchedWorkouts = fetchedWorkouts {
                self.workouts = fetchedWorkouts
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        workouts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutCell", for: indexPath)
        let workout = workouts[indexPath.row]
        cell.textLabel?.text = workout.name
        cell.detailTextLabel?.text = "Coach: \(workout.coach?.name ?? "WorkoutKit")"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        shareWorkout(workouts[indexPath.row])
    }
    
    @IBAction func addWorkoutTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "toWorkoutDetail", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toWorkoutDetail",
           let destination = segue.destination as? WorkoutDetailViewController {
            destination.onSave = { workout in
                self.workouts.append(workout)
                HealthKitManager.shared.saveWorkout(workout) { _, _ in }
                self.tableView.reloadData()
            }
        }
    }
    
    func shareWorkout(_ workout: SwimWorkout) {
        let shareText = """
        Swim Workout: \(workout.name)
        Distance: \(workout.distance) meters
        Duration: \(Int(workout.duration / 60)) minutes
        Strokes: \(workout.strokes.joined(separator: ", "))
        Coach: \(workout.coach?.name ?? "WorkoutKit")
        """
        let activityController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
    
    @IBAction func addWorkoutKitWorkoutTapped(_ sender: UIButton) {
        let workoutKitWorkout = WorkoutKitManager.shared.createWorkoutKitSwimWorkout(
            name: "Sprint Swim",
            distance: 1000,
            strokes: ["Freestyle"]
        )
        WorkoutKitManager.shared.saveWorkoutKitWorkout(workoutKitWorkout) { swimWorkout, error in
            if let swimWorkout = swimWorkout {
                self.workouts.append(swimWorkout)
                self.tableView.reloadData()
            } else if let error = error {
                print("Error saving WorkoutKit workout: \(error)")
            }
        }
    }
}
