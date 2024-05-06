//
//  CreatePoll.swift
//  Ranger
//
//  Created by Vlad Kyrylenko on 18.03.2024.
//

import SwiftUI

struct CreatePollView: View {
    var fromProfile: Bool = false
    
//    @State var pollName: String = ""
//    @State var pollPassword: String  = ""
//    @State var isClosed: Bool = false
    @State var imageName: String = "lock.open"
//    @State var gradationMin: String = ""
//    @State var gradationMax: String = ""
//    @State var alternatives: [String] = [""]
    
    @State var poll: PollModel = PollModel(
        id: "",
        creatorId: "",
        name: "",
        isClosed: false,
        password: "",
        alternatives: [""],
        statistics: [],
        experts: [],
        gradationMin: "",
        gradationMax: ""
    )
    
    @State var showAlert: Bool = false
    
    @State var alertType: AlertType = .updateSuccessfull
    
    @State var fillAllFieldsAlert: Bool = false
    
    @State var showUpdateAlert: Bool = false
    @State var isUpdateSuccessfull: Bool = false
    
    
    var databaseManager = DatabaseManager.shared
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        
        if databaseManager.isAnonymous{
            VStack{
                Text("Please create account with email to acces this")
            }
        } else {
            VStack{
                List {
                    Section {
                        HStack{
                            TextField(text: $poll.name) {
                                Text("Enter poll name")
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .textFieldStyle(.roundedBorder)
                            
                            VStack {
                                Image(systemName: imageName)
                                    .onTapGesture {
                                        poll.isClosed = !poll.isClosed
                                        
                                        withAnimation(){
                                            if poll.isClosed {
                                                imageName = "lock"
                                            } else {
                                                imageName = "lock.open"
                                            }
                                            
                                        }
                                    }
                                
                            }
                        }
                        if poll.isClosed {
                            HStack{
                                TextField(text: $poll.password) {
                                    Text("Enter password for poll")
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .textFieldStyle(.roundedBorder)
                            }
                        }
                    }
                    .listRowSeparator(.hidden)
                    
                    Section {
                        HStack {
                            TextField("Least important", text: $poll.gradationMin)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .textFieldStyle(.roundedBorder)
                            
                            TextField("Most important", text: $poll.gradationMax)
                                .padding(.horizontal, 10)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                    } header: {
                        Text("Gradation extremums")
                    }
                }
                .listStyle(.plain)
                .scrollDisabled(true)
                .frame(height: CGFloat(poll.isClosed ? 250 : 180))
                
                List {
                    Section{
                        ForEach(0 ..< poll.alternatives.count, id: \.self) { index in
                            HStack {
                                TextField("Enter alternative", text: $poll.alternatives[index])
                                    .textFieldStyle(.roundedBorder)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .onSubmit {
                                        if poll.alternatives[index] != "" {
                                            poll.alternatives.append("")
                                        }
                                    }
                                    .submitLabel(.done)
                                    .autocorrectionDisabled()
                                
                                
                                
                                if poll.alternatives[index].isEmpty {
                                    Image(systemName: "trash")
                                        .foregroundStyle(.red)
                                        .onTapGesture {
                                            poll.alternatives.remove(at: index)
                                        }
                                } else {
                                    Image(systemName: "delete.left")
                                        .foregroundStyle(.red)
                                        .onTapGesture {
                                            poll.alternatives[index] = ""
                                            
                                        }
                                }
                            }
                        }
                        
                        HStack {
                            Spacer()
                            
                            Image(systemName: "plus")
                                .foregroundStyle(.blue)
                                .onTapGesture {
                                    poll.alternatives.append("")
                                }
                            
                            Spacer()
                        }
                    } header: {
                        Text("Alternatives")
                    }
                    
                }
                .listStyle(.plain)
                
                Spacer()
                
                Button("Submit") {
                    hideKeyboard()
                    poll.alternatives.removeAll(where: {$0 == ""})
                    
                    if fromProfile {
                        databaseManager.updatePollInfo(poll: poll)
                        dismiss()
                    } else {
                        if poll.name.isEmpty {
                            alertType = .fillInPollName
                            showAlert = true
                        } else if poll.isClosed && poll.password.isEmpty {
                            alertType = .fillInPollPassword
                            showAlert = true
                        } else if poll.alternatives.count < 3 {
                            alertType = .addMoreAlternatives
                            showAlert = true
                        } else {
                            if poll.gradationMin.isEmpty && poll.gradationMax.isEmpty {
                                if databaseManager.createPoll(name: poll.name, isClosed: poll.isClosed, password: poll.password, alternatives: poll.alternatives) {
                                    
                                    alertType = .updateSuccessfull
                                    showAlert = true
                                } else {
                                    alertType = .updateNotSuccessfull
                                    showAlert = true
                                }
                            } else if poll.gradationMin.isEmpty || poll.gradationMax.isEmpty {
                                alertType = .fillAllCustomGradationExtremums
                                showAlert = true
                            } else if !poll.gradationMin.isEmpty && !poll.gradationMax.isEmpty{
                                if databaseManager.createPoll(name: poll.name, isClosed: poll.isClosed, password: poll.password, alternatives: poll.alternatives, gradationMin: poll.gradationMin, gradationMax: poll.gradationMax) {
                                    
                                    alertType = .updateSuccessfull
                                    showAlert = true
                                } else {
                                    alertType = .updateNotSuccessfull
                                    showAlert = true
                                }
                            }
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding(10)
            }
            .alert(isPresented: $showAlert, content: {
                switch alertType {
                case .fillAllCustomGradationExtremums:
                    Alert(title: Text("Error"),
                          message: Text("Please set all custom gradation extermums"),
                          dismissButton: .default(Text("Ok")))
                case .updateSuccessfull:
                    Alert(title: Text("Nice!"),
                          message: Text("Poll created successfully"),
                          dismissButton: .default(Text("Ok")){
                        clearAllFields()
                    })
                case .fillInPollName:
                    Alert(title: Text("Error"),
                          message: Text("Please, fill in poll name"),
                          dismissButton: .default(Text("Ok")))
                case .fillInPollPassword:
                    Alert(title: Text("Error"),
                          message: Text("Please, fill in password"),
                          dismissButton: .default(Text("Ok")))
                case .updateNotSuccessfull:
                    Alert(title: Text("Ups..."),
                          message: Text("Something went wrong("),
                          dismissButton: .default(Text("Ok")))
                case .addMoreAlternatives:
                    Alert(title: Text("Error"),
                          message: Text("Please, add more alternatives"),
                          dismissButton: .default(Text("Ok")))
                }
            })
            .contentShape(Rectangle())
            .onTapGesture {
                self.hideKeyboard()
            }
            
        }
    }
    
    func clearAllFields() {
        poll.name = ""
        poll.password = ""
        poll.isClosed = false
        imageName = "lock.open"
        poll.gradationMax = ""
        poll.gradationMin = ""
        poll.alternatives = [""]
    }
}

enum AlertType {
    case fillAllCustomGradationExtremums
    case updateSuccessfull
    case fillInPollName
    case fillInPollPassword
    case updateNotSuccessfull
    case addMoreAlternatives
}

#Preview {
    CreatePollView()
}
