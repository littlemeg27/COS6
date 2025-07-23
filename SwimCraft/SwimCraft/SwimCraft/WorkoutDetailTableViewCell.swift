//
//  WorkoutDetailTableViewCell.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 7/21/25.
//

import UIKit

class WorkoutDetailTableViewCell: UITableViewCell
{
    private let yardsLabel = UILabel()
    private let typeLabel = UILabel()
    private let amountLabel = UILabel()
    private let strokeLabel = UILabel()
    private let timeLabel = UILabel()
    
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
    
    private func setupUI()
    {
        yardsLabel.font = .systemFont(ofSize: 14)
        yardsLabel.textColor = .label
        yardsLabel.numberOfLines = 1
        
        typeLabel.font = .systemFont(ofSize: 14)
        typeLabel.textColor = .label
        typeLabel.numberOfLines = 1
        
        amountLabel.font = .systemFont(ofSize: 14)
        amountLabel.textColor = .label
        amountLabel.numberOfLines = 1
        
        strokeLabel.font = .systemFont(ofSize: 14)
        strokeLabel.textColor = .label
        strokeLabel.numberOfLines = 1
        
        timeLabel.font = .systemFont(ofSize: 14)
        timeLabel.textColor = .label
        timeLabel.numberOfLines = 1
        
        let stackView = UIStackView(arrangedSubviews: [amountLabel, yardsLabel, strokeLabel, typeLabel, timeLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        
        accessibilityLabel = "Workout Segment"
        accessibilityHint = "Displays details of a workout segment"
    }
    
    func configure(with segment: WorkoutSegment)
    {
        amountLabel.text = "Reps: \(segment.amount)"
        yardsLabel.text = "Yards: \(segment.yards)"
        strokeLabel.text = "Stroke: \(segment.stroke)"
        typeLabel.text = "Type: \(segment.type)"
        timeLabel.text = "Time: \(Int(segment.time)) sec"
        
        accessibilityLabel = "\(segment.amount) reps of \(segment.yards) yards \(segment.stroke), \(segment.type), \(Int(segment.time)) seconds"
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
