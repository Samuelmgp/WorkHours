//
//  WorkTicketIndicator.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-10-28.
//

import SwiftUI

struct WorkTicketIndicator: View {

    let color: Color

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 5, height: 5)
            .overlay {
                Circle()
                    .strokeBorder(color.opacity(0.15), lineWidth: 0.5)
            }
    }
}

#Preview {
    WorkTicketIndicator(color: .blue)
}
