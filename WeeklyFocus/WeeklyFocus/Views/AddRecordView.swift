//
//  AddRecordView.swift
//  WeeklyFocus
//
//  Created by Assistant on 2025/12/13.
//

import SwiftUI

struct AddRecordView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedDate = Date()
    @State private var startTime = Date()
    @State private var endTime = Date()
    @State private var notes = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("日期")) {
                    DatePicker("选择日期", selection: $selectedDate, displayedComponents: .date)
                }
                
                Section(header: Text("时间")) {
                    DatePicker("上班时间", selection: $startTime, displayedComponents: .hourAndMinute)
                    DatePicker("下班时间", selection: $endTime, displayedComponents: .hourAndMinute)
                }
                
                Section(header: Text("备注")) {
                    TextField("输入备注 (可选)", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }
                
                Section {
                    Button("添加记录") {
                        addRecord()
                    }
                    .disabled(!isValidTimeRange)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("补录时间")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func addRecord() {
        guard let finalStart = combinedDateTime(for: selectedDate, time: startTime),
              let finalEnd = combinedDateTime(for: selectedDate, time: endTime),
              finalEnd > finalStart else { return }
        
        dataManager.addTimedRecord(
            startTime: finalStart,
            endTime: finalEnd,
            notes: notes.isEmpty ? nil : notes
        )
        dismiss()
    }
    
    private var isValidTimeRange: Bool {
        startTime < endTime
    }
    
    private func combinedDateTime(for date: Date, time: Date) -> Date? {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time)
        
        var components = DateComponents()
        components.year = dateComponents.year
        components.month = dateComponents.month
        components.day = dateComponents.day
        components.hour = timeComponents.hour
        components.minute = timeComponents.minute
        components.second = timeComponents.second ?? 0
        
        return calendar.date(from: components)
    }
}

struct AddRecordView_Previews: PreviewProvider {
    static var previews: some View {
        AddRecordView()
            .environmentObject(DataManager.shared)
    }
}
