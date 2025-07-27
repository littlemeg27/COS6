//
//  AddButtonTableViewCell.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 7/21/25.
//

import UIKit

class AddButtonCell: UITableViewCell
{
    @IBOutlet weak var addLabel: UILabel?
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        setupUI()
    }
    
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
        guard let addLabel = addLabel else
        {
            print("Error: addLabel is nil")
            return
        }
        
        addLabel.text = "Add Segment"
        addLabel.font = .boldSystemFont(ofSize: 16)
        addLabel.textColor = .systemBlue
        addLabel.textAlignment = .center
        addLabel.isAccessibilityElement = true
        addLabel.accessibilityLabel = "Add Segment"
        addLabel.accessibilityHint = "Tap to add a new workout segment"
        
        contentView.backgroundColor = .systemGray6
    }
    
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
        addLabel?.textColor = selected ? .systemBlue.withAlphaComponent(0.7) : .systemBlue
    }
}
