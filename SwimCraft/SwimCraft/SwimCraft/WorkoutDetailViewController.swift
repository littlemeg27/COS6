//
//  WorkoutDetailViewController.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 7/9/25.
//

import UIKit
import Foundation

class WorkoutDetailViewController: UIViewController, UITableViewDataSource
{
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var coachLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private let distanceLabel = UILabel()
    private let durationLabel = UILabel()
    
    var workout: SwimWorkout?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.register(WorkoutDetailTableViewCell.self, forCellReuseIdentifier: "SegmentCell")
        
        setupAdditionalLabels()
        
        if let workout = workout
        {
            nameLabel.text = workout.name
            coachLabel.text = "Coach: \(workout.coach?.name ?? "None")"
            distanceLabel.text = "Distance: \(workout.distance) meters"
            durationLabel.text = "Duration: \(Int(workout.duration / 60)) minutes"
        }
        
        nameLabel.accessibilityLabel = "Workout Name"
        coachLabel.accessibilityLabel = "Coach"
        distanceLabel.accessibilityLabel = "Distance"
        durationLabel.accessibilityLabel = "Duration"
    }
    
    private func setupAdditionalLabels()
    {
        distanceLabel.font = .systemFont(ofSize: 16)
        distanceLabel.textColor = .label
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        durationLabel.font = .systemFont(ofSize: 16)
        durationLabel.textColor = .label
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(arrangedSubviews: [nameLabel, coachLabel, distanceLabel, durationLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        coachLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton)
    {
        navigationController?.popViewController(animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        guard let workout = workout else { return 0 }
        switch section
        {
            case 0: return workout.warmUp.count
            case 1: return workout.mainSet.count
            case 2: return workout.coolDown.count
            default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        switch section
        {
            case 0: return "Warm Up"
            case 1: return "Main Set"
            case 2: return "Cool Down"
            default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SegmentCell", for: indexPath) as! WorkoutDetailTableViewCell
        guard let workout = workout else { return cell }
        
        let segment: WorkoutSegment
        
        switch indexPath.section
        {
            case 0:
                segment = workout.warmUp[indexPath.row]
            case 1:
                segment = workout.mainSet[indexPath.row]
            case 2:
                segment = workout.coolDown[indexPath.row]
            default:
                return cell
        }
        
        cell.configure(with: segment)
        return cell
    }
}
