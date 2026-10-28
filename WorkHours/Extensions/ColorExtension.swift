//
//  ColorExtension.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-10-27.
//

import SwiftUI
import UIKit

extension Color {
    
    init?(hex: String){
        var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hex = hex.replacingOccurrences(of: "#", with: "")
        guard hex.count == 6, let int = UInt32(hex, radix: 16) else { return nil }
        self.init(
            red: Double((int >> 16) & 0xFF) / 255,
            green: Double((int >> 8) & 0xFF) / 255,
            blue: Double(int & 0xFF) / 255
        )
    }
    
    var hexString: String {
            let ui = UIColor(self)
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            ui.getRed(&r, green: &g, blue: &b, alpha: &a)
            return String(format: "#%02lX%02lX%02lX",
                Int(round(r * 255)), Int(round(g * 255)), Int(round(b * 255)))
    }
}

