//
//  UserInformation.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-10-19.
//

import SwiftUI

struct UserInformation: View {
    
    private var user: UserModel
    @State private var userPerformedDeletedAccount: Bool = false
    
    @State private var trackTravel: Bool
    @State private var deletePastPayPeriods: Bool
    @State private var deletableAfter: DeletableAfter
    
    
    init(user: UserModel) {
        self.user = user
        self.trackTravel = user.trackTravelTime
        self.deletePastPayPeriods = user.deletePastPayPeriods
        self.deletableAfter = user.deletePayPeriodAfter
    }
    
    var body: some View {
        List {
            Section("User Information"){
                Text("First Name: \(user.firstName)")
                Text("Last Name: \(user.lastName)")
            }
            
            Section("Travel Tracking"){
                
                Toggle(isOn: $trackTravel, label: { Label("Track Travel Time", systemImage: "clock")})
                    .listRowSeparator(.hidden)
                    .onChange(of: trackTravel) {
                        user.trackTravelTime = trackTravel
                        UserManager.shared.saveUser(user)
                    }
                
            }
            
            Section("Pay Period Settings"){
                Toggle(isOn: $deletePastPayPeriods, label: {Label("Delete Pay Periods", systemImage: "calendar")})
                    .onChange(of: deletePastPayPeriods) {
                        user.deletePastPayPeriods = deletePastPayPeriods
                        UserManager.shared.saveUser(user)
                    }
                
                deletePastPayPeriods == true ? Picker(selection: $deletableAfter){
                    ForEach(DeletableAfter.allCases, id: \.self){ o in
                        Text(o.rawValue)
                    }
                } label: {
                    Label("Delete After", systemImage: "exclamationmark.circle")
                }
                .onChange(of: deletableAfter) {
                    user.deletePayPeriodAfter = deletableAfter
                    UserManager.shared.saveUser(user)
                }
                : nil
            }
            
            Section("Danger Zone"){
                Button("Delete Account"){
                    userPerformedDeletedAccount = true
                }
                .listRowBackground(Color.clear)
                .buttonStyle(.glassProminent)
                .tint(.red)
                .buttonSizing(.flexible)
                .padding(.horizontal)
                .disabled(userPerformedDeletedAccount)
            }
            .listRowSeparator(.hidden)
        }
        .navigationTitle("Profile")
        .fullScreenCover(isPresented: $userPerformedDeletedAccount, content: {
            DeleteAccountOverview(isPresented: $userPerformedDeletedAccount, user: user as (UserModel?))
        })
    }
}

#Preview {
    @Previewable @State var delete: Bool = false
    @Previewable var user = UserModel(firstName: "Example", lastName: "Test", trackTravelTime: false)
    NavigationView {
        UserInformation(user: user)
    }
}
