//
//  WorkoutDetailViewController.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 7/9/25.
//

import UIKit

class WorkoutDetailViewController: UIViewController
{
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var distanceTextField: UITextField!
    @IBOutlet weak var durationTextField: UITextField!
    @IBOutlet weak var strokesTextField: UITextField!
    @IBOutlet weak var coachPicker: UIPickerView!
    
    var coaches: [Coach] = []
    var selectedCoach: Coach?
    var onSave: ((SwimWorkout) -> Void)?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        coachPicker.dataSource = self
        coachPicker.delegate = self
        coaches = loadCoaches(from: "CertifiedCoaches")
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton)
    {
        guard let name = nameTextField.text, !name.isEmpty,
              let distanceText = distanceTextField.text, let distance = Double(distanceText),
              let durationText = durationTextField.text, let duration = Double(durationText),
              let strokesText = strokesTextField.text else { return }
        
        let strokes = strokesText.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        let workout = SwimWorkout(
            id: UUID(),
            name: name,
            coach: selectedCoach,
            distance: distance,
            duration: duration,
            strokes: strokes,
            createdViaWorkoutKit: false
        )
        onSave?(workout)
        navigationController?.popViewController(animated: true)
    }
}

extension WorkoutDetailViewController: UIPickerViewDataSource, UIPickerViewDelegate
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
