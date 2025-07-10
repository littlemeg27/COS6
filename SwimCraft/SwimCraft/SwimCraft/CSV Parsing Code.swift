//
//  CSV Parsing Code.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 7/9/25.
//

import Foundation

func loadCoaches(from fileName: String) -> [Coach]
{
    var coaches: [Coach] = []
    guard let filePath = Bundle.main.path(forResource: fileName, ofType: "csv")
    else
    {
        return []
}
    do
    {
        let content = try String(contentsOfFile: filePath)
        let rows = content.components(separatedBy: .newlines).dropFirst()
        
        for row in rows where !row.isEmpty
        {
            let columns = row.components(separatedBy: ",")
            
            if columns.count == 6
            {
                let coach = Coach(
                    name: columns[0].trimmingCharacters(in: .whitespaces),
                    level: columns[1].trimmingCharacters(in: .whitespaces),
                    dateCompleted: columns[2].trimmingCharacters(in: .whitespaces),
                    clubAbbr: columns[3].trimmingCharacters(in: .whitespaces),
                    clubName: columns[4].trimmingCharacters(in: .whitespaces),
                    lmsc: columns[5].trimmingCharacters(in: .whitespaces)
                )
                coaches.append(coach)
            }
        }
    }
    catch
    {
        print("Error reading CSV: \(error)")
    }
    return coaches
}
