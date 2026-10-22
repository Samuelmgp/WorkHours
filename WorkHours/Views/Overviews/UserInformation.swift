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
            
            Section("Settings"){
                
                Toggle(isOn: $user.trackTravelTime, label: { Label("Track Travel Time", systemImage: "clock")})
                    .listRowSeparator(.hidden)

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
    }
}

#Preview {
    @Previewable @State var delete: Bool = false
    @Previewable var user = UserModel(firstName: "Example", lastName: "Test", trackTravelTime: false)
    NavigationView {
        UserInformation(user: user, userPerformedDeleteAccount: $delete)
    }
}
