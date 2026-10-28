//
//  PayPeriodComponent.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-09-24.
//

import SwiftUI

struct PayPeriodCard: View {
    
    @Bindable var payPeriod: PayPeriod
    
    var body: some View {
        HStack (alignment: .center){
            VStack (alignment: .leading){
                Label(payPeriod.employer?.employerName ?? "None", systemImage: "suitcase")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.primary.opacity(0.75))
                Text(("\(payPeriod.payPeriodStartDate.formatted(date: .abbreviated, time: .omitted)) - \(payPeriod.payPeriodEndDate.formatted(date: .abbreviated, time: .omitted))"))
                    .font(.system(size: 15, weight: .semibold))
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    @Previewable @State var sample = PayPeriod(payPeriodStartDate: .now, payPeriodEndDate: .now)
    PayPeriodCard(payPeriod: sample)
}
