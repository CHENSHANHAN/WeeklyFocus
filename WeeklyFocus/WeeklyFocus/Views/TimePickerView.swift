//
//  TimePickerView.swift
//  WeeklyFocus
//
//  Created by Assistant on 2025/12/13.
//

import SwiftUI

struct TimePickerView: View {
    @Binding var selectedTime: Date
    let timePickerMode: TimePickerMode
    let onConfirm: (Date) -> Void
    let onCancel: () -> Void
    
    @State private var tempTime: Date
    
    init(selectedTime: Binding<Date>, timePickerMode: TimePickerMode, onConfirm: @escaping (Date) -> Void, onCancel: @escaping () -> Void) {
        self._selectedTime = selectedTime
        self.timePickerMode = timePickerMode
        self.onConfirm = onConfirm
        self.onCancel = onCancel
        self._tempTime = State(initialValue: selectedTime.wrappedValue)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // 标题
                VStack(spacing: 8) {
                    Image(systemName: "clock.fill")
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                    
                    Text(timePickerMode == .clockIn ? "选择上班时间" : "选择下班时间")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("请选择准确的时间，如果忘记打卡")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // 时间选择器
                VStack(spacing: 15) {
                    DatePicker(
                        "选择时间",
                        selection: $tempTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                    
                    // 快速选择按钮
                    HStack(spacing: 10) {
                        ForEach(getQuickTimeOptions(), id: \.self) { time in
                            Button(action: {
                                tempTime = time
                            }) {
                                Text(formatTime(time))
                                    .font(.subheadline)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // 操作按钮
                HStack(spacing: 15) {
                    Button(action: onCancel) {
                        Text("取消")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.gray)
                            .cornerRadius(12)
                    }
                    
                    Button(action: {
                        onConfirm(tempTime)
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("确认")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        onCancel()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("确认") {
                        onConfirm(tempTime)
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
    
    private func getQuickTimeOptions() -> [Date] {
        let calendar = Calendar.current
        let now = Date()
        
        // 根据当前时间生成一些常用时间选项
        var options: [Date] = []
        
        if timePickerMode == .clockIn {
            // 上班时间常用选项
            let commonStartTimes = [8, 9, 10, 11]
            for hour in commonStartTimes {
                if let time = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: now) {
                    options.append(time)
                }
            }
            
            // 如果当前时间早于常用时间，添加当前时间
            let currentHour = calendar.component(.hour, from: now)
            if currentHour < 8 {
                if let currentTime = calendar.date(bySettingHour: currentHour, minute: calendar.component(.minute, from: now), second: 0, of: now) {
                    options.insert(currentTime, at: 0)
                }
            }
        } else {
            // 下班时间常用选项
            let commonEndTimes = [17, 18, 19, 20]
            for hour in commonEndTimes {
                if let time = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: now) {
                    options.append(time)
                }
            }
            
            // 添加当前时间作为选项
            if let currentTime = calendar.date(bySettingHour: calendar.component(.hour, from: now), minute: calendar.component(.minute, from: now), second: 0, of: now) {
                options.insert(currentTime, at: 0)
            }
        }
        
        return options
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    TimePickerView(
        selectedTime: .constant(Date()),
        timePickerMode: .clockIn,
        onConfirm: { _ in },
        onCancel: {}
    )
}