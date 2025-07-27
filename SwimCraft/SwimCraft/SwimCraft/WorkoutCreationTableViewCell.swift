//
//  WorkoutCreationTableViewCell.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 7/21/25.
//


import UIKit

class WorkoutCreationTableViewCell: UITableViewCell, UIPickerViewDataSource, UIPickerViewDelegate
{
    @IBOutlet weak var yardsTextField: UITextField!
    @IBOutlet weak var typePicker: UIPickerView!
    @IBOutlet weak var strokePicker: UIPickerView!
    @IBOutlet weak var timePicker: UIPickerView!
    @IBOutlet weak var amountTextField: UITextField!
    
    var onUpdate: ((WorkoutSegment) -> Void)?
    var types: [String] = []
    var strokes: [String] = []
    var times: [TimeInterval] = []
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        print("WorkoutCreationTableViewCell awakeFromNib")
        setupPickers()
        setupTextFields()
    }
    
    private func setupPickers()
    {
        guard let typePicker = typePicker, let strokePicker = strokePicker, let timePicker = timePicker else
        {
            print("Error: One or more UI elements are nil in WorkoutCreationTableViewCell")
            return
        }
        
        print("Setting up pickers")
        typePicker.dataSource = self
        typePicker.delegate = self
        strokePicker.dataSource = self
        strokePicker.delegate = self
        timePicker.dataSource = self
        timePicker.delegate = self
        typePicker.reloadAllComponents()
        strokePicker.reloadAllComponents()
        timePicker.reloadAllComponents()
        
        print("Pickers configured: typePicker: set, strokePicker: set, timePicker: set")
    }
    
    private func setupTextFields()
    {
        yardsTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        amountTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        print("Text fields set up")
    }
    
    func configure(with segment: WorkoutSegment, types: [String], strokes: [String], times: [TimeInterval])
    {
        guard let typePicker = typePicker, let strokePicker = strokePicker, let timePicker = timePicker else
        {
            print("Error: One or more UI elements are nil in configure")
            return
        }
        
        self.types = types
        self.strokes = strokes
        self.times = times
        
        print("Configuring cell with segment: \(segment), types: \(types), strokes: \(strokes), times: \(times)")
        yardsTextField.text = "\(segment.yards)"
        amountTextField.text = "\(segment.amount)"
        
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
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        print("Picker \(pickerView == typePicker ? "typePicker" : pickerView == strokePicker ? "strokePicker" : "timePicker") numberOfComponents: 1")
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        let count = pickerView == typePicker ? types.count : pickerView == strokePicker ? strokes.count : times.count
        print("Picker \(pickerView == typePicker ? "typePicker" : pickerView == strokePicker ? "strokePicker" : "timePicker") numberOfRows: \(count)")
        return count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        if pickerView == typePicker
        {
            print("typePicker titleForRow \(row): \(types[row])")
            return types[row]
        }
        else if pickerView == strokePicker
        {
            print("strokePicker titleForRow \(row): \(strokes[row])")
            return strokes[row]
        }
        else if pickerView == timePicker
        {
            let title = "\(Int(times[row])) sec"
            print("timePicker titleForRow \(row): \(title)")
            return title
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        let yards = Double(yardsTextField.text ?? "0") ?? 0
        let amount = Int(amountTextField.text ?? "1") ?? 1
        let type = types[typePicker.selectedRow(inComponent: 0)]
        let stroke = strokes[strokePicker.selectedRow(inComponent: 0)]
        let time = times[timePicker.selectedRow(inComponent: 0)]
        
        onUpdate?(WorkoutSegment(yards: yards, type: type, amount: amount, stroke: stroke, time: time))
        print("Picker selected: type: \(type), stroke: \(stroke), time: \(time)")
    }
    
    @objc func textFieldDidChange()
    {
        let yards = Double(yardsTextField.text ?? "0") ?? 0
        let amount = Int(amountTextField.text ?? "1") ?? 1
        let type = types[typePicker.selectedRow(inComponent: 0)]
        let stroke = strokes[strokePicker.selectedRow(inComponent: 0)]
        let time = times[timePicker.selectedRow(inComponent: 0)]
        
        onUpdate?(WorkoutSegment(yards: yards, type: type, amount: amount, stroke: stroke, time: time))
        print("Text field changed: yards: \(yards), amount: \(amount)")
    }
}
