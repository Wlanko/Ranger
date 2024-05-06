//
//  ContentView.swift
//  Ranger
//
//  Created by Vlad Kyrylenko on 11.03.2024.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            SelectPollView()
                .tabItem {
                    Label("Select", systemImage: "tray.full")
                }
            CreatePollView()
                .tabItem {
                    Label("Create", systemImage: "plus.circle")
                }
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
    }
}

#Preview {
    MainView()
}
