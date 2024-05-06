//
//  PollExecutionModel.swift
//  Ranger
//
//  Created by Vlad Kyrylenko on 26.03.2024.
//

import Foundation
import Algorithms

class PollExecutionModel {
    var statistics: [[Float]] = []
    var count = 0
    
    func getAllCombinations(alternatives: [String]) -> [[String]] {
        var allCombinations: [[String]] = []
        
        for combination in alternatives.combinations(ofCount: 3) {
            allCombinations.append(combination.shuffled())
        }
        
        return allCombinations
    }
    
    func updateStatistics(alternatives: [String], rangingResult: [[String]]) {
        if statistics.isEmpty {
            fillStatistics(range: alternatives.count)
        }
        
        count += 1
        
        for shelfId in 0..<rangingResult.count {
            for alternative in rangingResult[shelfId] {
                if let id = alternatives.firstIndex(of: alternative) {
                    statistics[id].append(getModifier(id: shelfId, range: rangingResult.count))
                }
            }
        }
        
        fillZeroes()
    }
    
    func fillZeroes() {
        for id in 0 ..< statistics.count {
            if statistics[id].count < count {
                statistics[id].append(0.0)
            }
        }
        
        print(statistics)
    }
    
    func fillStatistics(range: Int) {
        for _ in 0 ..< range {
            statistics.append([])
        }
    }
    
    func getModifier(id: Int, range: Int) -> Float{
        let mid = Int((Float(range)/2).rounded())
        
        if id+1 < mid {
            return 1 / Float(id + 1)
        } else if id+1 == mid {
            return 0
        } else {
            return 1 / Float(id - range)
        }
    }
}
