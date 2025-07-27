//
//  WorkoutCreationViewController.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 7/17/25.
//

import UIKit
import Foundation

class WorkoutCreationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var nameTextField: UITextField?
    @IBOutlet weak var coachPicker: UIPickerView!
    @IBOutlet weak var saveButton: UIButton?
    
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
        print("WorkoutCreationViewController viewDidLoad started")
        
        guard let tableView = tableView else
        {
            print("Error: tableView is nil")
            return
        }
        tableView.dataSource = self
        tableView.delegate = self
        
        print("Setting up coachPicker, isEnabled: \(coachPicker.isUserInteractionEnabled)")
        coachPicker.dataSource = self
        coachPicker.delegate = self
        coachPicker.reloadAllComponents()
        
        coaches = loadCoaches(from: "CertifiedCoaches")
        if coaches.isEmpty {
            print("Warning: No coaches loaded")
            coaches = [
                Coach(name: "Default Coach", level: "Level 1", dateCompleted: Date(), clubAbbr: "", clubName: "", lmsc: "")
            ]
        }
        
        print("Loaded \(coaches.count) coaches: \(coaches.map { $0.name })")
        selectedCoach = coaches.first
        
        if let firstIndex = coaches.firstIndex(where: { $0.name == coaches.first?.name })
        {
            coachPicker.selectRow(firstIndex, inComponent: 0, animated: false)
        }
        
        warmUpSegments.append(WorkoutSegment(yards: 0, type: segmentTypes[0], amount: 1, stroke: strokeTypes[0], time: timeOptions[0]))
        mainSetSegments.append(WorkoutSegment(yards: 0, type: segmentTypes[0], amount: 1, stroke: strokeTypes[0], time: timeOptions[0]))
        coolDownSegments.append(WorkoutSegment(yards: 0, type: segmentTypes[0], amount: 1, stroke: strokeTypes[0], time: timeOptions[0]))
        
        print("nameTextField: \(nameTextField?.text ?? "nil"), isEnabled: \(nameTextField?.isEnabled ?? false)")
        print("coachPicker: set, isEnabled: \(coachPicker.isUserInteractionEnabled)")
        print("saveButton: \(saveButton?.titleLabel?.text ?? "nil"), isEnabled: \(saveButton?.isEnabled ?? false)")
        print("WorkoutCreationViewController viewDidLoad completed")
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        print("coachPicker numberOfComponents: 1")
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        print("coachPicker numberOfRows: \(coaches.count)")
        return coaches.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        let coach = coaches[row]
        let title = "\(coach.name) (\(coach.level))"
        print("coachPicker titleForRow \(row): \(title)")
        return title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        selectedCoach = coaches[row]
        print("Selected coach: \(coaches[row].name)")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        print("numberOfSections: 3")
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let count: Int
        switch section
        {
            case 0: count = warmUpSegments.count + 1
            case 1: count = mainSetSegments.count + 1
            case 2: count = coolDownSegments.count + 1
            default: count = 0
        }
        print("numberOfRowsInSection \(section): \(count)")
        return count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        let title: String?
        switch section
        {
            case 0: title = "Warm Up"
            case 1: title = "Main Set"
            case 2: title = "Cool Down"
            default: title = nil
        }
        print("titleForHeaderInSection \(section): \(title ?? "nil")")
        return title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let section = indexPath.section
        let row = indexPath.row
        let segments = section == 0 ? warmUpSegments : section == 1 ? mainSetSegments : coolDownSegments
        
        if row < segments.count
        {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutSegmentCell", for: indexPath) as? WorkoutCreationTableViewCell else
            {
                print("Error: Failed to dequeue WorkoutCreationTableViewCell at \(indexPath)")
                return UITableViewCell()
            }
            let segment = segments[row]
            cell.configure(with: segment, types: segmentTypes, strokes: strokeTypes, times: timeOptions)
            
            cell.onUpdate =
            {
                [weak self] updatedSegment in
                
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
                print("Updated segment in section \(section), row \(row): \(updatedSegment)")
            }
            print("Configured WorkoutSegmentCell at \(indexPath)")
            return cell
        }
        else
        {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddButtonCell", for: indexPath) as? AddButtonCell else
            {
                print("Error: Failed to dequeue AddButtonCell at \(indexPath)")
                return UITableViewCell()
            }
            print("Configured AddButtonCell at \(indexPath)")
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
            print("Added new segment in section \(section): \(newSegment)")
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton)
    {
        guard let nameTextField = nameTextField, let name = nameTextField.text, !name.isEmpty else
        {
            print("Error: Workout name is empty")
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
        print("Saving workout: \(workout.name), distance: \(workout.distance), duration: \(workout.duration), strokes: \(workout.strokes)")
        onSave?(workout)
        
        if let navigationController = navigationController
        {
            print("Popping to WorkoutListViewController")
            navigationController.popViewController(animated: true)
        }
        else
        {
            print("Error: navigationController is nil in saveButtonTapped")
            dismiss(animated: true, completion: nil)
        }
    }
}
