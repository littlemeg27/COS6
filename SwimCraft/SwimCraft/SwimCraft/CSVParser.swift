//
//  CSVParser.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 7/9/25.
//

import Foundation

func loadCoaches(from fileName: String) -> [Coach]
{
    var coaches: [Coach] = []
    guard let filePath = Bundle.main.path(forResource: fileName, ofType: "csv") else
    {
        print("CSV file '\(fileName).csv' not found in bundle")
        return []
    }
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    
    do
    {
        let content = try String(contentsOfFile: filePath, encoding: .utf8)
        let rows = content.components(separatedBy: .newlines).dropFirst()
        
        for row in rows where !row.isEmpty
        {
            let columns = row.components(separatedBy: ",")
            
            if columns.count == 6
            {
                guard let dateCompleted = dateFormatter.date(from: columns[2].trimmingCharacters(in: .whitespaces)) else
                {
                    print("Invalid date format in row: \(row)")
                    continue
                }
                let coach = Coach(
                    name: columns[0].trimmingCharacters(in: .whitespaces),
                    level: columns[1].trimmingCharacters(in: .whitespaces),
                    dateCompleted: dateCompleted,
                    clubAbbr: columns[3].trimmingCharacters(in: .whitespaces),
                    clubName: columns[4].trimmingCharacters(in: .whitespaces),
                    lmsc: columns[5].trimmingCharacters(in: .whitespaces)
                )
                coaches.append(coach)
            }
            else
            {
                print("Invalid row format: \(row)")
            }
        }
    }
    catch
    {
        print("Error reading CSV: \(error)")
    }
    return coaches
}
