//
//  WorkingHours.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-09-18.
//

import Foundation

final class WorkingHours: Codable {
    var date: Date
    
    enum CodingKeys: CodingKey {
        case date
    }
    
    init(_ date: Date) {
        self.date = date
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.date = try container.decode(Date.self, forKey: .date)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.date, forKey: .date)
    }
}
