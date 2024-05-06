//
//  DatabaseManager.swift
//  Ranger
//
//  Created by Vlad Kyrylenko on 17.03.2024.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

class DatabaseManager: ObservableObject {
    @Published var isLoggined = false {
        didSet {
            self.objectWillChange.send()
        }
    }
    var dataBase = Firestore.firestore()
    
    var isAnonymous = false
    
    @Published var currentUserInfo: UserModel = UserModel(expertName: "", createdPolls: []) {
        didSet {
            self.objectWillChange.send()
        }
    }
    var currentUserId: String = ""
    
    @Published var polls: [PollModel] = [] {
        didSet {
            self.objectWillChange.send()
        }
    }
    
    
    
    static var shared: DatabaseManager = {
        let instance = DatabaseManager()
        return instance
    }()
    
    private init() {
        if let user = Auth.auth().currentUser {
            isAnonymous = user.isAnonymous
            currentUserId = user.uid
            if !isAnonymous{
                getUserInfo()
            }
            getPolls()
            
            isLoggined = true
        } else {
            isLoggined = false
        }
    }
    
    func getUserInfo() {
        Task {
            let userDocument = dataBase.collection("Users").document(currentUserId)
            
            do {
                let user = try await userDocument.getDocument(as: UserModel.self)
                DispatchQueue.main.async {
                    self.currentUserInfo = user
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func getPolls() {
        Task {
            do {
                let pollDocuments = try await dataBase.collection("Polls").getDocuments()
                DispatchQueue.main.async { [self] in
                    polls = []
                    for doc in pollDocuments.documents {
                        do {
                            polls.append(try doc.data(as: PollModel.self))
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
                
            } catch {
                print(error)
            }
        }
    }
    
    
    func authenticateUserWithEmailAndPassword(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if error == nil {
                self?.isLoggined = true
                self?.isAnonymous = false
                self?.currentUserId = Auth.auth().currentUser!.uid
                self?.getUserInfo()
                self?.getPolls()
            } else {
                print(error)
            }
        }
    }
    
    func authenticateAnonymously() {
        Auth.auth().signInAnonymously() { [weak self] authResult, error in
            if error == nil {
                self?.isLoggined = true
                self?.isAnonymous = true
            } else {
                print(error)
            }
        }
    }
    
    func createUserWithEmailAndPassword(email: String, password: String, expertName: String){
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if error == nil {
                self?.isLoggined = true
                self?.isAnonymous = false
                self?.currentUserId = (authResult?.user.uid)!
                self?.currentUserInfo.expertName = expertName
                self?.updateUserInfo(user: self!.currentUserInfo)
            } else {
                print(error)
            }
        }
    }
    
    func createPoll (name: String, isClosed: Bool, password: String, alternatives: [String], gradationMin: String = "Least important", gradationMax: String = "Most important") -> Bool {
        let ref = dataBase.collection("Polls").document()
        // ref is a DocumentReference
        
        var poll = PollModel(id: ref.documentID, creatorId: currentUserId, name: name, isClosed: isClosed, password: password, alternatives: alternatives, statistics: [], experts: [], gradationMin: gradationMin, gradationMax: gradationMax)
        
        currentUserInfo.createdPolls.append(poll.id)
        
        var userUpdateSuccessfull = updateUserInfo(user: currentUserInfo)
        var pollUpdateSuccessfull = updatePollInfo(poll: poll)
        
        if userUpdateSuccessfull && pollUpdateSuccessfull{
            return true
        } else {
            return false
        }
    }
    
    func updateUserInfo(user: UserModel) -> Bool {
        do {
            try dataBase.collection("Users").document(currentUserId).setData(from: user)
        } catch {
            print(error)
            return false
        }
        return true
    }
    
    func updatePollInfo(poll: PollModel) -> Bool{
        do {
            try dataBase.collection("Polls").document(poll.id).setData(from: poll)
        } catch {
            print(error)
            return false
        }
        return true
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
        
        isLoggined = false
    }
    
    func deleteAccount() {
        for poll in currentUserInfo.createdPolls {
            deletePoll(pollId: poll)
        }
        
        Task {
            do {
                try await dataBase.collection("Users").document(currentUserId).delete()
                print("Document successfully removed!")
            } catch {
                print("Error removing document: \(error)")
            }
        }
        Auth.auth().currentUser?.delete()
        isLoggined = false
    }
    
    func deleteAnonim(){
        Auth.auth().currentUser?.delete()
        isLoggined = false
    }
    
    func deletePoll(pollId: String) {
        Task {
            do {
                try await dataBase.collection("Polls").document(pollId).delete()
                print("Document successfully removed!")
            } catch {
                print("Error removing document: \(error)")
            }
        }
        currentUserInfo.createdPolls.removeAll(where: { $0 == pollId })
        
        updateUserInfo(user: currentUserInfo)
        getPolls()
    }
}
