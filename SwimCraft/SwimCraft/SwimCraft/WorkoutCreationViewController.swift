//
//  WorkoutCreationViewController.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 7/17/25.
//

import UIKit
import Foundation
import CSVParser

class WorkoutCreationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var coachPicker: UIPickerView!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        coachPicker.dataSource = self
        coachPicker.delegate = self
        coaches = loadCoaches(from: "CertifiedCoaches")
        

        warmUpSegments.append(WorkoutSegment(yards: 0, type: segmentTypes[0], amount: 1, stroke: strokeTypes[0], time: timeOptions[0]))
        mainSetSegments.append(WorkoutSegment(yards: 0, type: segmentTypes[0], amount: 1, stroke: strokeTypes[0], time: timeOptions[0]))
        coolDownSegments.append(WorkoutSegment(yards: 0, type: segmentTypes[0], amount: 1, stroke: strokeTypes[0], time: timeOptions[0]))
        
        tableView.register(WorkoutSegmentCell.self, forCellReuseIdentifier: "WorkoutSegmentCell")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        let segments = section == 0 ? warmUpSegments : section == 1 ? mainSetSegments : coolDownSegments
        
        if row < segments.count
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutSegmentCell", for: indexPath) as! WorkoutSegmentCell
            let segment = segments[row]
            cell.configure(with: segment, types: segmentTypes, strokes: strokeTypes, times: timeOptions)
            cell.onUpdate =
            { [weak self] updatedSegment in
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
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddButtonCell", for: indexPath)
            cell.textLabel?.text = "+ Add Segment"
            cell.textLabel?.textAlignment = .center
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        let section = indexPath.section
        let row = indexPath.row
        let segments = section == 0 ? warmUpSegments : section == 1 ? mainSetSegments : coolDownSegments
        
        if row == segments.count {
            let newSegment = WorkoutSegment(yards: 0, type: segmentTypes[0], amount: 1, stroke: strokeTypes[0], time: timeOptions[0])
            if section == 0 {
                warmUpSegments.append(newSegment)
            } else if section == 1 {
                mainSetSegments.append(newSegment)
            } else {
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

extension WorkoutCreationViewController: UIPickerViewDataSource, UIPickerViewDelegate
{
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        coaches.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        "\(coaches[row].name) (\(coaches[row].level))"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        selectedCoach = coaches[row]
    }
}

class WorkoutSegmentCell: UITableViewCell, UIPickerViewDataSource, UIPickerViewDelegate
{
    let yardsTextField = UITextField()
    let typePicker = UIPickerView()
    let amountTextField = UITextField()
    let strokePicker = UIPickerView()
    let timePicker = UIPickerView()
    
    var types: [String] = []
    var strokes: [String] = []
    var times: [TimeInterval] = []
    var onUpdate: ((WorkoutSegment) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        setupUI()
    }
    
    func setupUI()
    {
        yardsTextField.placeholder = "Yards"
        yardsTextField.keyboardType = .decimalPad
        amountTextField.placeholder = "Reps"
        amountTextField.keyboardType = .numberPad

        typePicker.tag = 1
        strokePicker.tag = 2
        timePicker.tag = 3
        typePicker.dataSource = self
        typePicker.delegate = self
        strokePicker.dataSource = self
        strokePicker.delegate = self
        timePicker.dataSource = self
        timePicker.delegate = self
        
        let stackView = UIStackView(arrangedSubviews: [yardsTextField, typePicker, amountTextField, strokePicker, timePicker])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        contentView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        
        yardsTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        amountTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    func configure(with segment: WorkoutSegment, types: [String], strokes: [String], times: [TimeInterval])
    {
        self.types = types
        self.strokes = strokes
        self.times = times
        yardsTextField.text = String(segment.yards)
        amountTextField.text = String(segment.amount)
        if let typeIndex = types.firstIndex(of: segment.type)
        {
            typePicker.selectRow(typeIndex, inComponent: 0, animated: false)
        }
        if let strokeIndex = strokes.firstIndex(of: segment.stroke)
        {
            strokePicker.selectRow(strokeIndex, inComponent: 0, animated: false)
        }
        if let timeIndex = times.firstIndex(of: segment.time)
        {
            timePicker.selectRow(timeIndex, inComponent: 0, animated: false)
        }
    }
    
    @objc func textFieldDidChange()
    {
        updateSegment()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        switch pickerView.tag
        {
        case 1: return types.count
        case 2: return strokes.count
        case 3: return times.count
        default: return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        switch pickerView.tag {
        case 1: return types[row]
        case 2: return strokes[row]
        case 3: return "\(Int(times[row])) sec"
        default: return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        updateSegment()
    }
    
    func updateSegment()
    {
        guard let yardsText = yardsTextField.text, let yards = Double(yardsText),
              let amountText = amountTextField.text, let amount = Int(amountText) else { return }
        
        let segment = WorkoutSegment(
            yards: yards,
            type: types[typePicker.selectedRow(inComponent: 0)],
            amount: amount,
            stroke: strokes[strokePicker.selectedRow(inComponent: 0)],
            time: times[timePicker.selectedRow(inComponent: 0)]
        )
        onUpdate?(segment)
    }
}
