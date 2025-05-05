//
//  EtcHelper.swift
//  AI View Test
//
//  Created by admin on 02.05.2025.
//

import Foundation

func formattedTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    //formatter.dateFormat = "h:mm a"
    formatter.timeStyle = .short
    return formatter.string(from: date)
}


// Format the timestamp in a relative way
func formattedDate(_ date: Date) -> String {
    let calendar = Calendar.current
    
    if calendar.isDateInToday(date) {
        // Today: show time
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    } else if calendar.isDateInYesterday(date) {
        return "Yesterday"
    } else if calendar.isDate(date, equalTo: Date(), toGranularity: .weekOfYear) {
        // This week: show day name
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    } else {
        // Show date
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        return formatter.string(from: date)
    }
}
