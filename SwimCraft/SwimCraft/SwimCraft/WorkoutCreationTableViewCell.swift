//
//  WorkoutCreationTableViewCell.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 7/21/25.
//

import UIKit
import SharedModule

class WorkoutCreationTableViewCell: UITableViewCell
{
    @IBOutlet weak var yardsTextField: UITextField?
    @IBOutlet weak var typeButton: UIButton?
    @IBOutlet weak var amountTextField: UITextField?
    @IBOutlet weak var strokeButton: UIButton?
    @IBOutlet weak var timeButton: UIButton?
    
    var segment: WorkoutSegment?
    var onUpdate: ((WorkoutSegment) -> Void)?
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        print("WorkoutCreationTableViewCell awakeFromNib")
        setupTextFields()
    }
    
    private func setupButtons(types: [String], strokes: [String], times: [TimeInterval])
    {
        print("Setting up buttons with types: \(types), strokes: \(strokes), times: \(times)")
        
        print("typeButton is connected: \(typeButton != nil ? String(describing: typeButton) : "nil")")
        print("strokeButton is connected: \(strokeButton != nil ? String(describing: strokeButton) : "nil")")
        print("timeButton is connected: \(timeButton != nil ? String(describing: timeButton) : "nil")")
        
        guard let typeButton = typeButton, let strokeButton = strokeButton, let timeButton = timeButton else
        {
            print("Error: One or more buttons are nil")
            return
        }

        let typeMenu = UIMenu(title: "Select Type", children: types.map
                              {
            type in
            UIAction(title: type, handler:
                        {
                [weak self] _ in
                guard var segment = self?.segment else { return }
                segment.type = type
                typeButton.setTitle(type, for: .normal)
                self?.segment = segment
                self?.onUpdate?(segment)
                print("Selected type: \(type)")
            })
        })
        
        typeButton.menu = typeMenu
        typeButton.showsMenuAsPrimaryAction = true
        strokeButton.layer.borderWidth = 1
        strokeButton.layer.borderColor = UIColor.red.cgColor
        typeButton.setTitle(segment?.type ?? types.first ?? "Swim", for: .normal)
        print("Button '\(typeButton.currentTitle ?? "nil")' menu children: \(typeButton.menu?.children.count ?? 0)")
        
        let strokeMenu = UIMenu(title: "Select Stroke", children: strokes.map { stroke in
            UIAction(title: stroke, handler:
                        {
                [weak self] _ in
                guard var segment = self?.segment else { return }
                segment.stroke = stroke
                strokeButton.setTitle(stroke, for: .normal)
                self?.segment = segment
                self?.onUpdate?(segment)
                
                print("Selected stroke: \(stroke)")
            })
        })
        strokeButton.menu = strokeMenu
        strokeButton.showsMenuAsPrimaryAction = true
        strokeButton.layer.borderWidth = 1
        strokeButton.layer.borderColor = UIColor.red.cgColor
        strokeButton.setTitle(segment?.stroke ?? strokes.first ?? "Freestyle", for: .normal)
        print("Button '\(strokeButton.currentTitle ?? "nil")' menu children: \(strokeButton.menu?.children.count ?? 0)")

        
        let timeMenu = UIMenu(title: "Select Time", children: times.map
                              {
            time in
            UIAction(title: "\(Int(time)) sec", handler: { [weak self] _ in
                guard var segment = self?.segment else { return }
                segment.time = time
                timeButton.setTitle("\(Int(time)) sec", for: .normal)
                self?.segment = segment
                self?.onUpdate?(segment)
                print("Selected time: \(time) sec")
            })
        })
        
        timeButton.menu = timeMenu
        timeButton.showsMenuAsPrimaryAction = true
        strokeButton.layer.borderWidth = 1
        strokeButton.layer.borderColor = UIColor.red.cgColor
        let timeTitle = segment?.time ?? 0 > 0 ? "\(Int(segment?.time ?? times.first ?? 30)) sec" : "\(Int(times.first ?? 30)) sec"
        timeButton.setTitle(timeTitle, for: .normal)
        print("Button '\(timeButton.currentTitle ?? "nil")' menu children: \(timeButton.menu?.children.count ?? 0)")
    }
    
    private func setupTextFields()
    {
        yardsTextField?.text = segment?.yards ?? 0 > 0 ? "\(segment?.yards ?? 0)" : ""
        amountTextField?.text = segment?.amount ?? 0 > 0 ? "\(segment?.amount ?? 0)" : ""
        
        yardsTextField?.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        amountTextField?.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField)
    {
        guard var segment = segment else
        {
            print("Error: segment is nil in textFieldDidChange")
            return
        }
        
        if textField == yardsTextField
        {
            segment.yards = Double(textField.text ?? "0") ?? 0
        }
        else if textField == amountTextField
        {
            segment.amount = Int(textField.text ?? "0") ?? 0
        }
        self.segment = segment
        onUpdate?(segment)
        print("Updated segment: yards=\(segment.yards ?? 0), amount=\(segment.amount ?? 0), time=\(segment.time ?? 0)")
    }
    
    func configure(with segment: WorkoutSegment, types: [String], strokes: [String], times: [TimeInterval])
    {
        self.segment = segment
        yardsTextField?.text = segment.yards ?? 0 > 0 ? "\(segment.yards ?? 0)" : ""
        amountTextField?.text = segment.amount ?? 0 > 0 ? "\(segment.amount ?? 0)" : ""
        setupButtons(types: types, strokes: strokes, times: times)
        print("Configured cell with segment: type=\(segment.type), stroke=\(segment.stroke), yards=\(segment.yards ?? 0), amount=\(segment.amount ?? 0), time=\(segment.time ?? 0)")
    }
}
