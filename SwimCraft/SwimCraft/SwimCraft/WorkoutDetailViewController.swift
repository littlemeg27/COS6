//
//  WorkoutDetailViewController.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 7/9/25.
//


import UIKit
import Foundation

class WorkoutDetailViewController: UIViewController, UITableViewDataSource
{
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var coachLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var workout: SwimWorkout?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SegmentCell")
        
        if let workout = workout
        {
            nameLabel.text = workout.name
            coachLabel.text = workout.coach?.name ?? "None"
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton)
    {
        navigationController?.popViewController(animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        guard let workout = workout else { return 0 }
        switch section
        {
            case 0: return workout.warmUp.count
            case 1: return workout.mainSet.count
            case 2: return workout.coolDown.count
            default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        switch section
        {
            case 0: return "Warm Up"
            case 1: return "Main Set"
            case 2: return "Cool Down"
            default: return nil
        }
    }
    
