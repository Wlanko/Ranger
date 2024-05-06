//
//  SIgnUpView.swift
//  Ranger
//
//  Created by Vlad Kyrylenko on 18.03.2024.
//

import SwiftUI

struct SignUpView: View {
    enum Field {
        case username
        case email
        case password
        case confirmPassword
    }
    
    @State var email: String = ""
    @State var password: String = ""
    @State var confirmPassword: String = ""
    @State var expertName: String = ""
    @State var showErrorAlert: Bool = false
    
    @State var errors: SignInErrors = .notAllFieldsAreFilledIn
    
    var databaseManager = DatabaseManager.shared
    
    @FocusState private var focusedField: Field?
    
    var body: some View {
        NavigationView {
            VStack {
                TextField(text: $expertName) {
                    Text("Enter your Expert name")
                }
                .padding(10)
                .textFieldStyle(.roundedBorder)
                .focused($focusedField, equals: .username)
                .autocorrectionDisabled()
                
                TextField(text: $email) {
                    Text("Enter email")
                }
                .textInputAutocapitalization(.none)
                .padding(10)
                .textFieldStyle(.roundedBorder)
                .focused($focusedField, equals: .email)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                
                
                
//                SecureField(text: $password) {
//                    Text("Enter password")
//                }
//                .padding(10)
//                .textFieldStyle(.roundedBorder)
//                .focused($focusedField, equals: .password)
//                .autocorrectionDisabled()
//                .textInputAutocapitalization(.never)
//
//                SecureField(text: $confirmPassword) {
//                    Text("Confirm password")
//                }
//                .padding(10)
//                .textFieldStyle(.roundedBorder)
//                .focused($focusedField, equals: .confirmPassword)
//                .autocorrectionDisabled()
//                .textInputAutocapitalization(.never)
                
                
                TextField(text: $password) {
                    Text("Enter password")
                }
                .padding(10)
                .textFieldStyle(.roundedBorder)
                .focused($focusedField, equals: .password)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                
                TextField(text: $confirmPassword) {
                    Text("Confirm password")
                }
                .padding(10)
                .textFieldStyle(.roundedBorder)
                .focused($focusedField, equals: .confirmPassword)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                
                
                Spacer()
                
                Button("Sign Up") {
                    createAccount()
                }
                .buttonStyle(.borderedProminent)
                .padding(10)
                
            }
            .defaultFocus($focusedField, .username)
            .onSubmit {
                switch focusedField {
                case .username:
                    focusedField = .email
                case .email:
                    focusedField = .password
                case .password:
                    focusedField = .confirmPassword
                case .confirmPassword:
                    createAccount()
                case .none:
                    focusedField = .username
                }
            }
            .alert(errors.rawValue, isPresented: $showErrorAlert, actions: {
                Button("ok", role: .cancel, action: {})
            })
            .navigationTitle("Sign Up")
            .navigationBarTitleDisplayMode(.inline)
            .contentShape(Rectangle())
            .onTapGesture {
                self.hideKeyboard()
            }
        }
    }
    
    func createAccount(){
        if checkForErrors(){
            databaseManager.createUserWithEmailAndPassword(email: email, password: password, expertName: expertName)
        } else {
            showErrorAlert = true
        }
    }
    
    func checkForErrors() -> Bool{
        if  expertName.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty {
            errors = .notAllFieldsAreFilledIn
            return false
        } else if password.count < 6 {
            errors = .passwordIsTooShort
            return false
        } else if password != confirmPassword {
            errors = .passwordsDoNotMatch
            return false
        } else {
            return true
        }
    }
}

enum SignInErrors: String {
    case passwordsDoNotMatch = "Please, make sure the passwords are matching"
    case passwordIsTooShort = "Please, make sure your password is at leat 6 characters long"
    case notAllFieldsAreFilledIn = "Please, fill in all fieds"
}

#Preview {
    SignUpView()
}
