//
//  WorkoutDetailViewController.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 7/9/25.
//

import UIKit
import Foundation

class WorkoutDetailViewController: UIViewController
{
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var distanceTextField: UITextField!
    @IBOutlet weak var durationTextField: UITextField!
    @IBOutlet weak var strokesTextField: UITextField!
    @IBOutlet weak var coachLabel: UILabel!

    var workout: SwimWorkout?

    override func viewDidLoad()
    {
        super.viewDidLoad()
        nameTextField.isEnabled = false
        distanceTextField.isEnabled = false
        durationTextField.isEnabled = false
        strokesTextField.isEnabled = false

        if let workout = workout
        {
            nameTextField.text = workout.name
            distanceTextField.text = String(workout.distance)
            durationTextField.text = String(Int(workout.duration / 60))
            strokesTextField.text = workout.strokes.joined(separator: ", ")
            coachLabel.text = workout.coach?.name ?? "None"
        }
    }

    @IBAction func backButtonTapped(_ sender: UIButton)
    {
        navigationController?.popViewController(animated: true)
    }
}
