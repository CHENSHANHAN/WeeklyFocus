//
//  SettingsView.swift
//  WeeklyFocus
//
//  Created by Assistant on 2025/12/13.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var weeklyTargetHours: Double = 40.0
    @State private var selectedWeekStartDay: WeekDay = .monday
    @State private var showingResetAlert = false
    @State private var showingManualTargetInput = false
    @State private var manualHours = 40
    @State private var manualMinutes = 0
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("目标设置")) {
                    HStack {
                        Text("每周目标时长")
                        Spacer()
                        Text(String(format: "%.1f 小时", weeklyTargetHours))
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(value: $weeklyTargetHours, in: 1...80, step: 0.1)
                    .accentColor(.blue)
                    
                    Button {
                        let totalMinutes = Int((weeklyTargetHours * 60).rounded())
                        manualHours = totalMinutes / 60
                        manualMinutes = totalMinutes % 60
                        showingManualTargetInput = true
                    } label: {
                        HStack {
                            Image(systemName: "keyboard")
                            Text("手动输入目标时间")
                        }
                    }
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
                weeklyTargetHours = min(max(weeklyTargetHours, 1.0), 80.0)
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
            .sheet(isPresented: $showingManualTargetInput) {
                ManualTargetInputView(
                    hours: $manualHours,
                    minutes: $manualMinutes,
                    onConfirm: {
                        let totalMinutes = manualHours * 60 + manualMinutes
                        let hoursValue = Double(totalMinutes) / 60.0
                        weeklyTargetHours = min(max(hoursValue, 1.0), 80.0)
                        showingManualTargetInput = false
                    },
                    onCancel: {
                        showingManualTargetInput = false
                    }
                )
            }
        }
    }
    
    private func loadCurrentSettings() {
        if let goal = dataManager.currentGoal {
            weeklyTargetHours = Double(goal.weeklyTargetMinutes) / 60.0
            weeklyTargetHours = min(max(weeklyTargetHours, 1.0), 80.0)
            selectedWeekStartDay = goal.weekStartDay
        }
    }
    
    private func saveSettings() {
        let targetMinutes = Int((weeklyTargetHours * 60).rounded())
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

struct ManualTargetInputView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var hours: Int
    @Binding var minutes: Int
    var onConfirm: () -> Void
    var onCancel: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("目标时间")) {
                    HStack {
                        Text("小时")
                        Spacer()
                        Picker("小时", selection: $hours) {
                            ForEach(0...80, id: \.self) { value in
                                Text("\(value)")
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 100)
                    }
                    
                    HStack {
                        Text("分钟")
                        Spacer()
                        Picker("分钟", selection: $minutes) {
                            ForEach(0..<60, id: \.self) { value in
                                Text("\(value)")
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 100)
                    }
                }
            }
            .navigationTitle("手动输入目标时间")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        onCancel()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        onConfirm()
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(DataManager.shared)
    }
}
