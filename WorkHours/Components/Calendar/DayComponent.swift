//
//  DayComponent.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-10-27.
//

import SwiftUI

struct DayComponent: View {
    
    private var numericDay: Int
    private var hasWorked: Bool
    
    init(numericDay: Int = 1, hasWorked: Bool = true) {
        self.numericDay = numericDay
        self.hasWorked = hasWorked
        
    }
    
    var body: some View {
        VStack {
            Text("\(numericDay)")
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .frame(width: 40, height: 40)
                .foregroundStyle(
                    hasWorked ? Color.charlie : Color.delta
                )
        )
    }
    
}

#Preview {
    DayComponent()
}
