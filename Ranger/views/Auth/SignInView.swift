//
//  LoginView.swift
//  Ranger
//
//  Created by Vlad Kyrylenko on 18.03.2024.
//

import SwiftUI

struct SignInView: View {
    var databaseManager = DatabaseManager.shared
    
    @State var email: String = ""
    @State var password: String = ""
    @FocusState private var focusPassword: Bool
    
    var body: some View {
        NavigationView {
            VStack{
                TextField(text: $email) {
                    Text("Enter email")
                }
                .padding(10)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .onSubmit() {
                    focusPassword = true
                }
                
                
                SecureField(text: $password) {
                    Text("Enter password")
                }
                .padding(10)
                .textFieldStyle(.roundedBorder)
                .focused($focusPassword)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .onSubmit {
                    logIn()
                }
                
                Button(action: { logIn() }, label: {
                    Text("Log In")
                })
                .padding(.vertical, 10)
                .padding(.horizontal, 30)
                .background(.ultraThinMaterial)
                .cornerRadius(15)
                
                HStack{
                    NavigationLink("Create account") {
                        SignUpView()
                    }
                    .font(.system(size: 15))
                    .padding(.vertical, 5)
                    Text("or sign in")
                        .foregroundStyle(.gray)
                        .font(.system(size: 15))
                    
                    Button("anonymously") {
                        databaseManager.authenticateAnonymously()
                    }
                    .font(.system(size: 15))
                    .padding(.vertical, 5)
                }
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(Text("Log In"))
            .contentShape(Rectangle())
            .onTapGesture {
                self.hideKeyboard()
            }
        }
    }
    
    func logIn() {
        databaseManager.authenticateUserWithEmailAndPassword(email: email, password: password)
    }
}

extension View {
    func hideKeyboard() {
        let resign = #selector(UIResponder.resignFirstResponder)
        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
    }
}

#Preview {
    SignInView()
}
