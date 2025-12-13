//
//  Record.swift
//  WeeklyFocus
//
//  Created by Assistant on 2025/12/13.
//

import Foundation
import SwiftData

@Model
class Record {
    var id: UUID
    var goalId: UUID
    var date: Date
    var durationMinutes: Int
    var startTime: Date?
    var endTime: Date?
    var clockInTime: Date?  // 上班时间
    var clockOutTime: Date?  // 下班时间
    var workDurationMinutes: Int  // 工作时长（分钟）
    var notes: String?
    var createdAt: Date
    
    init(goalId: UUID, date: Date, durationMinutes: Int, startTime: Date? = nil, endTime: Date? = nil, 
         clockInTime: Date? = nil, clockOutTime: Date? = nil, workDurationMinutes: Int = 0, notes: String? = nil) {
        self.id = UUID()
        self.goalId = goalId
        self.date = date
        self.durationMinutes = durationMinutes
        self.startTime = startTime
        self.endTime = endTime
        self.clockInTime = clockInTime
        self.clockOutTime = clockOutTime
        self.workDurationMinutes = workDurationMinutes
        self.notes = notes
        self.createdAt = Date()
    }
}

extension Record {
    var isManualEntry: Bool {
        return startTime == nil && endTime == nil
    }
    
    var isClockInOutEntry: Bool {
        return clockInTime != nil || clockOutTime != nil
    }
    
    var hasClockedIn: Bool {
        return clockInTime != nil
    }
    
    var hasClockedOut: Bool {
        return clockOutTime != nil
    }
    
    var workDurationDisplay: String {
        let hours = workDurationMinutes / 60
        let minutes = workDurationMinutes % 60
        if hours > 0 {
            return String(format: "%d小时%d分钟", hours, minutes)
        } else {
            return String(format: "%d分钟", minutes)
        }
    }
    
    var displayTime: String {
        let hours = durationMinutes / 60
        let minutes = durationMinutes % 60
        if hours > 0 {
            return String(format: "%d小时%d分钟", hours, minutes)
        } else {
            return String(format: "%d分钟", minutes)
        }
    }
    
    var clockInTimeDisplay: String {
        guard let clockInTime = clockInTime else { return "未打卡" }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: clockInTime)
    }
    
    var clockOutTimeDisplay: String {
        guard let clockOutTime = clockOutTime else { return "未打卡" }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: clockOutTime)
    }
    
    /// 计算工作时长（如果已打卡上下班）
    func calculateWorkDuration() {
        guard let clockIn = clockInTime, let clockOut = clockOutTime else {
            workDurationMinutes = 0
            return
        }
        
        let duration = clockOut.timeIntervalSince(clockIn) / 60 // 转换为分钟
        workDurationMinutes = Int(max(0, duration))
    }
}