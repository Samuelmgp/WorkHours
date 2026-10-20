//
//  PayPeriodComponent.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-09-24.
//

import SwiftUI

struct PayPeriodComponent: View {
    
    @Bindable var payPeriod: PayPeriod
    
    var body: some View {
        HStack (alignment: .center){
            VStack (alignment: .leading){
                Text("Pay Period:")
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
    PayPeriodComponent(payPeriod: sample)
}
