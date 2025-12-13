//
//  DataManager.swift
//  WeeklyFocus
//
//  Created by Assistant on 2025/12/13.
//

import Foundation
import SwiftData

@MainActor
class DataManager: ObservableObject {
    static let shared = DataManager()
    
    private var modelContainer: ModelContainer?
    private var modelContext: ModelContext?
    
    @Published var currentGoal: Goal?
    @Published var todaysRecords: [Record] = []
    @Published var currentWeekRecords: [Record] = []
    @Published var currentWeekProgress: Int = 0
    
    private init() {
        // 懒加载 - 在实际需要时才初始化
    }
    
    func initializeIfNeeded() {
        guard modelContext == nil else { return }
        
        setupModelContainer()
        loadCurrentGoal()
        loadTodaysRecords()
        loadCurrentWeekRecords()
    }
    
    private func setupModelContainer() {
        do {
            let schema = Schema([Goal.self, Record.self])
            let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(for: schema, configurations: [configuration])
            modelContext = ModelContext(modelContainer!)
        } catch {
            print("Failed to create ModelContainer: \(error)")
        }
    }
    
    // MARK: - Goal Management
    
    func loadCurrentGoal() {
        initializeIfNeeded()
        guard let context = modelContext else { return }
        
        let descriptor = FetchDescriptor<Goal>(
            predicate: #Predicate { $0.isActive == true },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        
        do {
            let goals = try context.fetch(descriptor)
            currentGoal = goals.first
            
            if currentGoal == nil {
                createDefaultGoal()
            }
        } catch {
            print("Failed to fetch goals: \(error)")
            createDefaultGoal()
        }
    }
    
    private func createDefaultGoal() {
        let goal = Goal()
        saveGoal(goal)
        currentGoal = goal
    }
    
    func saveGoal(_ goal: Goal) {
        initializeIfNeeded()
        guard let context = modelContext else { return }
        context.insert(goal)
        saveContext()
        currentGoal = goal
    }
    
    func updateGoal(targetMinutes: Int, weekStartDay: WeekDay) {
        initializeIfNeeded()
        guard let goal = currentGoal else { return }
        goal.weeklyTargetMinutes = targetMinutes
        goal.weekStartDay = weekStartDay
        saveContext()
        loadCurrentWeekRecords()
    }
    
    // MARK: - Record Management
    
    func loadTodaysRecords() {
        initializeIfNeeded()
        guard let context = modelContext else { return }
        guard let goal = currentGoal else { return }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        // Fetch all records for the current goal and filter by date in memory
        let descriptor = FetchDescriptor<Record>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        do {
            let allRecords = try context.fetch(descriptor)
            todaysRecords = allRecords.filter { record in
                record.goalId == goal.id && record.date >= startOfDay && record.date < endOfDay
            }
        } catch {
            print("Failed to fetch today's records: \(error)")
            todaysRecords = []
        }
    }
    
    func loadCurrentWeekRecords() {
        initializeIfNeeded()
        guard let context = modelContext else { return }
        guard let goal = currentGoal else { return }
        
        let currentCycle = WeeklyCycle.currentCycle(for: goal.weekStartDay)
        
        // Fetch all records and filter by goal ID and date range in memory
        let descriptor = FetchDescriptor<Record>(
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
        
        do {
            let allRecords = try context.fetch(descriptor)
            currentWeekRecords = allRecords.filter { record in
                record.goalId == goal.id && record.date >= currentCycle.startDate && record.date <= currentCycle.endDate
            }
            currentWeekProgress = currentWeekRecords.reduce(0) { $0 + $1.durationMinutes }
        } catch {
            print("Failed to fetch current week records: \(error)")
            currentWeekRecords = []
            currentWeekProgress = 0
        }
    }
    
    func addRecord(durationMinutes: Int, notes: String? = nil) {
        initializeIfNeeded()
        guard let goal = currentGoal else { return }
        
        let record = Record(
            goalId: goal.id,
            date: Date(),
            durationMinutes: durationMinutes,
            notes: notes
        )
        
        saveRecord(record)
    }
    
    func addTimedRecord(startTime: Date, endTime: Date, notes: String? = nil) {
        initializeIfNeeded()
        guard let goal = currentGoal else { return }
        
        let durationMinutes = Int(endTime.timeIntervalSince(startTime) / 60)
        
        let record = Record(
            goalId: goal.id,
            date: startTime,
            durationMinutes: durationMinutes,
            startTime: startTime,
            endTime: endTime,
            notes: notes
        )
        
        saveRecord(record)
    }
    
    func saveRecord(_ record: Record) {
        initializeIfNeeded()
        guard let context = modelContext else { return }
        context.insert(record)
        saveContext()
        loadTodaysRecords()
        loadCurrentWeekRecords()
    }
    
    func deleteRecord(_ record: Record) {
        initializeIfNeeded()
        guard let context = modelContext else { return }
        context.delete(record)
        saveContext()
        loadTodaysRecords()
        loadCurrentWeekRecords()
    }
    
    // MARK: - Clock In/Out Methods
    
    func loadTodaysRecord(for goalId: UUID) async -> Record? {
        initializeIfNeeded()
        guard let context = modelContext else { return nil }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let descriptor = FetchDescriptor<Record>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        do {
            let allRecords = try context.fetch(descriptor)
            return allRecords.first { record in
                record.goalId == goalId && record.date >= startOfDay && record.date < endOfDay
            }
        } catch {
            print("Failed to fetch today's record: \(error)")
            return nil
        }
    }
    
    func updateRecord(_ record: Record) async {
        initializeIfNeeded()
        guard let context = modelContext else { return }
        
        // 确保记录存在于上下文中
        if context.model(for: record.id) == nil {
            context.insert(record)
        }
        
        // 重新计算工作时长
        record.calculateWorkDuration()
        
        // 更新总时长（包含工作时长）
        if record.workDurationMinutes > 0 {
            record.durationMinutes = record.workDurationMinutes
        }
        
        saveContext()
        
        // 重新加载数据
        await MainActor.run {
            loadTodaysRecords()
            loadCurrentWeekRecords()
        }
    }
    
    func addRecord(_ record: Record) async {
        initializeIfNeeded()
        guard let context = modelContext else { return }
        
        // 重新计算工作时长
        record.calculateWorkDuration()
        
        // 更新总时长（包含工作时长）
        if record.workDurationMinutes > 0 {
            record.durationMinutes = record.workDurationMinutes
        }
        
        context.insert(record)
        saveContext()
        
        await MainActor.run {
            loadTodaysRecords()
            loadCurrentWeekRecords()
        }
    }
    
    /// 获取今日工作时长（分钟）
    func getTodayWorkDuration(for goalId: UUID) -> Int {
        initializeIfNeeded()
        guard let record = todaysRecords.first(where: { $0.goalId == goalId }) else { return 0 }
        return record.workDurationMinutes
    }
    
    /// 获取本周工作时长统计
    func getWeeklyWorkStats() -> [(date: Date, workMinutes: Int)] {
        initializeIfNeeded()
        guard let goal = currentGoal else { return [] }
        
        let currentCycle = WeeklyCycle.currentCycle(for: goal.weekStartDay)
        var dailyWorkStats: [(date: Date, workMinutes: Int)] = []
        
        let calendar = Calendar.current
        
        for dayOffset in 0..<7 {
            let date = calendar.date(byAdding: .day, value: dayOffset, to: currentCycle.startDate)!
            let dayRecords = currentWeekRecords.filter { calendar.isDate($0.date, inSameDayAs: date) }
            let totalWorkMinutes = dayRecords.reduce(0) { $0 + $1.workDurationMinutes }
            dailyWorkStats.append((date: date, workMinutes: totalWorkMinutes))
        }
        
        return dailyWorkStats
    }
    
    // MARK: - Statistics
    
    func getWeeklyStats() -> [(date: Date, minutes: Int)] {
        guard let goal = currentGoal else { return [] }
        
        let currentCycle = WeeklyCycle.currentCycle(for: goal.weekStartDay)
        var dailyStats: [(date: Date, minutes: Int)] = []
        
        let calendar = Calendar.current
        for dayOffset in 0..<7 {
            let date = calendar.date(byAdding: .day, value: dayOffset, to: currentCycle.startDate)!
            let dayRecords = currentWeekRecords.filter { calendar.isDate($0.date, inSameDayAs: date) }
            let totalMinutes = dayRecords.reduce(0) { $0 + $1.durationMinutes }
            dailyStats.append((date: date, minutes: totalMinutes))
        }
        
        return dailyStats
    }
    
    // MARK: - Helper Methods
    
    private func saveContext() {
        guard let context = modelContext else { return }
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}