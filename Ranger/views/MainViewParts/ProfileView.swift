//
//  ProfileView.swift
//  Ranger
//
//  Created by Vlad Kyrylenko on 18.03.2024.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var databaseManager = DatabaseManager.shared
   
    @State var searchField: String = ""
    @State var searchBy: SearchOptions = .name
    @State var expertName: String = ""
    @State var activateEditLink: Bool = false
    @State var presentDeletePollAlert: Bool = false
    @State var presentDeleteAccountAlert: Bool = false
    
    @State var navigationPoll: PollModel = PollModel(id: "", creatorId: "", name: "", isClosed: false, password: "", alternatives: [], statistics: [], experts: [], gradationMin: "", gradationMax: "")
    
    let shelfNumberOptions: [Int] = [3, 5, 7, 9]
    let searchOptions: [SearchOptions] = [.id, .name]
    
    var body: some View {
        if databaseManager.isAnonymous{
            VStack{
                Text("Please create account with email to acces this")
                Spacer()
                Button {
                    databaseManager.deleteAnonim()
                } label: {
                    Text("Sign Out")
                }
                .padding(.vertical, 7)
                .padding(.horizontal, 10)
                .background(.ultraThinMaterial)
                .cornerRadius(5)
            }
        } else {
            NavigationStack {
                VStack{
                    HStack{
                        TextField(!databaseManager.isAnonymous ? databaseManager.currentUserInfo.expertName : "Expert name", text: $expertName)
                            .padding(.leading, 10)
                            .padding(.vertical, 5)
                            .textFieldStyle(.roundedBorder)
                        Button("Save") {
                            if !expertName.isEmpty {
                                databaseManager.currentUserInfo.expertName = expertName
                                databaseManager.updateUserInfo(user: databaseManager.currentUserInfo)
                            }
                        }
                        .padding(.vertical, 7)
                        .padding(.horizontal, 10)
                        .background(.ultraThinMaterial)
                        .cornerRadius(5)
                        .padding(.trailing, 10)
                    }
                    
                    HStack{
                        TextField("Search by name", text: $searchField)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .textFieldStyle(.roundedBorder)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                        
                    }
                    
                    List {
                        Section {
                            if databaseManager.polls.count > 0 {
                                ForEach(searchField.isEmpty ? ( databaseManager.currentUserId == "hYTzVVTJe4WWgwqS89mqpTCSlGs2" ? databaseManager.polls : databaseManager.polls.filter({ poll in
                                    poll.creatorId.contains(databaseManager.currentUserId)
                                })) : databaseManager.polls.filter({ poll in
                                    if databaseManager.currentUserId == "hYTzVVTJe4WWgwqS89mqpTCSlGs2" {
                                        poll.name.contains(searchField)
                                    } else {
                                        poll.creatorId.contains(databaseManager.currentUserId) && poll.name.contains(searchField)
                                    }
                                }), id: \.self) { poll in
                                    NavigationLink() {
                                        StatisticsView(statistics: getStats(from: poll.statistics), poll: poll, fromProfile: true)
                                            .navigationTitle("Statistics")
                                            .navigationBarTitleDisplayMode(.inline)
                                        
                                    } label: {
                                        PollCellView(poll: poll)
                                            .swipeActions() {
                                                Button {
                                                    navigationPoll = poll
                                                    activateEditLink = true
                                                } label: {
                                                    Image(systemName: "pencil")
                                                }
                                                .tint(.green)
                                                
                                                
                                                Button {
                                                    navigationPoll = poll
                                                    presentDeletePollAlert = true
                                                    print("delete")
                                                } label: {
                                                    Image(systemName: "trash")
                                                }
                                                .tint(.red)
                                                
                                            }
                                    }
                                    .alert(isPresented: $presentDeletePollAlert, content: {
                                        Alert(title: Text("Attention"),
                                              message: Text("Are you sure you want to delete this poll?"),
                                              primaryButton: .destructive(Text("Yes")) {databaseManager.deletePoll(pollId: navigationPoll.id)},
                                              secondaryButton: .cancel(Text("No"))
                                              )
                                    })
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
                            Text("Created polls")
                        }
                    }
                    .listStyle(.plain)
                    .onAppear(){
                        self.databaseManager.getPolls()
                    }
                    .navigationDestination(isPresented: $activateEditLink) {
                        
                        CreatePollView(fromProfile: true, imageName: navigationPoll.isClosed ? "lock" : "lock.open", poll: navigationPoll)
                            .navigationTitle("Edit")
                            .navigationBarTitleDisplayMode(.inline)
                        
                    }
                    
                    Button {
                        databaseManager.signOut()
                    } label: {
                        Text("Sign Out")
                    }
                    .padding(.vertical, 7)
                    .padding(.horizontal, 10)
                    .background(.ultraThinMaterial)
                    .cornerRadius(5)
                    
                    
                    Button {
                        presentDeleteAccountAlert = true
                    } label: {
                        Text("Delete account")
                            .foregroundStyle(.red)
                    }
                    .padding(.vertical, 7)
                    .padding(.horizontal, 10)
                    .background(.ultraThinMaterial)
                    .cornerRadius(5)
                    .alert(isPresented: $presentDeleteAccountAlert, content: {
                        Alert(title: Text("Attention"),
                              message: Text("Are you sure you want to delete your account? This will also delete all polls you've created!"),
                              primaryButton: .destructive(Text("Yes")) {databaseManager.deleteAccount()},
                              secondaryButton: .cancel(Text("No"))
                              )
                    })
                }
            }
        }
    }
    
    func getStats(from array: [String]) -> [[Float]]{
        var statistics: [[Float]] = []
        
        for i in array {
            let singleStats: [Float] = i.split(separator: " ").map { value in
                return Float(value) ?? 0.0
            }
            statistics.append(singleStats)
        }
        
        return statistics
    }
    
    enum Destination {
        case edit
        case stats
    }
}

#Preview {
    ProfileView()
}
