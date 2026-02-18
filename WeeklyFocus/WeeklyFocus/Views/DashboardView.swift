//
//  DashboardView.swift
//  WeeklyFocus
//
//  Created by Assistant on 2025/12/13.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddRecord = false
    @State private var showingCheckInOut = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Weekly Progress Card
                    weeklyProgressCard
                    
                    // Today's Status Card
                    todayStatusCard
                    
                    // Quick Actions Card
                    quickActionsCard
                    
                    // Recent Records
                    recentRecordsSection
                }
                .padding()
            }
            .navigationTitle("每周记录")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gear")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink {
                        StatisticsView()
                    } label: {
                        Image(systemName: "chart.bar")
                    }
                }
            }
            .sheet(isPresented: $showingAddRecord) {
                AddRecordView()
            }
            .sheet(isPresented: $showingCheckInOut) {
                if let goal = dataManager.currentGoal {
                    CheckInOutView(goal: goal)
                }
            }
        }
    }
    
    private var weeklyProgressCard: some View {
        VStack(spacing: 16) {
            if let goal = dataManager.currentGoal {
                let progress = Double(dataManager.currentWeekProgress) / Double(goal.weeklyTargetMinutes)
                let currentHours = dataManager.currentWeekProgress / 60
                let currentMinutes = dataManager.currentWeekProgress % 60
                let targetHours = goal.weeklyTargetMinutes / 60
                let targetMinutes = goal.weeklyTargetMinutes % 60
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("本周进度")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        // 详细时间显示（包含分钟）
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(currentHours)小时\(currentMinutes)分钟 / \(targetHours)小时\(targetMinutes)分钟")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            // 额外显示纯分钟数，更精确
                            Text("总进度: \(dataManager.currentWeekProgress) / \(goal.weeklyTargetMinutes) 分钟")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 8) {
                        ProgressRing(progress: progress, size: 60)
                        
                        // 显示剩余时间
                        let remainingMinutes = max(0, goal.weeklyTargetMinutes - dataManager.currentWeekProgress)
                        let remainingHours = remainingMinutes / 60
                        let remainingMins = remainingMinutes % 60
                        
                        if remainingMinutes > 0 {
                            VStack(spacing: 2) {
                                Text("还需")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(remainingHours)小时\(remainingMins)分钟")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.orange)
                            }
                        } else {
                            Text("已完成！")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                    }
                }
                
                ProgressView(value: progress) {
                    HStack {
                        Text(String(format: "%.1f%%", progress * 100))
                            .font(.caption)
                        
                        Spacer()
                    }
                }
                .progressViewStyle(LinearProgressViewStyle())
                .tint(progress >= 1.0 ? .green : .blue)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var todayStatusCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("今日状态")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    let todayMinutes = dataManager.todaysRecords.reduce(0) { $0 + $1.durationMinutes }
                    let todayHours = todayMinutes / 60
                    let todayRemainingMinutes = todayMinutes % 60
                    
                    // 详细时间显示
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(todayHours)小时\(todayRemainingMinutes)分钟")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        // 额外显示纯分钟数
                        Text("总计: \(todayMinutes) 分钟")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(dataManager.todaysRecords.isEmpty ? "今日还未开始" : "已记录 \(dataManager.todaysRecords.count) 次")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: dataManager.todaysRecords.isEmpty ? "moon" : "sun.max.fill")
                    .font(.system(size: 40))
                    .foregroundColor(dataManager.todaysRecords.isEmpty ? .orange : .yellow)
            }
            
            // 工作时长显示（如果有上下班打卡）
            if let goal = dataManager.currentGoal {
                let todayWorkMinutes = dataManager.getTodayWorkDuration(for: goal.id)
                if todayWorkMinutes > 0 {
                    Divider()
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("今日工作时长")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            let workHours = todayWorkMinutes / 60
                            let workMinutes = todayWorkMinutes % 60
                            
                            // 详细时间显示
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(workHours)小时\(workMinutes)分钟")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)
                                
                                // 额外显示纯分钟数
                                Text("工作时间: \(todayWorkMinutes) 分钟")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "briefcase.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.blue)
                    }
                }
            }
            
            if !dataManager.todaysRecords.isEmpty {
                Divider()
                
                ForEach(dataManager.todaysRecords.prefix(3), id: \.id) { record in
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.blue)
                        Text(record.displayTime)
                            .font(.subheadline)
                        
                        if let notes = record.notes, !notes.isEmpty {
                            Spacer()
                            Text(notes)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
                
                if dataManager.todaysRecords.count > 3 {
                    Text("还有 \(dataManager.todaysRecords.count - 3) 条记录...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var quickActionsCard: some View {
        VStack(spacing: 16) {
            Text("快速操作")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                Button(action: { showingCheckInOut = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "briefcase.fill")
                            .font(.title2)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("上下班打卡")
                                .font(.headline)
                            Text("记录工作时间")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        Spacer()
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title2)
                    }
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                Button(action: { showingAddRecord = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle")
                            .font(.title2)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("补录时间")
                                .font(.headline)
                            Text("手动添加一条时间记录")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        Spacer()
                        Image(systemName: "plus.app.fill")
                            .font(.title2)
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var recentRecordsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("最近记录")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                NavigationLink("查看全部") {
                    AllRecordsView()
                }
                .font(.caption)
            }
            
            if dataManager.currentWeekRecords.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    Text("本周还没有记录")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            } else {
                ForEach(dataManager.currentWeekRecords.suffix(5).reversed(), id: \.id) { record in
                    RecordRowView(record: record)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct ProgressRing: View {
    let progress: Double
    let size: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 8)
                .opacity(0.3)
                .foregroundColor(.gray)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))
                .foregroundColor(progress >= 1.0 ? .green : .blue)
                .rotationEffect(Angle(degrees: 270))
                .animation(.easeInOut(duration: 0.3), value: progress)
            
            Text(String(format: "%.0f%%", min(progress, 1.0) * 100))
                .font(.caption)
                .fontWeight(.semibold)
        }
        .frame(width: size, height: size)
    }
}

struct RecordRowView: View {
    let record: Record
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "clock.fill")
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(record.displayTime)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(record.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if let notes = record.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 8)
    }
}
