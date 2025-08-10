//
//  WorkoutListViewController.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 7/9/25.
//

import UIKit
import HealthKit

class WorkoutListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    var workouts: [SwimWorkout] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsMultipleSelectionDuringEditing = true
        fetchWorkouts()
    }
    
    private func fetchWorkouts() {
        let context = PersistenceController.shared.context
        HealthKitManager.shared.fetchWorkouts(context: context) { [weak self] workouts, error in
            if let error = error {
                print("Error fetching workouts: \(error.localizedDescription)")
                return
            }
            self?.workouts = workouts
            print("Number of workouts: \(workouts.count)")
            self?.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workouts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutCell", for: indexPath)
        let workout = workouts[indexPath.row]
        cell.textLabel?.text = workout.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            print("Selected workout at \(indexPath): \(workouts[indexPath.row].name)")
        }
    }
    
    @IBAction func toggleEditing(_ sender: Any) {
        tableView.setEditing(!tableView.isEditing, animated: true)
    }
    
    @IBAction func deleteSelectedWorkouts(_ sender: Any) {
        guard let selectedIndexPaths = tableView.indexPathsForSelectedRows else {
            print("No workouts selected for deletion")
            return
        }
        let selectedWorkouts = selectedIndexPaths.map { workouts[$0.row] }
        print("deleteSelectedWorkouts triggered")
        print("Attempting to delete \(selectedWorkouts.count) workouts: \(selectedWorkouts.map { $0.name })")
        
        let context = PersistenceController.shared.context
        HealthKitManager.shared.deleteWorkouts(selectedWorkouts, context: context) { [weak self] success, error in
            if success {
                print("Successfully deleted \(selectedWorkouts.count) workouts, remaining count: \(self?.workouts.count ?? 0)")
                self?.fetchWorkouts()
            } else {
                print("Error deleting workouts: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}
