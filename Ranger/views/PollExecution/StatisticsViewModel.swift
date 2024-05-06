//
//  StatisticsViewModel.swift
//  Ranger
//
//  Created by Vlad Kyrylenko on 21.04.2024.
//

import Foundation

class StatisticsViewModel {
    func getTotalStats(array: [[Float]]) -> [Float] {
        var answer: [Float] = []
        
        for i in array {
            answer.append(i.reduce(.zero, +))
        }
        
        return answer
    }
    
    func getTotalStatsForCreator(from array: [[Float]]) -> [Float] {
        var answer: [Float] = array[0]
        
        for altId in 0 ..< answer.count {
            for arrayId in 1 ..< array.count {
                answer[altId] += array[arrayId][altId]
            }
        }
        
        return answer
    }
    
    func getSingleValues(array: [[Float]], step: Int) -> [Float] {
        var answer: [Float] = []
        
        for i in array {
            answer.append(i[step])
        }
        
        return answer
    }
}
