//
//  StatisticsView.swift
//  WeeklyFocus
//
//  Created by Assistant on 2025/12/13.
//

import SwiftUI
import Charts

struct StatisticsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedWeekOffset = 0
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                // Current Week Summary
                weekSummaryCard
                
                // Weekly Bar Chart
                weeklyChartCard
                
                // Work Hours Chart (new)
                workHoursChartCard
                
                // Daily Breakdown
                dailyBreakdownCard
            }
                .padding()
            }
            .navigationTitle("统计")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var weekSummaryCard: some View {
        VStack(spacing: 16) {
            if let goal = dataManager.currentGoal {
                let weeklyStats = dataManager.getWeeklyStats()
                let totalMinutes = weeklyStats.reduce(0) { $0 + $1.minutes }
                let avgMinutes = totalMinutes / 7
                let progress = Double(totalMinutes) / Double(goal.weeklyTargetMinutes)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("本周总结")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        // 详细时间显示（包含分钟）
                        VStack(alignment: .leading, spacing: 2) {
                            let totalHours = totalMinutes / 60
                            let totalRemainingMinutes = totalMinutes % 60
                            let targetHours = goal.weeklyTargetMinutes / 60
                            let targetRemainingMinutes = goal.weeklyTargetMinutes % 60
                            
                            Text("\(totalHours)小时\(totalRemainingMinutes)分钟 / \(targetHours)小时\(targetRemainingMinutes)分钟")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            // 额外显示纯分钟数
                            Text("总计: \(totalMinutes) / \(goal.weeklyTargetMinutes) 分钟")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("目标完成度")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(String(format: "%.1f%%", progress * 100))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(progress >= 1.0 ? .green : .blue)
                        
                        // 显示剩余时间
                        let remainingMinutes = max(0, goal.weeklyTargetMinutes - totalMinutes)
                        if remainingMinutes > 0 {
                            let remainingHours = remainingMinutes / 60
                            let remainingMins = remainingMinutes % 60
                            Text("还需: \(remainingHours)小时\(remainingMins)分钟")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                Divider()
                
                HStack(spacing: 20) {
                    VStack(spacing: 4) {
                        Text("日均")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        let avgHours = avgMinutes / 60
                        let avgRemainingMinutes = avgMinutes % 60
                        Text("\(avgHours)小时\(avgRemainingMinutes)分钟")
                            .font(.headline)
                        Text("(\(avgMinutes) 分钟)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Divider()
                    
                    VStack(spacing: 4) {
                        Text("记录天数")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(weeklyStats.filter { $0.minutes > 0 }.count)/7")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Divider()
                    
                    VStack(spacing: 4) {
                        Text("记录次数")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(dataManager.currentWeekRecords.count)")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var weeklyChartCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("本周分布")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if let goal = dataManager.currentGoal {
                    let dailyTarget = goal.weeklyTargetMinutes / 7
                    let dailyTargetHours = dailyTarget / 60
                    let dailyTargetMinutes = dailyTarget % 60
                    Text("日均目标: \(dailyTargetHours)小时\(dailyTargetMinutes)分钟 (\(dailyTarget)分钟)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(dataManager.getWeeklyStats(), id: \.date) { stat in
                        BarMark(
                            x: .value("Day", dayOfWeek(from: stat.date)),
                            y: .value("Minutes", stat.minutes)
                        )
                        .foregroundStyle(stat.minutes > 0 ? .blue : .gray)
                        .opacity(stat.minutes > 0 ? 0.8 : 0.3)
                    }
                    
                    if let goal = dataManager.currentGoal {
                        let dailyTarget = goal.weeklyTargetMinutes / 7
                        RuleMark(y: .value("Target", dailyTarget))
                            .foregroundStyle(.red)
                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                    }
                }
                .frame(height: 200)
            } else {
                // Fallback for iOS 15
                Text("图表需要 iOS 16.0 或更高版本")
                    .foregroundColor(.secondary)
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var workHoursChartCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("工作时长统计")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                let weeklyWorkStats = dataManager.getWeeklyWorkStats()
                let totalWorkMinutes = weeklyWorkStats.reduce(0) { $0 + $1.workMinutes }
                let avgWorkMinutes = totalWorkMinutes / 7
                
                // 详细时间显示（包含分钟）
                let totalWorkHours = totalWorkMinutes / 60
                let totalWorkRemainingMinutes = totalWorkMinutes % 60
                let avgWorkHours = avgWorkMinutes / 60
                let avgWorkRemainingMinutes = avgWorkMinutes % 60
                
                Text("总计: \(totalWorkHours)小时\(totalWorkRemainingMinutes)分钟 平均: \(avgWorkHours)小时\(avgWorkRemainingMinutes)分钟 (总计: \(totalWorkMinutes)分钟)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(dataManager.getWeeklyWorkStats(), id: \.date) { stat in
                        BarMark(
                            x: .value("Day", dayOfWeek(from: stat.date)),
                            y: .value("Work Hours", stat.workMinutes / 60)
                        )
                        .foregroundStyle(stat.workMinutes > 0 ? .orange : .gray)
                        .opacity(stat.workMinutes > 0 ? 0.8 : 0.3)
                    }
                    
                    // 标准8小时工作线
                    RuleMark(y: .value("Standard 8h", 8))
                        .foregroundStyle(.red)
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                }
                .frame(height: 200)
            } else {
                // Fallback for iOS 15
                Text("图表需要 iOS 16.0 或更高版本")
                    .foregroundColor(.secondary)
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            
            // 工作时长详情
            if !dataManager.getWeeklyWorkStats().allSatisfy({ $0.workMinutes == 0 }) {
                Divider()
                
                ForEach(dataManager.getWeeklyWorkStats(), id: \.date) { stat in
                    if stat.workMinutes > 0 {
                        WorkHoursRow(date: stat.date, workMinutes: stat.workMinutes)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var dailyBreakdownCard: some View {
        VStack(spacing: 16) {
            Text("每日详情")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ForEach(dataManager.getWeeklyStats(), id: \.date) { stat in
                DailyStatRow(date: stat.date, minutes: stat.minutes)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private func dayOfWeek(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
}

struct DailyStatRow: View {
    let date: Date
    let minutes: Int
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(dayOfWeekString(from: date))
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(width: 80, alignment: .leading)
            
            ProgressView(value: Double(minutes) / 480) // 8 hours max
                .progressViewStyle(LinearProgressViewStyle())
                .tint(minutes > 0 ? .blue : .gray)
            
            // 详细时间显示（包含分钟和纯分钟数）
            VStack(alignment: .trailing, spacing: 1) {
                Text(minutes > 0 ? "\(minutes / 60)h\(minutes % 60)m" : "-")
                    .font(.subheadline)
                
                if minutes > 0 {
                    Text("(\(minutes)分钟)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 70, alignment: .trailing)
        }
        .padding(.vertical, 8)
    }
    
    private func dayOfWeekString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.weekdaySymbols[Calendar.current.component(.weekday, from: date) - 1]
    }
}

struct WorkHoursRow: View {
    let date: Date
    let workMinutes: Int
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(dayOfWeekString(from: date))
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(width: 80, alignment: .leading)
            
            ProgressView(value: Double(workMinutes) / 480) // 8 hours max
                .progressViewStyle(LinearProgressViewStyle())
                .tint(workMinutes > 480 ? .green : .orange)
            
            // 详细时间显示（包含分钟和纯分钟数）
            VStack(alignment: .trailing, spacing: 1) {
                Text(workMinutes > 0 ? "\(workMinutes / 60)h\(workMinutes % 60)m" : "-")
                    .font(.subheadline)
                    .foregroundColor(workMinutes > 480 ? .green : .primary)
                
                if workMinutes > 0 {
                    Text("(\(workMinutes)分钟)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 70, alignment: .trailing)
        }
        .padding(.vertical, 8)
    }
    
    private func dayOfWeekString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.weekdaySymbols[Calendar.current.component(.weekday, from: date) - 1]
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView()
            .environmentObject(DataManager.shared)
    }
}