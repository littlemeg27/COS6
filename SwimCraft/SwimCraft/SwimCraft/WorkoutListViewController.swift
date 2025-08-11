//
//  WorkoutListViewController.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 7/9/25.
//

import UIKit
import HealthKit
import CoreData

class WorkoutListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var clearAllButton: UIButton!
    
    var workouts: [SwimWorkout] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsMultipleSelectionDuringEditing = true
        print("WorkoutListViewController viewDidLoad, clearButton: \(clearButton != nil ? "connected" : "nil"), shareButton: \(shareButton != nil ? "connected" : "nil")")
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
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workouts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutCell", for: indexPath)
        let workout = workouts[indexPath.row]
        cell.textLabel?.text = workout.name
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            print("Selected workout at \(indexPath): \(workouts[indexPath.row].name)")
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
            let workout = workouts[indexPath.row]
            let detailVC = WorkoutDetailViewController()
            detailVC.workout = workout
            navigationController?.pushViewController(detailVC, animated: true)
            print("Navigating to WorkoutDetailViewController for workout: \(workout.name)")
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let shareAction = UIContextualAction(style: .normal, title: "Share") { [weak self] _, _, completion in
            guard let self = self else { return }
            let workout = self.workouts[indexPath.row]
            self.shareWorkout(workout)
            completion(true)
        }
        shareAction.backgroundColor = .systemBlue
        
        return UISwipeActionsConfiguration(actions: [shareAction])
    }
    
    @IBAction func toggleEditing(_ sender: AnyObject) {
        tableView.setEditing(!tableView.isEditing, animated: true)
        print("Toggled editing mode: \(tableView.isEditing)")
    }
    
    @IBAction func deleteSelectedWorkouts(_ sender: AnyObject) {
        guard let selectedIndexPaths = tableView.indexPathsForSelectedRows else {
            print("No workouts selected for deletion")
            showAlert(message: "No workouts selected")
            return
        }
        let selectedWorkouts = selectedIndexPaths.map { workouts[$0.row] }
        print("deleteSelectedWorkouts triggered")
        print("Attempting to delete \(selectedWorkouts.count) workouts: \(selectedWorkouts.map { $0.name })")
        
        let context = PersistenceController.shared.context
        HealthKitManager.shared.deleteWorkouts(selectedWorkouts, context: context) { [weak self] success, error in
            if success {
                print("Successfully deleted \(selectedWorkouts.count) workouts, remaining count: \(self?.workouts.count ?? 0)")
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SwimWorkoutEntity")
                if let coreDataWorkouts = try? context.fetch(fetchRequest) {
                    print("Core Data contains \(coreDataWorkouts.count) SwimWorkout entities after deletion")
                    for entity in coreDataWorkouts {
                        print("Core Data workout: ID=\(entity.value(forKey: "id") as? String ?? "N/A"), name=\(entity.value(forKey: "name") as? String ?? "N/A")")
                    }
                }
                self?.fetchWorkouts()
            } else {
                print("Error deleting workouts: \(error?.localizedDescription ?? "Unknown error")")
                self?.showAlert(message: "Failed to delete workouts: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    @IBAction func deleteAllWorkouts(_ sender: AnyObject) {
        guard !workouts.isEmpty else {
            print("No workouts to delete")
            showAlert(message: "No workouts to delete")
            return
        }
        let alert = UIAlertController(title: "Delete All Workouts", message: "Are you sure you want to delete all workouts?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            print("deleteAllWorkouts triggered")
            print("Attempting to delete all \(self.workouts.count) workouts: \(self.workouts.map { $0.name })")
            
            let context = PersistenceController.shared.context
            HealthKitManager.shared.deleteWorkouts(self.workouts, context: context) { success, error in
                if success {
                    print("Successfully deleted all workouts")
                    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SwimWorkoutEntity")
                    if let coreDataWorkouts = try? context.fetch(fetchRequest) {
                        print("Core Data contains \(coreDataWorkouts.count) SwimWorkout entities after deletion")
                    }
                    self.fetchWorkouts()
                } else {
                    print("Error deleting all workouts: \(error?.localizedDescription ?? "Unknown error")")
                    self.showAlert(message: "Failed to delete workouts: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        })
        present(alert, animated: true)
    }
    
    @IBAction func shareSelectedWorkout(_ sender: AnyObject) {
        guard let selectedIndexPaths = tableView.indexPathsForSelectedRows, !selectedIndexPaths.isEmpty else {
            print("No workouts selected for sharing")
            showAlert(message: "Please select a workout to share")
            return
        }
        // Share only the first selected workout for simplicity
        let workout = workouts[selectedIndexPaths[0].row]
        shareWorkout(workout)
        print("shareSelectedWorkout triggered for workout: \(workout.name)")
    }
    
    private func shareWorkout(_ workout: SwimWorkout) {
        let text = """
        Workout: \(workout.name)
        Coach: \(workout.coach?.name ?? "N/A")
        Distance: \(workout.distance) meters
        Duration: \(Int(workout.duration)) seconds
        Warm Up: \(workout.warmUp.map { "\($0.amount ?? 1) x \($0.yards ?? 0) \($0.stroke) \($0.type)" }.joined(separator: "\n"))
        Main Set: \(workout.mainSet.map { "\($0.amount ?? 1) x \($0.yards ?? 0) \($0.stroke) \($0.type)" }.joined(separator: "\n"))
        Cool Down: \(workout.coolDown.map { "\($0.amount ?? 1) x \($0.yards ?? 0) \($0.stroke) \($0.type)" }.joined(separator: "\n"))
        """
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        present(activityVC, animated: true)
        print("Sharing workout: \(workout.name)")
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
