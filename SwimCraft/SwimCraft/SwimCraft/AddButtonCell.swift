//
//  AddButtonTableViewCell.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 7/21/25.
//

import UIKit

extension UIColor
{
    convenience init(hexString: String)
    {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var rgb: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgb)
        let red = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let green = CGFloat((rgb >> 8) & 0xFF) / 255.0
        let blue = CGFloat(rgb & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

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
        addLabel.textAlignment = .center
        addLabel.textColor = UIColor(hexString: "#293241")
        addLabel.backgroundColor = UIColor(hexString: "#98C1D9") 
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
