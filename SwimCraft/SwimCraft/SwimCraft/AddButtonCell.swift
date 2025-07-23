//
//  AddButtonTableViewCell.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 7/21/25.
//

import UIKit

class AddButtonCell: UITableViewCell
{
    
    private let addLabel = UILabel()
    
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
        addLabel.text = "+ Add Segment"
        addLabel.font = .boldSystemFont(ofSize: 16)
        addLabel.textColor = .systemBlue
        addLabel.textAlignment = .center
        addLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(addLabel)
        
        NSLayoutConstraint.activate([
            addLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            addLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            addLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            addLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        
        contentView.backgroundColor = .systemGray6
        
        addLabel.isAccessibilityElement = true
        addLabel.accessibilityLabel = "Add Segment"
        addLabel.accessibilityHint = "Tap to add a new workout segment"
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        setupUI()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
        addLabel.textColor = selected ? .systemBlue.withAlphaComponent(0.7) : .systemBlue
    }
}
