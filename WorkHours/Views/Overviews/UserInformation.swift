//
//  UserInformation.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-10-19.
//

import SwiftUI

struct UserInformation: View {
    
    @Bindable private var user: UserModel
    @Binding private var userPerformedDeletedAccount: Bool

    
    init(user: UserModel, userPerformedDeleteAccount: Binding<Bool>) {
        self.user = user
        self._userPerformedDeletedAccount = userPerformedDeleteAccount
    }
    
    var body: some View {
        List {
            Section("User Information"){
                Text("First Name: \(user.firstName)")
                Text("Last Name: \(user.lastName)")
            }
            
            Section("Employer"){
                Text("Employer: \(user.employer)")
            }
            
            Section("Current Pay Period"){
                Text("Start: \(user.currentPayPeriodStartDate.formatted(date: .abbreviated, time: .shortened))")
                Text("End: \(user.currentPayPeriodEndDate.formatted(date: .abbreviated, time: .shortened))")
            }
            
            Section("Next Pay Period"){
                let nppStart: String = user.nextPayPeriodStartDate?.formatted(date: .abbreviated, time: .shortened) ?? "Undetermined"
                let nppEnd: String = user.nextPayPeriodEndDate?.formatted(date: .abbreviated, time: .shortened) ?? "Undetermined"
                Text("Starts: \(nppStart)")
                Text("Ends: \(nppEnd)")
            }
            
            Section("Settings"){
                Text("Wage Details")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary.opacity(0.75))
                    .listRowSeparator(.hidden)
                
                WageInput(value: $user.wage)
                Picker("Hours Rounding", selection: $user.hourRounding) {
                    ForEach(WorkHoursRoundingOptions.allCases, id: \.self){ v in
                        Text(v.getTitle())
                    }
                }
                Picker("Pay Period Frequency", selection: $user.paidFrequency){
                    ForEach(PayFrequency.allCases, id: \.self){ v in
                        Text(v.rawValue)
                    }
                }
                
                Text("Travel Settings")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary.opacity(0.75))
                    .listRowSeparator(.hidden)
                
                Toggle(isOn: $user.trackTravelTime, label: { Label("Track Travel Time", systemImage: "clock")})
                    .listRowSeparator(.hidden)

            }
            
            Section("Danger Zone"){
                Button("Delete Account"){
                    userPerformedDeletedAccount = true
                }
                .buttonStyle(.glassProminent)
                .tint(.red)
                .buttonSizing(.flexible)
                .padding(.horizontal)
                .disabled(userPerformedDeletedAccount)
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .navigationTitle("Profile")
    }
}

#Preview {
    @Previewable @State var delete: Bool = false
    @Previewable var user = UserModel(firstName: "Example", lastName: "Test", employer: "SGX", payweekStart: .now, payweekEnd: Calendar.current.date(byAdding: .day, value: 7, to: .now)!)
    NavigationView {
        UserInformation(user: user, userPerformedDeleteAccount: $delete)
    }
}
