//
//  WorkoutCreationViewController.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 7/17/25.
//

import UIKit
import Foundation

class WorkoutCreationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var coachPicker: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    var coaches: [Coach] = []
    var selectedCoach: Coach?
    var warmUpSegments: [WorkoutSegment] = []
    var mainSetSegments: [WorkoutSegment] = []
    var coolDownSegments: [WorkoutSegment] = []
    var onSave: ((SwimWorkout) -> Void)?
    
    let segmentTypes = ["Drill", "Swim", "Kick", "Pull", "Sprint", "Easy", "Fins"]
    let strokeTypes = ["Freestyle", "Backstroke", "Breaststroke", "Butterfly", "Individual Medley", "Not Free Style", "Choice"]
    let timeOptions: [TimeInterval] = [30, 60, 90, 120, 180]
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        coaches = loadCoaches(from: "CertifiedCoaches")
        
        warmUpSegments.append(WorkoutSegment(yards: 0, type: segmentTypes[0], amount: 1, stroke: strokeTypes[0], time: timeOptions[0]))
        mainSetSegments.append(WorkoutSegment(yards: 0, type: segmentTypes[0], amount: 1, stroke: strokeTypes[0], time: timeOptions[0]))
        coolDownSegments.append(WorkoutSegment(yards: 0, type: segmentTypes[0], amount: 1, stroke: strokeTypes[0], time: timeOptions[0]))
        
        tableView.register(WorkoutCreationTableViewCell.self, forCellReuseIdentifier: "WorkoutSegmentCell")
        tableView.register(AddButtonCell.self, forCellReuseIdentifier: "AddButtonCell")
        
        setupCoachPicker()
    }
    
    private func setupCoachPicker()
    {
        coachPicker.setTitle("Select Coach", for: .normal)
        coachPicker.showsMenuAsPrimaryAction = true
        coachPicker.titleLabel?.font = .systemFont(ofSize: 16)
        coachPicker.setTitleColor(.systemBlue, for: .normal)
        
        updateCoachPickerMenu()
        
        coachPicker.accessibilityLabel = "Select Coach"
        coachPicker.accessibilityHint = "Tap to choose a coach for the workout"
    }
    
    private func updateCoachPickerMenu()
    {
        let coachActions = coaches.enumerated().map { index, coach in
            UIAction(title: "\(coach.name) (\(coach.level))", handler: { [weak self] _ in
                self?.selectedCoach = coach
                self?.coachPicker.setTitle("\(coach.name) (\(coach.level))", for: .normal)
            })
        }
        
        let menu = UIMenu(title: "Select Coach", children: coachActions)
        coachPicker.menu = menu
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch section
        {
            case 0: return warmUpSegments.count + 1
            case 1: return mainSetSegments.count + 1
            case 2: return coolDownSegments.count + 1
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
        let section = indexPath.section
        let row = indexPath.row
        let segments = section == 0 ? warmUpSegments : section == 1 ? mainSetSegments : coolDownSegments
        
        if row < segments.count
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutSegmentCell", for: indexPath) as! WorkoutCreationTableViewCell
            let segment = segments[row]
            cell.configure(with: segment, types: segmentTypes, strokes: strokeTypes, times: timeOptions)
            
            cell.onUpdate = { [weak self] updatedSegment in
                if section == 0
                {
                    self?.warmUpSegments[row] = updatedSegment
                }
                else if section == 1
                {
                    self?.mainSetSegments[row] = updatedSegment
                }
                else
                {
                    self?.coolDownSegments[row] = updatedSegment
                }
            }
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddButtonCell", for: indexPath) as! AddButtonCell
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        let section = indexPath.section
        let row = indexPath.row
        let segments = section == 0 ? warmUpSegments : section == 1 ? mainSetSegments : coolDownSegments
        
        if row == segments.count
        {
            let newSegment = WorkoutSegment(yards: 0, type: segmentTypes[0], amount: 1, stroke: strokeTypes[0], time: timeOptions[0])
            
            if section == 0
            {
                warmUpSegments.append(newSegment)
            }
            else if section == 1
            {
                mainSetSegments.append(newSegment)
            }
            else
            {
                coolDownSegments.append(newSegment)
            }
            tableView.insertRows(at: [IndexPath(row: row, section: section)], with: .automatic)
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton)
    {
        guard let name = nameTextField.text, !name.isEmpty else
        {
            let alert = UIAlertController(title: "Error", message: "Please enter a workout name", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let workout = SwimWorkout(
            id: UUID(),
            name: name,
            coach: selectedCoach,
            warmUp: warmUpSegments,
            mainSet: mainSetSegments,
            coolDown: coolDownSegments,
            createdViaWorkoutKit: false,
            source: nil
        )
        onSave?(workout)
        navigationController?.popViewController(animated: true)
    }
}
