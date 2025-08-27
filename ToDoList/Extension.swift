//
//  Extension.swift
//  ToDoList
//
//  Created by N L on 21. 8. 2025..
//

import SwiftUI

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(.sRGB,
                  red:   Double((hex >> 16) & 0xFF)/255,
                  green: Double((hex >> 8)  & 0xFF)/255,
                  blue:  Double(hex & 0xFF)/255,
                  opacity: alpha)
    }
    
    struct App {
        static let black = Color(hex: 0x040404)
        static let white = Color(hex: 0xF4F4F4)
        static let yellow = Color(hex: 0xFED702)
        static let stroke = Color(hex: 0x4D555E)
        static let gray = Color(hex: 0x272729)
        static let menuBackground = Color(hex: 0xEDEDEDCC)
    }
}

extension Date {
    private static let ddMMyyFormatter: DateFormatter = {
        let df = DateFormatter()
        df.calendar = .current
        df.timeZone = .current
        df.locale = .current
        df.dateFormat = "dd/MM/yy"
        return df
    }()
    
    var ddMMyyString: String {
        Date.ddMMyyFormatter.string(from: self)
    }
}

extension Todo {
    var displayDateString: String {
        (createdAt).ddMMyyString
    }
}

extension Todo {
    var shareText: String {
        let status = completed ? "✅ Выполнено" : "🟢 В процессе"
        let titleText = title.isEmpty ? "Без названия" : title
        let detailsText = (description?.isEmpty == false) ? ("\n" + (description ?? "")) : ""
        let dateText = displayDateString.isEmpty ? "" : "\n\(displayDateString)"
        return "\(status)\n\(titleText)\(detailsText)\(dateText)"
    }
}
