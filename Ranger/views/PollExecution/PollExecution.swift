//
//  PollExecution.swift
//  Ranger
//
//  Created by Vlad Kyrylenko on 25.03.2024.
//

import SwiftUI

struct PollExecution: View {
    var poll: PollModel
    let expertName: String
    let pollExecutionModel = PollExecutionModel()
    let databaseManager = DatabaseManager.shared
    @State var ratingFields: [[String]]
    @State var finished: Bool = false
    @State var isClosed: Bool
    @State var password: String = ""
    
    var body: some View {
        if isClosed && databaseManager.currentUserId != "hYTzVVTJe4WWgwqS89mqpTCSlGs2" {
            PasswordView(refPassword: poll.password, isClosed: $isClosed)
        } else {
            if finished {
                StatisticsView(statistics: pollExecutionModel.statistics, poll: poll, numberOfShelfs: ratingFields.count)
            } else {
                RangingProcess(poll: poll, pollExecutionModel: pollExecutionModel, expertName: self.expertName, ratingFields: ratingFields, finished: $finished)
                    
            }
        }
    }
    
    func cleanShelfs() {
        for id in 0 ..< ratingFields.count {
            ratingFields[id].removeAll()
        }
    }
}

struct PasswordView: View {
    let refPassword: String
    @Binding var isClosed: Bool
    @State var password: String = ""
    
    var body: some View {
        Text("This poll is closed")
        Text("Please enter password to continue")
        
        TextField(text: $password) {
            Text("Enter password")
        }
        .padding(.horizontal, 10)
        .textFieldStyle(.roundedBorder)
        .autocapitalization(.none)
        .autocorrectionDisabled()
        .onSubmit {
            if password == refPassword {
                isClosed = false
            }
        }
        
        Spacer()
        
        Button("Continue") {
            if password == refPassword {
                isClosed = false
            }
        }
        .buttonStyle(.borderedProminent)
        .padding(10)
    }
}

struct RangingProcess: View {
    @State var poll: PollModel
    let pollExecutionModel: PollExecutionModel
    let databaseManager = DatabaseManager.shared
    let expertName: String
    @State var ratingFields: [[String]]
    @Binding var finished: Bool
    @State var selectedTapAlternative: String = ""
    
    @State var allAlternativeCombinations: [[String]] = [[]]
    @State var step: Int = 0
    @State var showRangeAllAlternativesAlert: Bool = false
    
    var body: some View {
        VStack{
            HStack {
                Text("Step: \(step+1)/\(allAlternativeCombinations.count)")
                    .padding(10)
                
                Spacer()
                
                Text("Accuracy: \(Int(Float(step) / Float(allAlternativeCombinations.count)*100))%")
                
                Spacer()
                
                NavigationLink("Stop", destination: StatisticsView(statistics: pollExecutionModel.statistics, poll: poll, numberOfShelfs: ratingFields.count))
                    .buttonStyle(.bordered)
                    .padding(10)
            }
            
            ForEach($ratingFields.indices) { id in
                
                ZStack {
                    if ratingFields[id].isEmpty && id == 0{
                        Text(poll.gradationMax)
                            .foregroundStyle(.gray)
                    }
                    
                    if ratingFields[id].isEmpty && id == ratingFields.count - 1 {
                        Text(poll.gradationMin)
                            .foregroundStyle(.gray)
                    }
                    
                    ScrollView(.horizontal) {
                        HStack{
                            ForEach ($ratingFields[id], id:  \.self) { $alternative in
                                Text(alternative)
                                    .frame(maxHeight: .infinity)
                                    .padding(10)
                                    .overlay(content: {
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(selectedTapAlternative == alternative ? .indigo : .teal, lineWidth: 2)
                                    })
                                    .background(Color(.systemBackground))
                                    .draggable(alternative)
                                    .onTapGesture {
                                        if selectedTapAlternative != alternative {
                                            selectedTapAlternative = alternative
                                        } else {
                                            selectedTapAlternative = ""
                                        }
                                    }
                            }
                        }
                        
                    }
                    .frame(maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .padding(10)
                    .dropDestination(for: String.self) { droppedItems, location in
                        for task in droppedItems {
                            for l in 0..<ratingFields.count {
                                ratingFields[l].removeAll { $0 == task }
                            }
                            allAlternativeCombinations[step].removeAll{$0 == task}
                        }
                        
                        ratingFields[id] += droppedItems
                        
                        return true
                    }
                    .overlay(content: {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.gray, lineWidth: 1)
                            .padding(.horizontal, 5)
                    })
                    .onTapGesture {
                        if !selectedTapAlternative.isEmpty {
                            for l in 0..<ratingFields.count {
                                ratingFields[l].removeAll { $0 == selectedTapAlternative }
                            }
                            allAlternativeCombinations[step].removeAll{ $0 == selectedTapAlternative }
                            
                            ratingFields[id].append(selectedTapAlternative)
                            
                            selectedTapAlternative = ""
                        }
                    }
                }
            }
            
            ScrollView(.horizontal){
                HStack {
                        
                        ForEach ($allAlternativeCombinations[step], id:  \.self) { $alternative in
                            Text(alternative)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .overlay(content: {
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(selectedTapAlternative == alternative ? .indigo : .teal, lineWidth: 2)
                                })
                                .draggable(alternative)
                                .onTapGesture {
                                    if selectedTapAlternative != alternative {
                                        selectedTapAlternative = alternative
                                    } else {
                                        selectedTapAlternative = ""
                                    }
                                }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 30)
                .padding(10)
            }
            .contentShape(Rectangle())
            .frame(maxWidth: .infinity, maxHeight: 45)
            .padding(10)
            .overlay(content: {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(.green, lineWidth: 1)
                    .padding(.horizontal, 5)
            })
            
            
            Button() {
                if allAlternativeCombinations[step].isEmpty {
                    
                    pollExecutionModel.updateStatistics(alternatives: poll.alternatives, rangingResult: ratingFields)
                    
                    if step + 1 < allAlternativeCombinations.count {
                        step += 1
                        cleanShelfs()
                    } else {
                        updatePoll()
                        databaseManager.updatePollInfo(poll: poll)
                        finished = true
                    }
                } else {
                    showRangeAllAlternativesAlert = true
                }
                
            } label: {
                Text("Submit")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(10)
            .alert(isPresented: $showRangeAllAlternativesAlert, content: {
                Alert(title: Text("Error"), message: Text("Please, place all sugested alternatives in shelfs"), dismissButton: .cancel())
            })
            
        }
        .contentShape(Rectangle())
        .onAppear() {
            var createAlternatives = true
            for shelf in ratingFields {
                if !shelf.isEmpty {
                    createAlternatives = false
                }
            }
            if createAlternatives {
                allAlternativeCombinations = pollExecutionModel.getAllCombinations(alternatives: poll.alternatives)
            }
        }
        .navigationTitle("\(poll.name)")
    }
    
    func cleanShelfs() {
        for id in 0 ..< ratingFields.count {
            ratingFields[id].removeAll()
        }
        selectedTapAlternative = ""
    }
    
    func updatePoll() {
        let stats: [Float] = StatisticsViewModel().getTotalStats(array: pollExecutionModel.statistics)
        
        poll.experts.append(expertName)
        poll.statistics.append(arrayToString(from: stats))
    }
    
    func arrayToString(from array: [Float]) -> String {
        var str = ""
        for value in array {
            str += " \(value)"
        }
        
        return str
    }
}

#Preview {
    PollExecution(poll: PollModel(id: "someid", creatorId: "somecreatorId", name: "Test", isClosed: false, password: "", alternatives: ["alt1","alt2","alt3","alt4","alt5"], statistics: [], experts: [], gradationMin: "min", gradationMax: "max"), expertName: "Some Expert", ratingFields: [[],[],[],[],[]], isClosed: false)
}
