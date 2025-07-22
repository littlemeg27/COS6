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
    @IBOutlet weak var typePicker: UIDropDownPicker!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var strokePicker: UIDropDownPicker!
    @IBOutlet weak var timePicker: UIDropDownPicker!
    
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
    
    @objc func textFieldDidChange() {
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
        switch pickerView.tag
        {
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
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        setupUI()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
}
