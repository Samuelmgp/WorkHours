//
//  Item.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-09-18.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
