//
//  Goal.swift
//  WeeklyFocus
//
//  Created by Assistant on 2025/12/13.
//

import Foundation
import SwiftData

@Model
class Goal {
    var id: UUID
    var title: String
    var weeklyTargetMinutes: Int
    var weekStartDay: WeekDay
    var createdAt: Date
    var isActive: Bool
    
    init(title: String = "Weekly Focus", weeklyTargetMinutes: Int = 2400, weekStartDay: WeekDay = .monday) {
        self.id = UUID()
        self.title = title
        self.weeklyTargetMinutes = weeklyTargetMinutes
        self.weekStartDay = weekStartDay
        self.createdAt = Date()
        self.isActive = true
    }
}

enum WeekDay: Int, CaseIterable, Identifiable, Codable {
    case sunday = 0
    case monday = 1
    case tuesday = 2
    case wednesday = 3
    case thursday = 4
    case friday = 5
    case saturday = 6
    
    var id: Int { rawValue }
    
    var displayName: String {
        switch self {
        case .sunday: return "周日"
        case .monday: return "周一"
        case .tuesday: return "周二"
        case .wednesday: return "周三"
        case .thursday: return "周四"
        case .friday: return "周五"
        case .saturday: return "周六"
        }
    }
    
    var shortName: String {
        switch self {
        case .sunday: return "日"
        case .monday: return "一"
        case .tuesday: return "二"
        case .wednesday: return "三"
        case .thursday: return "四"
        case .friday: return "五"
        case .saturday: return "六"
        }
    }
}