//
//  TimerView.swift
//  WeeklyFocus
//
//  Created by Assistant on 2025/12/13.
//

import SwiftUI

struct TimerView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    @State private var isRunning = false
    @State private var startTime: Date?
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var notes = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                
                // Timer Display
                VStack(spacing: 16) {
                    Text(formattedTime)
                        .font(.system(size: 64, weight: .bold, design: .monospaced))
                        .foregroundColor(isRunning ? .blue : .gray)
                    
                    if isRunning {
                        Text("开始时间: \(startTime?.formatted(date: .omitted, time: .shortened) ?? "")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Control Buttons
                VStack(spacing: 16) {
                    Button(action: toggleTimer) {
                        HStack {
                            Image(systemName: isRunning ? "stop.fill" : "play.fill")
                                .font(.title2)
                            Text(isRunning ? "停止计时" : "开始计时")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isRunning ? Color.red : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    if !isRunning && elapsedTime > 0 {
                        Button("保存记录") {
                            saveRecord()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                
                // Notes Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("备注 (可选)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextField("输入活动备注...", text: $notes, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(2...4)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("专注计时")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var formattedTime: String {
        let hours = Int(elapsedTime) / 3600
        let minutes = (Int(elapsedTime) % 3600) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private func toggleTimer() {
        if isRunning {
            stopTimer()
        } else {
            startTimer()
        }
    }
    
    private func startTimer() {
        isRunning = true
        startTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if let start = startTime {
                elapsedTime = Date().timeIntervalSince(start)
            }
        }
    }
    
    private func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    private func saveRecord() {
        guard elapsedTime > 0 else { return }
        guard let start = startTime else { return }
        
        let endTime = start.addingTimeInterval(elapsedTime)
        dataManager.addTimedRecord(startTime: start, endTime: endTime, notes: notes.isEmpty ? nil : notes)
        
        dismiss()
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
            .environmentObject(DataManager.shared)
    }
}