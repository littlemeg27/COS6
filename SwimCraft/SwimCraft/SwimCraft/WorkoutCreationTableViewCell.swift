//
//  WorkoutCreationTableViewCell.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 7/21/25.
//

import UIKit

class WorkoutCreationTableViewCell: UITableViewCell {
    @IBOutlet weak var yardsTextField: UITextField?
    @IBOutlet weak var typeButton: UIButton?
    @IBOutlet weak var amountTextField: UITextField?
    @IBOutlet weak var strokeButton: UIButton?
    @IBOutlet weak var timeButton: UIButton?
    
    var segment: WorkoutSegment?
    var onUpdate: ((WorkoutSegment) -> Void)?
    
    private let types = ["Swim", "Kick", "Drill", "Pull"]
    private let strokes = ["Freestyle", "Backstroke", "Breaststroke", "Butterfly", "IM"]
    private let times: [TimeInterval] = [30, 60, 90, 120, 150, 180, 240, 300]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("WorkoutCreationTableViewCell awakeFromNib, typeButton: \(typeButton != nil ? "connected" : "nil"), strokeButton: \(strokeButton != nil ? "connected" : "nil"), timeButton: \(timeButton != nil ? "connected" : "nil")")
        setupTextFields()
        setupButtons()
    }
    
    private func setupButtons() {
        guard let typeButton = typeButton, let strokeButton = strokeButton, let timeButton = timeButton else {
            print("Error: One or more buttons are nil (typeButton: \(typeButton != nil ? "connected" : "nil"), strokeButton: \(strokeButton != nil ? "connected" : "nil"), timeButton: \(timeButton != nil ? "connected" : "nil"))")
            return
        }
        
        // Setup typeButton menu
        let typeMenu = UIMenu(title: "Select Type", children: types.map { type in
            UIAction(title: type) { [weak self] _ in
                guard let self = self, var segment = self.segment else {
                    print("Error: self or segment is nil in typeButton action")
                    return
                }
                segment.type = type
                typeButton.setTitle(type, for: .normal)
                self.segment = segment
                self.onUpdate?(segment)
                print("Selected type: \(type)")
            }
        })
        typeButton.menu = typeMenu
        typeButton.showsMenuAsPrimaryAction = true
        typeButton.setTitle(segment?.type.isEmpty ?? true ? types.first ?? "Swim" : segment!.type, for: .normal)
        
        // Setup strokeButton menu
        let strokeMenu = UIMenu(title: "Select Stroke", children: strokes.map { stroke in
            UIAction(title: stroke) { [weak self] _ in
                guard let self = self, var segment = self.segment else {
                    print("Error: self or segment is nil in strokeButton action")
                    return
                }
                segment.stroke = stroke
                strokeButton.setTitle(stroke, for: .normal)
                self.segment = segment
                self.onUpdate?(segment)
                print("Selected stroke: \(stroke)")
            }
        })
        strokeButton.menu = strokeMenu
        strokeButton.showsMenuAsPrimaryAction = true
        strokeButton.setTitle(segment?.stroke.isEmpty ?? true ? strokes.first ?? "Freestyle" : segment!.stroke, for: .normal)
        
        // Setup timeButton menu
        let timeMenu = UIMenu(title: "Select Time", children: times.map { time in
            UIAction(title: "\(Int(time)) sec") { [weak self] _ in
                guard let self = self, var segment = self.segment else {
                    print("Error: self or segment is nil in timeButton action")
                    return
                }
                segment.time = time
                timeButton.setTitle("\(Int(time)) sec", for: .normal)
                self.segment = segment
                self.onUpdate?(segment)
                print("Selected time: \(time) sec")
            }
        })
        timeButton.menu = timeMenu
        timeButton.showsMenuAsPrimaryAction = true
        let timeTitle = segment?.time ?? 0 > 0 ? "\(Int(segment!.time!)) sec" : "\(Int(times.first ?? 30)) sec"
        timeButton.setTitle(timeTitle, for: .normal)
    }
    
    private func setupTextFields() {
        guard let yardsTextField = yardsTextField, let amountTextField = amountTextField else {
            print("Error: One or more text fields are nil (yardsTextField: \(yardsTextField != nil ? "connected" : "nil"), amountTextField: \(amountTextField != nil ? "connected" : "nil"))")
            return
        }
        
        yardsTextField.text = segment?.yards ?? 0 > 0 ? String(format: "%.0f", segment!.yards!) : ""
        amountTextField.text = segment?.amount ?? 0 > 0 ? "\(segment!.amount!)" : ""
        
        yardsTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        amountTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
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
        }
        self.segment = segment
        self.onUpdate?(segment)
        print("Updated segment: yards=\(segment.yards ?? 0), amount=\(segment.amount ?? 0), time=\(segment.time ?? 0)")
    }
    
    func configure(with segment: WorkoutSegment, types: [String] = ["Swim", "Kick", "Drill", "Pull"], strokes: [String] = ["Freestyle", "Backstroke", "Breaststroke", "Butterfly", "IM"], times: [TimeInterval] = [30, 60, 90, 120, 150, 180, 240, 300])
    {
        self.segment = segment
        self.yardsTextField?.text = segment.yards ?? 0 > 0 ? String(format: "%.0f", segment.yards!) : ""
        self.amountTextField?.text = segment.amount ?? 0 > 0 ? "\(segment.amount!)" : ""
        setupButtons()
        print("Configured cell with segment: type=\(segment.type), stroke=\(segment.stroke), yards=\(segment.yards ?? 0), amount=\(segment.amount ?? 0), time=\(segment.time ?? 0)")
    }
}
