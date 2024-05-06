//
//  StatisticsView.swift
//  Ranger
//
//  Created by Vlad Kyrylenko on 15.04.2024.
//

import SwiftUI
import Charts

struct StatisticsView: View {
    @State var statistics: [[Float]]
    @State var poll: PollModel
    var fromProfile: Bool = false
    var statisticsViewModel = StatisticsViewModel()
    var numberOfShelfs: Int = 0
    
    var body: some View {
        if fromProfile {
            if statistics.isEmpty {
                Text("No one has submited answers yet(")
            } else {
                Text("Total values")
                
                ChartView(values: statisticsViewModel.getTotalStatsForCreator(from: statistics), names: poll.alternatives)
            }
        } else {
            ChartView(values: statisticsViewModel.getTotalStats(array: statistics), names: poll.alternatives)
        }
        
        
        ScrollView() {
            VStack {
                if statistics.isEmpty {
                    Text(fromProfile ? "Please wait" : "Please submit some answers)")
                } else {
                    ForEach(fromProfile ? 0 ..< statistics.count : 0 ..< statistics[0].count) { id in
                        Text(fromProfile ? poll.experts[id] : "Step \(id+1)")
                        if fromProfile {
                            ChartView(values: statistics[id], names: poll.alternatives)
                        } else {
                            ChartView(values: statisticsViewModel.getSingleValues(array: statistics, step: id), names: poll.alternatives)
                                .frame(maxHeight: .infinity)
                        }
                    }
                }
            }
        }
        .padding(.bottom, 20)
        .navigationBarTitle("\(poll.name)" + (numberOfShelfs > 0 ? " - \(numberOfShelfs) shelfs" : ""))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ChartView: View {
    @State var values: [Float]
    @State var names: [String]
    
    var body: some View {
        Chart {
            ForEach(0 ..< values.count, id: \.self) { id in
                BarMark(
                    x: .value("Alternative Name", names[id]),
                    y: .value("Total Value", values[id])
                    )
                .foregroundStyle(values[id] < 0 ? .red : .green)
                .annotation {
                    Text(String(format: "%.3f", values[id]))
                        .foregroundStyle(.gray)
                        .font(.system(size: 12))
                }
            }
        }
    }
}



#Preview {
    StatisticsView(statistics: [[1.0, 0.3, -0.1],[0.4, 0.5, 0.1], [0.2, -0.3, 0]], poll: PollModel(id: "someid", creatorId: "somecreatorId", name: "Test", isClosed: false, password: "", alternatives: ["alt1","alt2","alt3"], statistics: [], experts: [], gradationMin: "min", gradationMax: "max"))
}
