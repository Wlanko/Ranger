//
//  RangerApp.swift
//  Ranger
//
//  Created by Vlad Kyrylenko on 11.03.2024.
//

import SwiftUI
import FirebaseCore



class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main

struct RangerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            AppView()
        }
    }
}

struct AppView: View {
    @ObservedObject var databaseManager = DatabaseManager.shared
    var body: some View {
        if(databaseManager.isLoggined){
            MainView()
        } else {
            SignInView()
        }
            //SignInView()
    }
}
