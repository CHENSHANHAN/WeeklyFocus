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
    
    @State private var hours = 0
    @State private var minutes = 0
    @State private var selectedDate = Date()
    @State private var notes = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("时长设置")) {
                    HStack {
                        Text("小时")
                        Spacer()
                        Picker("小时", selection: $hours) {
                            ForEach(0..<24, id: \.self) { hour in
                                Text("\(hour)").tag(hour)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 80)
                    }
                    
                    HStack {
                        Text("分钟")
                        Spacer()
                        Picker("分钟", selection: $minutes) {
                            ForEach(0..<60, id: \.self) { minute in
                                Text("\(minute)").tag(minute)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 80)
                    }
                }
                
                Section(header: Text("日期")) {
                    DatePicker("选择日期", selection: $selectedDate, displayedComponents: .date)
                }
                
                Section(header: Text("备注")) {
                    TextField("输入备注 (可选)", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }
                
                Section {
                    Button("添加记录") {
                        addRecord()
                    }
                    .disabled(hours == 0 && minutes == 0)
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
        let totalMinutes = hours * 60 + minutes
        guard totalMinutes > 0 else { return }
        
        dataManager.addRecord(durationMinutes: totalMinutes, notes: notes.isEmpty ? nil : notes)
        dismiss()
    }
}

struct AddRecordView_Previews: PreviewProvider {
    static var previews: some View {
        AddRecordView()
            .environmentObject(DataManager.shared)
    }
}