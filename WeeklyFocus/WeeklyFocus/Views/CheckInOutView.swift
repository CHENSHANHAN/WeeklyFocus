//
//  CheckInOutView.swift
//  WeeklyFocus
//
//  Created by Assistant on 2025/12/13.
//

import SwiftUI

enum TimePickerMode {
    case clockIn
    case clockOut
}

struct CheckInOutView: View {
    @EnvironmentObject private var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    let goal: Goal
    @State private var todayRecord: Record?
    @State private var currentTime = Date()
    @State private var timer: Timer?
    
    // 时间选择相关状态
    @State private var showTimePicker = false
    @State private var timePickerMode: TimePickerMode = .clockIn
    @State private var selectedTime = Date()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // 当前时间显示
                VStack(spacing: 10) {
                    Text("当前时间")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(currentTime, style: .time)
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundColor(.primary)
                }
                .padding(.top, 20)
                
                // 今日打卡状态
                if let record = todayRecord {
                    VStack(spacing: 20) {
                        // 上班打卡状态
                        HStack {
                            Image(systemName: record.hasClockedIn ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(record.hasClockedIn ? .green : .gray)
                                .font(.title)
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text("上班打卡")
                                    .font(.headline)
                                
                                if record.hasClockedIn {
                                    Text("打卡时间: \(record.clockInTimeDisplay)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("未打卡")
                                        .font(.subheadline)
                                        .foregroundColor(.orange)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        
                        // 下班打卡状态
                        HStack {
                            Image(systemName: record.hasClockedOut ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(record.hasClockedOut ? .green : .gray)
                                .font(.title)
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text("下班打卡")
                                    .font(.headline)
                                
                                if record.hasClockedOut {
                                    Text("打卡时间: \(record.clockOutTimeDisplay)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("未打卡")
                                        .font(.subheadline)
                                        .foregroundColor(.orange)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        
                        // 工作时长显示
                        if record.workDurationMinutes > 0 {
                            VStack(spacing: 10) {
                                Text("今日工作时长")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Text(record.workDurationDisplay)
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.blue)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    
                    // 打卡按钮
                    VStack(spacing: 15) {
                        if !record.hasClockedIn {
                            // 上班打卡按钮组
                            VStack(spacing: 10) {
                                Button(action: {
                                    clockIn()
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.right.circle.fill")
                                        Text("上班打卡")
                                    }
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                                
                                Button(action: {
                                    selectedTime = Date()
                                    timePickerMode = .clockIn
                                    showTimePicker = true
                                }) {
                                    HStack {
                                        Image(systemName: "clock.arrow.2.circlepath")
                                        Text("选择上班时间")
                                    }
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green.opacity(0.2))
                                    .foregroundColor(.green)
                                    .cornerRadius(12)
                                }
                            }
                        } else if !record.hasClockedOut {
                            // 下班打卡按钮组
                            VStack(spacing: 10) {
                                Button(action: {
                                    clockOut()
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.left.circle.fill")
                                        Text("下班打卡")
                                    }
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                                
                                Button(action: {
                                    selectedTime = Date()
                                    timePickerMode = .clockOut
                                    showTimePicker = true
                                }) {
                                    HStack {
                                        Image(systemName: "clock.arrow.2.circlepath")
                                        Text("选择下班时间")
                                    }
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red.opacity(0.2))
                                    .foregroundColor(.red)
                                    .cornerRadius(12)
                                }
                            }
                        } else {
                            // 已完整打卡，显示重新打卡选项
                            Button(action: {
                                resetClockInOut()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise")
                                    Text("重新打卡")
                                }
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                        }
                    }
                } else {
                    // 没有今日记录，创建新的
                    VStack(spacing: 20) {
                        Text("今日还未创建记录")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            createTodayRecordAndClockIn()
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("创建记录并上班打卡")
                            }
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("上下班打卡")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showTimePicker) {
                TimePickerView(
                    selectedTime: $selectedTime,
                    timePickerMode: timePickerMode,
                    onConfirm: { selectedDate in
                        if timePickerMode == .clockIn {
                            clockInWithTime(selectedDate)
                        } else {
                            clockOutWithTime(selectedDate)
                        }
                        showTimePicker = false
                    },
                    onCancel: {
                        showTimePicker = false
                    }
                )
                .presentationDetents([.medium])
            }
            .onAppear {
                loadTodayRecord()
                startTimer()
            }
            .onDisappear {
                stopTimer()
            }
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            currentTime = Date()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func loadTodayRecord() {
        Task {
            if let record = await dataManager.loadTodaysRecord(for: goal.id) {
                await MainActor.run {
                    todayRecord = record
                }
            }
        }
    }
    
    private func clockIn() {
        guard var record = todayRecord else { return }
        
        record.clockInTime = Date()
        record.calculateWorkDuration()
        
        Task {
            await dataManager.updateRecord(record)
            await MainActor.run {
                todayRecord = record
            }
        }
    }
    
    private func clockOut() {
        guard var record = todayRecord else { return }
        
        record.clockOutTime = Date()
        record.calculateWorkDuration()
        
        Task {
            await dataManager.updateRecord(record)
            await MainActor.run {
                todayRecord = record
            }
        }
    }
    
    private func resetClockInOut() {
        guard var record = todayRecord else { return }
        
        record.clockInTime = nil
        record.clockOutTime = nil
        record.workDurationMinutes = 0
        
        Task {
            await dataManager.updateRecord(record)
            await MainActor.run {
                todayRecord = record
            }
        }
    }
    
    private func clockInWithTime(_ time: Date) {
        guard var record = todayRecord else {
            // 如果没有今日记录，先创建记录再打卡
            createTodayRecordAndClockInWithTime(time)
            return
        }
        
        record.clockInTime = time
        record.calculateWorkDuration()
        
        Task {
            await dataManager.updateRecord(record)
            await MainActor.run {
                todayRecord = record
            }
        }
    }
    
    private func clockOutWithTime(_ time: Date) {
        guard var record = todayRecord else { return }
        
        record.clockOutTime = time
        record.calculateWorkDuration()
        
        Task {
            await dataManager.updateRecord(record)
            await MainActor.run {
                todayRecord = record
            }
        }
    }
    
    private func createTodayRecordAndClockIn() {
        let today = Calendar.current.startOfDay(for: Date())
        var newRecord = Record(
            goalId: goal.id,
            date: today,
            durationMinutes: 0,
            clockInTime: Date()
        )
        newRecord.calculateWorkDuration()
        
        Task {
            await dataManager.addRecord(newRecord)
            await MainActor.run {
                todayRecord = newRecord
            }
        }
    }
    
    private func createTodayRecordAndClockInWithTime(_ time: Date) {
        let today = Calendar.current.startOfDay(for: Date())
        var newRecord = Record(
            goalId: goal.id,
            date: today,
            durationMinutes: 0,
            clockInTime: time
        )
        newRecord.calculateWorkDuration()
        
        Task {
            await dataManager.addRecord(newRecord)
            await MainActor.run {
                todayRecord = newRecord
            }
        }
    }
}

// 预览专用的简化CheckInOut视图
struct CheckInOutPreviewView: View {
    @State private var todayRecord: Record?
    @State private var currentTime = Date()
    @State private var timer: Timer?
    @Environment(\.dismiss) private var dismiss
    
    let goal: Goal
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // 当前时间显示
                VStack(spacing: 10) {
                    Text("当前时间")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(currentTime, style: .time)
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundColor(.primary)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(15)
                .shadow(radius: 2)
                
                // 打卡状态
                if let record = todayRecord {
                    VStack(spacing: 20) {
                        if record.hasClockedIn {
                            // 已打卡上班
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.title)
                                
                                VStack(alignment: .leading) {
                                    Text("上班打卡")
                                        .font(.headline)
                                    Text(record.clockInTimeDisplay)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(10)
                        }
                        
                        if record.hasClockedOut {
                            // 已打卡下班
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.title)
                                
                                VStack(alignment: .leading) {
                                    Text("下班打卡")
                                        .font(.headline)
                                    Text(record.clockOutTimeDisplay)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                        }
                        
                        if record.hasClockedIn && record.hasClockedOut {
                            // 工作时长
                            HStack {
                                Image(systemName: "clock.fill")
                                    .foregroundColor(.orange)
                                    .font(.title)
                                
                                VStack(alignment: .leading) {
                                    Text("工作时长")
                                        .font(.headline)
                                    Text(record.workDurationDisplay)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.orange)
                                }
                                
                                Spacer()
                            }
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                }
                
                Spacer()
                
                // 操作按钮
                VStack(spacing: 15) {
                    if let record = todayRecord {
                        if !record.hasClockedIn {
                            Button(action: {
                                var newRecord = record
                                newRecord.clockInTime = Date()
                                newRecord.calculateWorkDuration()
                                todayRecord = newRecord
                            }) {
                                HStack {
                                    Image(systemName: "arrow.right.circle.fill")
                                    Text("上班打卡")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(10)
                            }
                        } else if !record.hasClockedOut {
                            Button(action: {
                                var newRecord = record
                                newRecord.clockOutTime = Date()
                                newRecord.calculateWorkDuration()
                                todayRecord = newRecord
                            }) {
                                HStack {
                                    Image(systemName: "arrow.left.circle.fill")
                                    Text("下班打卡")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                            }
                        } else {
                            Button(action: {
                                var newRecord = record
                                newRecord.clockInTime = nil
                                newRecord.clockOutTime = nil
                                newRecord.workDurationMinutes = 0
                                todayRecord = newRecord
                            }) {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise")
                                    Text("重置打卡")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .cornerRadius(10)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("\(goal.title) 打卡")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            // 初始化今日记录
            let today = Calendar.current.startOfDay(for: Date())
            todayRecord = Record(
                goalId: goal.id,
                date: today,
                durationMinutes: 0,
                clockInTime: nil,
                clockOutTime: nil
            )
            
            // 启动定时器更新时间
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                currentTime = Date()
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
}

#Preview {
    CheckInOutPreviewView(goal: Goal(title: "工作", weeklyTargetMinutes: 480, weekStartDay: .monday))
}