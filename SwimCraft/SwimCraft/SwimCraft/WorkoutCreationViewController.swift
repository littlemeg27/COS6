//
//  WorkoutCreationViewController.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 7/17/25.
//

import UIKit
import SharedModule

class WorkoutCreationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate
{
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var nameTextField: UITextField?
    @IBOutlet weak var coachPicker: UIPickerView?
    @IBOutlet weak var saveButton: UIButton?
    
    var coaches: [Coach] = []
    var selectedCoach: Coach?
    var warmUpSegments: [WorkoutSegment] = []
    var mainSetSegments: [WorkoutSegment] = []
    var coolDownSegments: [WorkoutSegment] = []
    var onSave: ((SwimWorkout) -> Void)?
    
    let segmentTypes = ["Drill", "Swim", "Kick", "Pull", "Sprint", "Easy", "Fins"]
    let strokeTypes = ["Freestyle", "Backstroke", "Breaststroke", "Butterfly", "Individual Medley", "Not Free Style", "Choice"]
    let timeOptions: [TimeInterval] = [30, 60, 90, 120, 180]
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("WorkoutCreationViewController viewDidLoad started")
        
        // Check outlets
        guard tableView != nil else {
            print("Error: tableView outlet is nil")
            showErrorAlert(message: "Table view is not connected in storyboard")
            return
        }
        guard nameTextField != nil else {
            print("Error: nameTextField outlet is nil")
            showErrorAlert(message: "Name text field is not connected in storyboard")
            return
        }
        guard coachPicker != nil else {
            print("Error: coachPicker outlet is nil")
            showErrorAlert(message: "Coach picker is not connected in storyboard")
            return
        }
        guard saveButton != nil else {
            print("Error: saveButton outlet is nil")
            showErrorAlert(message: "Save button is not connected in storyboard")
            return
        }
        
        // Configure tableView
        print("Configuring tableView")
        tableView!.dataSource = self
        tableView!.delegate = self
        
        // Configure coachPicker
        print("Configuring coachPicker, isEnabled: \(coachPicker!.isUserInteractionEnabled)")
        coachPicker!.dataSource = self
        coachPicker!.delegate = self
        coachPicker!.isUserInteractionEnabled = true
        
        // Load coaches
        print("Attempting to load coaches")
        do {
            coaches = try loadCoaches(from: "CertifiedCoaches")
            print("Successfully loaded \(coaches.count) coaches: \(coaches.map { $0.name })")
        } catch {
            print("Error loading coaches: \(error)")
            coaches = [Coach(name: "Default Coach", level: "Level 1", dateCompleted: Date(), clubAbbr: "", clubName: "", lmsc: "")]
        }
        
        if coaches.isEmpty {
            print("Warning: No coaches loaded, using default")
            coaches = [Coach(name: "Default Coach", level: "Level 1", dateCompleted: Date(), clubAbbr: "", clubName: "", lmsc: "")]
        }
        
        selectedCoach = coaches.first
        if let firstIndex = coaches.firstIndex(where: { $0.name == coaches.first?.name }) {
            print("Selecting coach at index \(firstIndex)")
            coachPicker!.selectRow(firstIndex, inComponent: 0, animated: false)
        }
        
        print("Reloading coachPicker components")
        coachPicker!.reloadAllComponents()
        
        // Initialize segments
        print("Initializing default segments")
        warmUpSegments.append(WorkoutSegment(yards: 0, type: segmentTypes[0], amount: 1, stroke: strokeTypes[0], time: timeOptions[0]))
        mainSetSegments.append(WorkoutSegment(yards: 0, type: segmentTypes[0], amount: 1, stroke: strokeTypes[0], time: timeOptions[0]))
        coolDownSegments.append(WorkoutSegment(yards: 0, type: segmentTypes[0], amount: 1, stroke: strokeTypes[0], time: timeOptions[0]))
        
        print("nameTextField: \(nameTextField!.text ?? "nil"), isEnabled: \(nameTextField!.isEnabled)")
        print("coachPicker: set, isEnabled: \(coachPicker!.isUserInteractionEnabled)")
        print("saveButton: \(saveButton!.titleLabel?.text ?? "nil"), isEnabled: \(saveButton!.isEnabled)")
        print("WorkoutCreationViewController viewDidLoad completed")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("WorkoutCreationViewController viewDidAppear, coachPicker frame: \(coachPicker?.frame ?? CGRect.zero)")
    }
    
    private func showErrorAlert(message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(alert, animated: true)
            } else {
                print("Error: Cannot present alert, no root view controller")
            }
        }
    }
    
    private func loadCoaches(from resource: String) throws -> [Coach]
    {
        print("loadCoaches: Looking for \(resource).csv")
        guard let url = Bundle.main.url(forResource: resource, withExtension: "csv") else
        {
            print("Error: Could not find \(resource).csv in bundle")
            throw NSError(domain: "SwimCraft", code: -1, userInfo: [NSLocalizedDescriptionKey: "Coach resource not found"])
        }
        print("loadCoaches: Found file at \(url)")
        let data = try String(contentsOf: url, encoding: .utf8)
        print("loadCoaches: Loaded \(data.count) characters of data")
        
        var coaches: [Coach] = []
        let rows = data.components(separatedBy: .newlines).filter { !$0.isEmpty }
        guard !rows.isEmpty else
        {
            print("Error: CSV file is empty")
            throw NSError(domain: "SwimCraft", code: -2, userInfo: [NSLocalizedDescriptionKey: "CSV file is empty"])
        }
        
        let expectedHeader = ["Coach", "Level", "Date Completed", "Club Abbr", "Club Name", "LMSC"]
        let header = rows[0].components(separatedBy: ",")
        guard header == expectedHeader else
        {
            print("Error: Invalid CSV header: \(header)")
            throw NSError(domain: "SwimCraft", code: -3, userInfo: [NSLocalizedDescriptionKey: "Invalid CSV header"])
        }
        
        for row in rows.dropFirst()
        {
            let columns = row.components(separatedBy: ",")
            guard columns.count == 6 else
            {
                print("Warning: Skipping invalid row: \(row)")
                continue
            }
            
            let name = columns[0].trimmingCharacters(in: .whitespaces)
            let level = columns[1].trimmingCharacters(in: .whitespaces)
            let dateString = columns[2].trimmingCharacters(in: .whitespaces)
            let clubAbbr = columns[3].trimmingCharacters(in: .whitespaces)
            let clubName = columns[4].trimmingCharacters(in: .whitespaces)
            let lmsc = columns[5].trimmingCharacters(in: .whitespaces)
            
            guard !name.isEmpty, !level.isEmpty, let date = dateFormatter.date(from: dateString) else
            {
                print("Warning: Skipping invalid coach data: \(row)")
                continue
            }
            
            let coach = Coach(name: name, level: level, dateCompleted: date, clubAbbr: clubAbbr, clubName: clubName, lmsc: lmsc)
            coaches.append(coach)
        }
        
        print("loadCoaches: Parsed \(coaches.count) coaches")
        return coaches
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        print("coachPicker numberOfComponents: 1")
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        print("coachPicker numberOfRows: \(coaches.count)")
        return coaches.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        guard row < coaches.count else
        {
            print("Error: Invalid row \(row) for coaches count \(coaches.count)")
            return nil
        }
        let coach = coaches[row]
        let title = "\(coach.name) (\(coach.level))"
        print("coachPicker titleForRow \(row): \(title)")
        return title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        guard row < coaches.count else
        {
            print("Error: Invalid row \(row) selected for coaches count \(coaches.count)")
            return
        }
        selectedCoach = coaches[row]
        print("Selected coach: \(coaches[row].name)")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        print("numberOfSections: 3")
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let count: Int
        switch section {
        case 0: count = warmUpSegments.count + 1
        case 1: count = mainSetSegments.count + 1
        case 2: count = coolDownSegments.count + 1
        default: count = 0
        }
        print("numberOfRowsInSection \(section): \(count)")
        return count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        let title: String?
        switch section {
        case 0: title = "Warm Up"
        case 1: title = "Main Set"
        case 2: title = "Cool Down"
        default: title = nil
        }
        print("titleForHeaderInSection \(section): \(title ?? "nil")")
        return title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let section = indexPath.section
        let row = indexPath.row
        let segments = section == 0 ? warmUpSegments : section == 1 ? mainSetSegments : coolDownSegments
        
        if row < segments.count
        {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutSegmentCell", for: indexPath) as? WorkoutCreationTableViewCell else
            {
                print("Error: Failed to dequeue WorkoutCreationTableViewCell at \(indexPath)")
                return UITableViewCell()
            }
            let segment = segments[row]
            cell.configure(with: segment, types: segmentTypes, strokes: strokeTypes, times: timeOptions)
            
            cell.onUpdate =
            {
                [weak self] updatedSegment in
                
                if section == 0
                {
                    self?.warmUpSegments[row] = updatedSegment
                }
                else if section == 1
                {
                    self?.mainSetSegments[row] = updatedSegment
                }
                else
                {
                    self?.coolDownSegments[row] = updatedSegment
                }
                print("Updated segment in section \(section), row \(row): \(updatedSegment)")
            }
            print("Configured WorkoutSegmentCell at \(indexPath)")
            return cell
        }
        else
        {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddButtonCell", for: indexPath) as? AddButtonCell else
            {
                print("Error: Failed to dequeue AddButtonCell at \(indexPath)")
                return UITableViewCell()
            }
            print("Configured AddButtonCell at \(indexPath)")
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        let section = indexPath.section
        let row = indexPath.row
        let segments = section == 0 ? warmUpSegments : section == 1 ? mainSetSegments : coolDownSegments
        
        if row == segments.count
        {
            let newSegment = WorkoutSegment(yards: 0, type: segmentTypes[0], amount: 1, stroke: strokeTypes[0], time: timeOptions[0])
            
            if section == 0
            {
                warmUpSegments.append(newSegment)
            }
            else if section == 1
            {
                mainSetSegments.append(newSegment)
            }
            else
            {
                coolDownSegments.append(newSegment)
            }
            tableView.insertRows(at: [IndexPath(row: row, section: section)], with: .automatic)
            print("Added new segment in section \(section): \(newSegment)")
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton)
    {
        guard let nameTextField = nameTextField, let name = nameTextField.text, !name.isEmpty else
        {
            print("Error: Workout name is empty")
            showErrorAlert(message: "Please enter a workout name")
            return
        }
        
        let validSegments = [warmUpSegments, mainSetSegments, coolDownSegments].flatMap { $0 }.filter { ($0.yards ?? 0) > 0 }
        guard !validSegments.isEmpty else
        {
            print("Error: No valid segments")
            showErrorAlert(message: "Please add at least one valid segment with non-zero yards")
            return
        }
        
        let workout = SwimWorkout(
            id: UUID(),
            name: name,
            coach: selectedCoach,
            warmUp: warmUpSegments,
            mainSet: mainSetSegments,
            coolDown: coolDownSegments,
            createdViaWorkoutKit: false,
            source: nil,
            date: Date()
        )
        print("Saving workout: \(workout.name), distance: \(workout.distance), duration: \(workout.duration), strokes: \(workout.strokes)")
        
        PersistenceController.shared.saveWorkout(workout) // Save to Core Data
        
        HealthKitManager.shared.saveWorkoutToHealthKit(workout: workout) { success, error in
            if success
            {
                print("Successfully saved to HealthKit")
            }
            else
            {
                print("Error saving to HealthKit: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
        
        onSave?(workout)
        onSave = nil
        if let navigationController = navigationController
        {
            print("Popping to WorkoutListViewController")
            navigationController.popViewController(animated: true)
        }
        else
        {
            print("Error: navigationController is nil in saveButtonTapped")
            showErrorAlert(message: "Cannot return to previous screen. Please ensure navigation controller is set.")
        }
    }
}
