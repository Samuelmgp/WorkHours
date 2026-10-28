//
//  EmployerCard.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-10-21.
//

import SwiftUI

struct EmployerCard: View {
    
    @Bindable var employerModel: EmployerModel
    
    init(employerModel: EmployerModel) {
        self.employerModel = employerModel
    }
    
    var body: some View {
        HStack (alignment: .center) {
            VStack(alignment: .leading, spacing: 10){
                Text("Employer")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary.opacity(0.85))
                Label(employerModel.employerName, systemImage: "suitcase")
                    .font(.system(size: 20))
            }
            Spacer()
            VStack(alignment: .leading, spacing: 10){
                Text("Employed")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary.opacity(0.85))
                Label(employerModel.getDetails().getEmployedSinceFormatted(), systemImage: "calendar")
                    .font(.system(size: 20))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(.thinMaterial)
        )
        .padding(.horizontal)
    }
}

#Preview {
    
    @Previewable var sample: EmployerModel = EmployerModel(employerName: "SGX", employedSince: .now, payPeriodFrequency: .biweekly, hourRounding: .none, currentPayPeriodStart: .now, currentPayPeriodEnd: Calendar.current.date(byAdding: .day, value: 14, to: .now)!)
    
    EmployerCard(employerModel: sample)
}
