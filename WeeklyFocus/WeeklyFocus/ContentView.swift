//
//  ContentView.swift
//  WeeklyFocus
//
//  Created by chenshanhan on 2025/12/13.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var dataManager: DataManager
    
    var body: some View {
        DashboardView()
            .onAppear {
                dataManager.initializeIfNeeded()
            }
    }
}

#Preview {
    ContentView()
        .environmentObject(DataManager.shared)
}
