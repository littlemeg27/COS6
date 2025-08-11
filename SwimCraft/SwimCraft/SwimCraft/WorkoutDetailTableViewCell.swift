//
//  WorkoutDetailTableViewCell.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 7/21/25.
//

import UIKit

class WorkoutDetailTableViewCell: UITableViewCell {
    @IBOutlet weak var yardsLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var strokeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("WorkoutDetailTableViewCell awakeFromNib")
    }
    
    func configure(with segment: WorkoutSegment) {
        // Explicitly unwrap optionals with local variables
        let yards: Double = segment.yards ?? 0.0
        let amount: Int = segment.amount ?? 0
        let time: TimeInterval = segment.time ?? 0.0
        
        yardsLabel.text = yards > 0 ? String(format: "%.0f yards", yards) : "N/A"
        typeLabel.text = segment.type
        amountLabel.text = amount > 0 ? String(amount) : "N/A"
        strokeLabel.text = segment.stroke
        timeLabel.text = time > 0 ? String(format: "%d sec", Int(time)) : "N/A"
        
        print("Configured WorkoutDetailTableViewCell: type=\(segment.type), stroke=\(segment.stroke), yards=\(yards), amount=\(amount), time=\(time)")
    }
}
