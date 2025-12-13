//
//  WeeklyFocusApp.swift
//  WeeklyFocus
//
//  Created by chenshanhan on 2025/12/13.
//

import SwiftUI
import SwiftData

@main
struct WeeklyFocusApp: App {
    @StateObject private var dataManager = DataManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager)
        }
        .modelContainer(for: [Goal.self, Record.self])
    }
}
