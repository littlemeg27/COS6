//
//  WorkoutCreationTableViewCell.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 7/21/25.
//

import UIKit

class WorkoutCreationTableViewCell: UITableViewCell
{
    @IBOutlet weak var yardsTextField: UITextField!
    @IBOutlet weak var typePicker: UIButton!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var strokePicker: UIButton!
    @IBOutlet weak var timePicker: UIButton!
    
    var types: [String] = []
    var strokes: [String] = []
    var times: [TimeInterval] = []
    var onUpdate: ((WorkoutSegment) -> Void)?
    
    private var selectedType: String?
    private var selectedStroke: String?
    private var selectedTime: TimeInterval?
    
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
        if yardsTextField == nil
        {
            yardsTextField = UITextField()
            contentView.addSubview(yardsTextField)
        }
        if typePicker == nil
        {
            typePicker = UIButton(type: .system)
            contentView.addSubview(typePicker)
        }
        if amountTextField == nil
        {
            amountTextField = UITextField()
            contentView.addSubview(amountTextField)
        }
        if strokePicker == nil
        {
            strokePicker = UIButton(type: .system)
            contentView.addSubview(strokePicker)
        }
        if timePicker == nil
        {
            timePicker = UIButton(type: .system)
            contentView.addSubview(timePicker)
        }
        
        yardsTextField.placeholder = "Yards"
        yardsTextField.keyboardType = .decimalPad
        yardsTextField.borderStyle = .roundedRect
        
        amountTextField.placeholder = "Reps"
        amountTextField.keyboardType = .numberPad
        amountTextField.borderStyle = .roundedRect
        
        typePicker.setTitle("Select Type", for: .normal)
        typePicker.setTitleColor(.systemBlue, for: .normal)
        typePicker.showsMenuAsPrimaryAction = true
        typePicker.titleLabel?.font = .systemFont(ofSize: 14)
        
        strokePicker.setTitle("Select Stroke", for: .normal)
        strokePicker.setTitleColor(.systemBlue, for: .normal)
        strokePicker.showsMenuAsPrimaryAction = true
        strokePicker.titleLabel?.font = .systemFont(ofSize: 14)
        
        timePicker.setTitle("Select Time", for: .normal)
        timePicker.setTitleColor(.systemBlue, for: .normal)
        timePicker.showsMenuAsPrimaryAction = true
        timePicker.titleLabel?.font = .systemFont(ofSize: 14)
        
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
        
        yardsTextField.accessibilityLabel = "Yards"
        yardsTextField.accessibilityHint = "Enter the distance in yards"
        amountTextField.accessibilityLabel = "Reps"
        amountTextField.accessibilityHint = "Enter the number of repetitions"
        typePicker.accessibilityLabel = "Segment Type"
        typePicker.accessibilityHint = "Tap to select the type of workout segment"
        strokePicker.accessibilityLabel = "Stroke"
        strokePicker.accessibilityHint = "Tap to select the stroke type"
        timePicker.accessibilityLabel = "Time"
        timePicker.accessibilityHint = "Tap to select the time interval"
    }
    
    func configure(with segment: WorkoutSegment, types: [String], strokes: [String], times: [TimeInterval])
    {
        self.types = types
        self.strokes = strokes
        self.times = times
        yardsTextField.text = String(segment.yards)
        amountTextField.text = String(segment.amount)
        
        selectedType = segment.type
        typePicker.setTitle(segment.type, for: .normal)
        updateTypeMenu()
        
        selectedStroke = segment.stroke
        strokePicker.setTitle(segment.stroke, for: .normal)
        updateStrokeMenu()
        
        selectedTime = segment.time
        timePicker.setTitle("\(Int(segment.time)) sec", for: .normal)
        updateTimeMenu()
    }
    
    private func updateTypeMenu()
    {
        let actions = types.map
        {
            type in
            UIAction(title: type, state: type == selectedType ? .on : .off)
            {
                [weak self] _ in
                self?.selectedType = type
                self?.typePicker.setTitle(type, for: .normal)
                self?.updateSegment()
            }
        }
        typePicker.menu = UIMenu(title: "Select Type", children: actions)
    }
    
    private func updateStrokeMenu()
    {
        let actions = strokes.map
        {
            stroke in
            UIAction(title: stroke, state: stroke == selectedStroke ? .on : .off) { [weak self] _ in
                self?.selectedStroke = stroke
                self?.strokePicker.setTitle(stroke, for: .normal)
                self?.updateSegment()
            }
        }
        strokePicker.menu = UIMenu(title: "Select Stroke", children: actions)
    }
    
    private func updateTimeMenu()
    {
        let actions = times.map
        {
            time in
            UIAction(title: "\(Int(time)) sec", state: time == selectedTime ? .on : .off) { [weak self] _ in
                self?.selectedTime = time
                self?.timePicker.setTitle("\(Int(time)) sec", for: .normal)
                self?.updateSegment()
            }
        }
        timePicker.menu = UIMenu(title: "Select Time", children: actions)
    }
    
    @objc func textFieldDidChange()
    {
        updateSegment()
    }
    
    func updateSegment()
    {
        guard let yardsText = yardsTextField.text, let yards = Double(yardsText),
              let amountText = amountTextField.text, let amount = Int(amountText),
              let type = selectedType, let stroke = selectedStroke, let time = selectedTime else { return }
        
        let segment = WorkoutSegment(
            yards: yards,
            type: type,
            amount: amount,
            stroke: stroke,
            time: time
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
