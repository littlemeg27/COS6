//
//  WorkoutCreationTableViewCell.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 7/21/25.
//

import UIKit

class WorkoutCreationTableViewCell: UITableViewCell {
    @IBOutlet weak var yardsTextField: UITextField!
    @IBOutlet weak var typeButton: UIButton!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var strokeButton: UIButton!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var timeButton: UIButton!
    
    var segment: WorkoutSegment?
    var onUpdate: ((WorkoutSegment) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("WorkoutCreationTableViewCell awakeFromNib")
        setupTextFields()
    }
    
    private func setupButtons(types: [String], strokes: [String], times: [TimeInterval]) {
        print("Setting up buttons with types: \(types), strokes: \(strokes), times: \(times)")
        
        // Verify buttons are UIButton
        print("typeButton is UIButton: \(typeButton is UIButton ? String(describing: typeButton) : "Not a UIButton, actual type: \(type(of: typeButton))")")
        print("strokeButton is UIButton: \(strokeButton is UIButton ? String(describing: strokeButton) : "Not a UIButton, actual type: \(type(of: strokeButton))")")
        print("timeButton is UIButton: \(timeButton is UIButton ? String(describing: timeButton) : "Not a UIButton, actual type: \(type(of: timeButton))")")
        
        guard typeButton is UIButton, strokeButton is UIButton, timeButton is UIButton else {
            print("Error: One or more buttons are not UIButton instances")
            return
        }
        
        // Setup typeButton
        let typeMenu = UIMenu(title: "Select Type", children: types.map { type in
            UIAction(title: type, handler: { [weak self] _ in
                guard var segment = self?.segment else { return }
                segment.type = type
                self?.typeButton.setTitle(type, for: .normal)
                self?.segment = segment
                self?.onUpdate?(segment)
                print("Selected type: \(type)")
            })
        })
        typeButton.menu = typeMenu
        typeButton.showsMenuAsPrimaryAction = true
        typeButton.setTitle(segment?.type ?? types.first ?? "Swim", for: .normal)
        
        // Setup strokeButton
        let strokeMenu = UIMenu(title: "Select Stroke", children: strokes.map { stroke in
            UIAction(title: stroke, handler: { [weak self] _ in
                guard var segment = self?.segment else { return }
                segment.stroke = stroke
                self?.strokeButton.setTitle(stroke, for: .normal)
                self?.segment = segment
                self?.onUpdate?(segment)
                print("Selected stroke: \(stroke)")
            })
        })
        strokeButton.menu = strokeMenu
        strokeButton.showsMenuAsPrimaryAction = true
        strokeButton.setTitle(segment?.stroke ?? strokes.first ?? "Freestyle", for: .normal)
        
        // Setup timeButton
        let timeMenu = UIMenu(title: "Select Time", children: times.map { time in
            UIAction(title: "\(Int(time)) sec", handler: { [weak self] _ in
                guard var segment = self?.segment else { return }
                segment.time = time
                self?.timeButton.setTitle("\(Int(time)) sec", for: .normal)
                self?.timeTextField.text = "\(Int(time))"
                self?.segment = segment
                self?.onUpdate?(segment)
                print("Selected time: \(time) sec")
            })
        })
        timeButton.menu = timeMenu
        timeButton.showsMenuAsPrimaryAction = true
        let timeTitle = segment?.time ?? 0 > 0 ? "\(Int(segment?.time ?? times.first ?? 30)) sec" : "\(Int(times.first ?? 30)) sec"
        timeButton.setTitle(timeTitle, for: .normal)
    }
    
    private func setupTextFields() {
        yardsTextField.text = segment?.yards ?? 0 > 0 ? "\(segment?.yards ?? 0)" : ""
        amountTextField.text = segment?.amount ?? 0 > 0 ? "\(segment?.amount ?? 0)" : ""
        timeTextField.text = segment?.time ?? 0 > 0 ? "\(Int(segment?.time ?? 0))" : ""
        
        yardsTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        amountTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        timeTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard var segment = segment else {
            print("Error: segment is nil in textFieldDidChange")
            return
        }
        if textField == yardsTextField {
            segment.yards = Double(textField.text ?? "0") ?? 0
        } else if textField == amountTextField {
            segment.amount = Int(textField.text ?? "0") ?? 0
        } else if textField == timeTextField {
            segment.time = TimeInterval(textField.text ?? "0") ?? 0
            let timeTitle = segment.time ?? 0 > 0 ? "\(Int(segment.time ?? 30)) sec" : "30 sec"
            timeButton.setTitle(timeTitle, for: .normal)
        }
        self.segment = segment
        onUpdate?(segment)
        print("Updated segment: yards=\(segment.yards ?? 0), amount=\(segment.amount ?? 0), time=\(segment.time ?? 0)")
    }
    
    func configure(with segment: WorkoutSegment, types: [String], strokes: [String], times: [TimeInterval]) {
        self.segment = segment
        yardsTextField.text = segment.yards ?? 0 > 0 ? "\(segment.yards ?? 0)" : ""
        amountTextField.text = segment.amount ?? 0 > 0 ? "\(segment.amount ?? 0)" : ""
        timeTextField.text = segment.time ?? 0 > 0 ? "\(Int(segment.time ?? 0))" : ""
        setupButtons(types: types, strokes: strokes, times: times)
        print("Configured cell with segment: type=\(segment.type), stroke=\(segment.stroke), yards=\(segment.yards ?? 0), amount=\(segment.amount ?? 0), time=\(segment.time ?? 0)")
    }
}
