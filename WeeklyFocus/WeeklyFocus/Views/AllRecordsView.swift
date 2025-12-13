//
//  AllRecordsView.swift
//  WeeklyFocus
//
//  Created by Assistant on 2025/12/13.
//

import SwiftUI

struct AllRecordsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(groupedRecords, id: \.date) { group in
                    Section(header: Text(sectionHeader(for: group.date))) {
                        ForEach(group.records, id: \.id) { record in
                            RecordRowView(record: record)
                        }
                        .onDelete { indexSet in
                            deleteRecords(at: indexSet, in: group.records)
                        }
                    }
                }
            }
            .navigationTitle("所有记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
    }
    
    private var groupedRecords: [(date: Date, records: [Record])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: dataManager.currentWeekRecords) { record in
            calendar.startOfDay(for: record.date)
        }
        
        return grouped.keys.sorted(by: >).map { date in
            (date: date, records: grouped[date]!.sorted(by: { $0.date > $1.date }))
        }
    }
    
    private func sectionHeader(for date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "今天"
        } else if calendar.isDateInYesterday(date) {
            return "昨天"
        } else {
            return date.formatted(date: .abbreviated, time: .omitted)
        }
    }
    
    private func deleteRecords(at offsets: IndexSet, in records: [Record]) {
        for index in offsets {
            let record = records[index]
            dataManager.deleteRecord(record)
        }
    }
}