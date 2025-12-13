//
//  WeeklyCycle.swift
//  WeeklyFocus
//
//  Created by Assistant on 2025/12/13.
//

import Foundation

struct WeeklyCycle {
    let startDate: Date
    let endDate: Date
    let weekNumber: Int
    let year: Int
    
    init(startDate: Date, endDate: Date) {
        self.startDate = startDate
        self.endDate = endDate
        
        let calendar = Calendar.current
        self.weekNumber = calendar.component(.weekOfYear, from: startDate)
        self.year = calendar.component(.year, from: startDate)
    }
    
    func contains(_ date: Date) -> Bool {
        return date >= startDate && date <= endDate
    }
    
    var displayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
}

extension WeeklyCycle {
    static func currentCycle(for weekStartDay: WeekDay) -> WeeklyCycle {
        let calendar = Calendar.current
        let today = Date()
        
        let currentWeekday = calendar.component(.weekday, from: today)
        let targetWeekday = weekStartDay.rawValue + 1
        
        var daysFromStart = currentWeekday - targetWeekday
        if daysFromStart < 0 {
            daysFromStart += 7
        }
        
        let startDate = calendar.date(byAdding: .day, value: -daysFromStart, to: today)!
        let endDate = calendar.date(byAdding: .day, value: 6, to: startDate)!
        
        return WeeklyCycle(startDate: startDate, endDate: endDate)
    }
    
    static func cycle(containing date: Date, weekStartDay: WeekDay) -> WeeklyCycle {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let targetWeekday = weekStartDay.rawValue + 1
        
        var daysFromStart = weekday - targetWeekday
        if daysFromStart < 0 {
            daysFromStart += 7
        }
        
        let startDate = calendar.date(byAdding: .day, value: -daysFromStart, to: date)!
        let endDate = calendar.date(byAdding: .day, value: 6, to: startDate)!
        
        return WeeklyCycle(startDate: startDate, endDate: endDate)
    }
}