//
//  WorkoutListTableViewCell.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 7/21/25.
//

import UIKit

class WorkoutListTableViewCell: UITableViewCell
{
    private let nameLabel = UILabel()
    private let coachLabel = UILabel()
    private let distanceLabel = UILabel()
    private let durationLabel = UILabel()
    
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
        nameLabel.font = .boldSystemFont(ofSize: 16)
        nameLabel.textColor = .label
        nameLabel.numberOfLines = 1
        
        coachLabel.font = .systemFont(ofSize: 14)
        coachLabel.textColor = .secondaryLabel
        coachLabel.numberOfLines = 1
        
        distanceLabel.font = .systemFont(ofSize: 14)
        distanceLabel.textColor = .secondaryLabel
        distanceLabel.numberOfLines = 1
        
        durationLabel.font = .systemFont(ofSize: 14)
        durationLabel.textColor = .secondaryLabel
        durationLabel.numberOfLines = 1
        
        let stackView = UIStackView(arrangedSubviews: [nameLabel, coachLabel, distanceLabel, durationLabel])
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
        
        accessoryType = .disclosureIndicator
        
        accessibilityLabel = "Workout Cell"
        accessibilityHint = "Tap to view workout details or share"
    }
    
    func configure(with workout: SwimWorkout)
    {
        nameLabel.text = workout.name
        coachLabel.text = "Coach: \(workout.coach?.name ?? "None")"
        distanceLabel.text = "Distance: \(workout.distance) meters"
        durationLabel.text = "Duration: \(Int(workout.duration / 60)) minutes"
        
        accessibilityLabel = "Workout: \(workout.name), Coach: \(workout.coach?.name ?? "None"), Distance: \(workout.distance) meters, Duration: \(Int(workout.duration / 60)) minutes"
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
