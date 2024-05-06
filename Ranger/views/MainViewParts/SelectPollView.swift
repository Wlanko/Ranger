//
//  SelectPoll.swift
//  Ranger
//
//  Created by Vlad Kyrylenko on 18.03.2024.
//

import SwiftUI

struct SelectPollView: View {
    @ObservedObject var databaseManager = DatabaseManager.shared
    @State var expertName: String = ""
    @State var searchField: String = ""
    @State var searchBy: SearchOptions = .name
    @State var shelfNumber: Int = 3
    @State var passwordField: String = ""
    @State var expertNameIsEmpty: Bool = false
    
    @State var arr: [[String]] = [[],[],[]]
    
    let shelfNumberOptions: [Int] = [3, 5, 7, 9]
    let searchOptions: [SearchOptions] = [.id, .name]
    
    var body: some View {
        NavigationView {
            VStack{
                VStack {
                    TextField(!databaseManager.isAnonymous ? databaseManager.currentUserInfo.expertName : "Expert name", text: $expertName)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit {
                            hideKeyboard()
                        }
                    
                    
                    HStack{
                        TextField("Search", text: $searchField)
                            .padding(.leading, 10)
                            .padding(.vertical, 5)
                            .textFieldStyle(.roundedBorder)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .onSubmit {
                                hideKeyboard()
                            }
                        
                        Text("By")
                        
                        Picker("Sort by", selection: $searchBy) {
                            ForEach (searchOptions, id: \.self) { option in
                                Text(option.rawValue)
                                    .tag(option)
                            }
                        }
                        .overlay(content: {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(lineWidth: 0.5)
                                .foregroundStyle(.gray)
                                .opacity(0.3)
                        })
                        .pickerStyle(.menu)
                        .padding(.trailing, 10)
                        .padding(.vertical, 5)
                        
                    }
                    
                    HStack {
                        Text("Number of shelfs")
                            .padding(.leading, 10)
                            .padding(.vertical, 5)
                            .foregroundStyle(.gray)
                            .opacity(0.5)
                        Spacer()
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    hideKeyboard()
                }
                Picker("Sort by", selection: $shelfNumber) {
                    ForEach (shelfNumberOptions, id: \.self) { option in
                        Text("\(option)")
                            .tag(option)
                    }
                }
                .overlay(content: {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(lineWidth: 0.5)
                        .foregroundStyle(.gray)
                        .opacity(0.3)
                })
                .pickerStyle(.segmented)
                .padding(.horizontal, 10)
                .onChange(of: shelfNumber) { oldValue, newValue in
                    arr = createArray()
                }
                
                
                List {
                    Section {
                        if databaseManager.polls.count > 0 {
                            ForEach(searchField.isEmpty ? databaseManager.polls : databaseManager.polls.filter({ poll in
                                switch searchBy {
                                case .id:
                                    poll.id.contains(searchField)
                                case .name:
                                    poll.name.contains(searchField)
                                case .creator:
                                    poll.creatorId.contains(searchField)
                                }
                            }), id: \.self) { poll in
                                NavigationLink {
                                    PollExecution(poll: poll, expertName: !databaseManager.isAnonymous ? databaseManager.currentUserInfo.expertName : expertName.isEmpty ? "Unknown" : expertName, ratingFields: arr, isClosed: poll.isClosed)
                                    
                                } label: {
                                    PollCellView(poll: poll)
                                }
                            }
                        } else {
                            HStack {
                                Spacer()
                                
                                Text("No polls were created yet")
                                    .foregroundStyle(.gray)
                                    .opacity(0.3)
                                
                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .listRowSeparator(.hidden, edges: .bottom)
                        }
                    } header: {
                        Text("Select poll")
                    }
                }
                .listStyle(.plain)
                .onAppear(){
                    self.databaseManager.getPolls()
                }
                .alert(isPresented: $expertNameIsEmpty) {
                    Alert(title: Text("Error"), message: Text("Enter expert name"), dismissButton: .cancel())
                }
                
                Spacer()
            }
        }
    }
    func createArray() -> [[String]] {
        arr = []
        for _ in 0 ..< shelfNumber {
            arr.append([])
        }
        
        return arr
    }
}

enum SearchOptions: String {
    case id = "id"
    case name = "name"
    case creator = "creator"
}

#Preview {
    SelectPollView()
}
