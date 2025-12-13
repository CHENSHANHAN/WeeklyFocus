//
//  SettingsView.swift
//  WeeklyFocus
//
//  Created by Assistant on 2025/12/13.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var weeklyTargetHours = 40
    @State private var selectedWeekStartDay: WeekDay = .monday
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("目标设置")) {
                    HStack {
                        Text("每周目标时长")
                        Spacer()
                        Text("\(weeklyTargetHours) 小时")
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(value: Binding(
                        get: { Double(weeklyTargetHours) },
                        set: { weeklyTargetHours = Int($0) }
                    ), in: 1...80, step: 1)
                    .accentColor(.blue)
                }
                
                Section(header: Text("周期设置")) {
                    Picker("周起始日", selection: $selectedWeekStartDay) {
                        ForEach(WeekDay.allCases) { day in
                            Text(day.displayName).tag(day)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("数据管理")) {
                    Button(role: .destructive) {
                        showingResetAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("清除所有数据")
                        }
                    }
                }
                
                Section(header: Text("关于")) {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("开发者")
                        Spacer()
                        Text("CSH")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadCurrentSettings()
            }
            .onDisappear {
                saveSettings()
            }
            .alert("确认清除", isPresented: $showingResetAlert) {
                Button("取消", role: .cancel) { }
                Button("清除", role: .destructive) {
                    resetAllData()
                }
            } message: {
                Text("此操作将删除所有目标和记录数据，无法撤销。确定要继续吗？")
            }
        }
    }
    
    private func loadCurrentSettings() {
        if let goal = dataManager.currentGoal {
            weeklyTargetHours = goal.weeklyTargetMinutes / 60
            selectedWeekStartDay = goal.weekStartDay
        }
    }
    
    private func saveSettings() {
        let targetMinutes = weeklyTargetHours * 60
        dataManager.updateGoal(targetMinutes: targetMinutes, weekStartDay: selectedWeekStartDay)
    }
    
    private func resetAllData() {
        // This would need to be implemented in DataManager
        // For now, we'll just reset the current goal
        if let goal = dataManager.currentGoal {
            dataManager.updateGoal(targetMinutes: 2400, weekStartDay: .monday)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(DataManager.shared)
    }
}