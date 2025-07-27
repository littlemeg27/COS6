//
//  WorkoutListViewController.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 7/9/25.
//

import UIKit

class WorkoutListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    var workouts: [SwimWorkout] = []
    
    private let dateFormatter: DateFormatter =
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        print("WorkoutListViewController loaded")

        guard let tableView = tableView else
        {
            print("Error: tableView is nil")
            return
        }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(WorkoutListTableViewCell.self, forCellReuseIdentifier: "WorkoutCell")
        
        createButton.setTitle("Create Workout", for: .normal)
        createButton.setTitleColor(.systemBlue, for: .normal)
        shareButton.setTitle("Share Workout", for: .normal)
        shareButton.setTitleColor(.systemBlue, for: .normal)
        
        print("createButton: \(createButton.titleLabel?.text ?? "nil"), interaction: \(createButton.isUserInteractionEnabled)")
        print("shareButton: \(createButton.titleLabel?.text ?? "nil"), interaction: \(shareButton.isUserInteractionEnabled)")
        
        HealthKitManager.shared.requestAuthorization
        {
            success, error in
            
            if success
            {
                print("HealthKit authorization succeeded")
                self.fetchWorkouts()
            }
            else if let error = error
            {
                print("HealthKit authorization failed: \(error)")
            }
        }

        if navigationController == nil
        {
            print("Error: navigationController is nil")
        }
        else
        {
            print("navigationController is set")
        }
    }
    
    private func fetchWorkouts()
    {
        HealthKitManager.shared.fetchWorkouts
        {
            fetchedWorkouts, error in
            
            if let fetchedWorkouts = fetchedWorkouts
            {
                DispatchQueue.main.async
                {
                    let uniqueWorkouts = Dictionary(uniqueKeysWithValues: fetchedWorkouts.map { ($0.id, $0) }).values
                    self.workouts = Array(uniqueWorkouts).sorted { $0.name < $1.name }
                    self.tableView.reloadData()
                    print("Fetched \(self.workouts.count) unique workouts: \(self.workouts.map { $0.name })")
                }
            }
            else if let error = error
            {
                print("Error fetching workouts: \(error)")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        print("WorkoutListViewController viewWillAppear, workouts: \(workouts.count)")
        fetchWorkouts()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        print("Number of workouts: \(workouts.count)")
        return workouts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutCell", for: indexPath) as! WorkoutListTableViewCell
        let workout = workouts[indexPath.row]
        cell.configure(with: workout)
        print("Configured cell for workout: \(workout.name) at \(indexPath)")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "toWorkoutDetail", sender: indexPath)
    }
    
    @IBAction func createButtonTapped(_ sender: UIButton)
    {
        print("createButtonTapped triggered")
        performSegue(withIdentifier: "toWorkoutCreation", sender: nil)
        print("Segue toWorkoutCreation performed")
    }
    
    @IBAction func shareButtonTapped(_ sender: UIButton)
    {
        print("shareButtonTapped triggered")
        if workouts.isEmpty
        {
            let alert = UIAlertController(title: "No Workouts", message: "There are no workouts to share.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            print("No workouts available to share")
            return
        }
        
        let alert = UIAlertController(title: "Share Workout", message: "Select a workout to share", preferredStyle: .actionSheet)
        for (index, workout) in workouts.enumerated()
        {
            alert.addAction(UIAlertAction(title: workout.name, style: .default) { _ in
                self.shareWorkout(self.workouts[index])
                print("Selected workout to share: \(workout.name)")
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Share cancelled")
        })
        present(alert, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "toWorkoutDetail", let destination = segue.destination as? WorkoutDetailViewController, let indexPath = sender as? IndexPath
        {
            print("Segue to WorkoutDetailViewController for workout: \(workouts[indexPath.row].name)")
            destination.workout = workouts[indexPath.row]
        }
        else if segue.identifier == "toWorkoutCreation", let destination = segue.destination as? WorkoutCreationViewController
        {
            print("Preparing segue to WorkoutCreationViewController")
            destination.onSave = { [weak self] workout in
                print("Saved workout: \(workout.name), distance: \(workout.distance), duration: \(workout.duration), strokes: \(workout.strokes)")
                self?.workouts.append(workout)
                HealthKitManager.shared.saveWorkout(workout)
                {
                    success, error in
                    if success
                    {
                        DispatchQueue.main.async
                        {
                            self?.tableView.reloadData()
                            print("Workout saved to HealthKit and table reloaded with \(self?.workouts.count ?? 0) workouts")
                        }
                    }
                    else if let error = error
                    {
                        print("Error saving workout to HealthKit: \(error)")
                    }
                }
            }
        }
        else
        {
            print("Unknown segue identifier: \(segue.identifier ?? "nil")")
        }
    }
    
    func shareWorkout(_ workout: SwimWorkout)
    {
        print("Sharing workout: \(workout.name)")
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
        present(activityController, animated: true)
    }
    
    @IBAction func addWorkoutKitWorkoutTapped(_ sender: UIButton)
    {
        print("addWorkoutKitWorkoutTapped disabled for testing")
    }
}
