//
//  WorkoutListViewController.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 7/9/25.
//

import UIKit
import HealthKit
import CoreData
import SharedModule


class WorkoutListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var clearButton: UIButton?
    @IBOutlet weak var shareButton: UIButton?
    
    var workouts: [SwimWorkout] = []
    var selectedWorkout: SwimWorkout?
    var context: NSManagedObjectContext!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        print("WorkoutListViewController viewDidLoad, clearButton: \(clearButton != nil ? "connected" : "not connected"), shareButton: \(shareButton != nil ? "connected" : "not connected")")
        tableView!.dataSource = self
        tableView!.delegate = self
        context = PersistenceController.shared.context
        
        HealthKitManager.shared.fetchWorkouts(context: context)
        {
            workouts, error in
            
            if let error = error
            {
                print("Error fetching workouts: (error.localizedDescription)")
            }
            else
            {
                self.workouts = workouts
                DispatchQueue.main.async
                {
                    self.tableView.reloadData()
                }
                print("Number of workouts: (self.workouts.count)")
            }
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return workouts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutCell", for: indexPath)
        let workout = workouts[indexPath.row]
        cell.textLabel?.text = workout.name
        cell.detailTextLabel?.text = "Distance: (workout.distance) yards"
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        selectedWorkout = workouts[indexPath.row]
        performSegue(withIdentifier: "ShowDetail", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "ShowDetail"
        {
            if let detailVC = segue.destination as? WorkoutDetailViewController
            {
                detailVC.workout = selectedWorkout
            }
        }
    }
    @IBAction func clearButtonTapped(_ sender: UIButton)
    {
        guard !workouts.isEmpty else
        {
            print("No workouts to delete")
            return
        }
        HealthKitManager.shared.deleteWorkouts(workouts, context: context) { success, error in
            if success
            {
                print("Successfully deleted workouts")
                self.workouts = []
                self.tableView.reloadData()
            }
            else if let error = error
            {
                print("Error deleting workouts: (error.localizedDescription)")
            }
        }
    }
    @IBAction func shareButtonTapped(_ sender: UIButton)
    {
        guard let selectedWorkout = selectedWorkout else
        {
            print("No workout selected")
            return
        }
        
        var shareText = "Workout: (selectedWorkout.name)\n"
        
        if let coach = selectedWorkout.coach
        {
            shareText += "Coach: (coach.name)\n"
        }
        
        shareText += "Distance: (selectedWorkout.distance) yards\n"
        shareText += "Duration: (selectedWorkout.duration) seconds\n"
        shareText += "\nWarm Up:\n"
        
        for segment in selectedWorkout.warmUp
        {
            shareText += "(segment.amount ?? 1) x (segment.yards ?? 0) (segment.stroke) (segment.type)\n"
        }
        
        shareText += "\nMain Set:\n"
        
        for segment in selectedWorkout.mainSet
        {
            shareText += "(segment.amount ?? 1) x (segment.yards ?? 0) (segment.stroke) (segment.type)\n"
        }
        
        shareText += "\nCool Down:\n"
        
        for segment in selectedWorkout.coolDown
        {
            shareText += "(segment.amount ?? 1) x (segment.yards ?? 0) (segment.stroke) (segment.type)\n"
        }
        
        let activityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        present(activityViewController, animated: true)
    }
}
