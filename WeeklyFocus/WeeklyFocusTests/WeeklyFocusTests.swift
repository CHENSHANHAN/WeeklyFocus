//
//  WeeklyFocusTests.swift
//  WeeklyFocusTests
//
//  Created by Assistant on 2025/12/13.
//

import XCTest
import SwiftData
@testable import WeeklyFocus

final class WeeklyFocusTests: XCTestCase {
    
    func testGoalCreation() {
        let goal = Goal(title: "Test Goal", weeklyTargetMinutes: 2400, weekStartDay: .monday)
        
        XCTAssertEqual(goal.title, "Test Goal")
        XCTAssertEqual(goal.weeklyTargetMinutes, 2400)
        XCTAssertEqual(goal.weekStartDay, .monday)
        XCTAssertTrue(goal.isActive)
        XCTAssertNotNil(goal.createdAt)
    }
    
    func testRecordCreation() {
        let goalId = UUID()
        let date = Date()
        let record = Record(goalId: goalId, date: date, durationMinutes: 60, notes: "Test record")
        
        XCTAssertEqual(record.goalId, goalId)
        XCTAssertEqual(record.durationMinutes, 60)
        XCTAssertEqual(record.notes, "Test record")
        XCTAssertEqual(record.date, date)
        XCTAssertTrue(record.isManualEntry)
    }
    
    func testWeeklyCycleCalculation() {
        let calendar = Calendar.current
        let testDate = calendar.date(from: DateComponents(year: 2025, month: 12, day: 13))! // Friday
        
        let cycle = WeeklyCycle.cycle(containing: testDate, weekStartDay: .monday)
        
        // Should start on Monday (Dec 9, 2025)
        let expectedStart = calendar.date(from: DateComponents(year: 2025, month: 12, day: 9))!
        let expectedEnd = calendar.date(from: DateComponents(year: 2025, month: 12, day: 15))!
        
        XCTAssertEqual(cycle.startDate, expectedStart)
        XCTAssertEqual(cycle.endDate, expectedEnd)
        XCTAssertTrue(cycle.contains(testDate))
    }
    
    func testWeekDayEnum() {
        XCTAssertEqual(WeekDay.monday.displayName, "周一")
        XCTAssertEqual(WeekDay.sunday.shortName, "日")
        XCTAssertEqual(WeekDay.monday.rawValue, 1)
    }
    
    func testRecordDisplayTime() {
        let record1 = Record(goalId: UUID(), date: Date(), durationMinutes: 75) // 1 hour 15 minutes
        XCTAssertEqual(record1.displayTime, "1小时15分钟")
        
        let record2 = Record(goalId: UUID(), date: Date(), durationMinutes: 30) // 30 minutes
        XCTAssertEqual(record2.displayTime, "30分钟")
    }
    
    func testWeeklyCycleCurrentWeek() {
        let currentCycle = WeeklyCycle.currentCycle(for: .monday)
        let today = Date()
        
        XCTAssertTrue(currentCycle.contains(today))
        
        // Check that the cycle is exactly 7 days
        let calendar = Calendar.current
        let daysDiff = calendar.dateComponents([.day], from: currentCycle.startDate, to: currentCycle.endDate).day
        XCTAssertEqual(daysDiff, 6) // 6 days difference = 7 day span
    }
}