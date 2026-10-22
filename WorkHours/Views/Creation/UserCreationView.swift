//
//  UserCreationView.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-09-20.
//

import SwiftUI
import SwiftData

struct UserCreationView: View {
    
    @Environment(\.modelContext) var context
    
    @State var firstName: String = ""
    @State var lastName: String = ""
    
    @State var payPeriodStartDate: Date = .now
    @State var payPeriodEndDate: Date = .now
    @State var payPeriodFrequency: PayFrequency = .none
    @State var hoursRounding: WorkHoursRoundingOptions = .none
    @State var wageFieldValue: Double = 0.0
    
    @State var travelTimeTracking: Bool = false
    
    @Binding var isShowingUserCreation: Bool
    
    
    var body: some View {
        Form {
            Section("User Information"){
                InputField("First Name", "person", text: $firstName)
                    .textContentType(.givenName)
                InputField("Last Name", "person", text: $lastName)
                    .textContentType(.familyName)
            }
            
            Section ("Settings"){
                Toggle("Enable Travel Time", systemImage: "clock", isOn: $travelTimeTracking)
            }
            
            Button {
                isShowingUserCreation = false
                saveUser()
            } label: {
                Text("Create User")
                    .scaledToFill()
                    .multilineTextAlignment(.center)
                    .padding(.vertical)
            }
            .listRowBackground(EmptyView())
            .buttonStyle(.borderedProminent)
            .buttonSizing(.flexible)
            .disabled(!isShowingUserCreation)
        }
        .navigationTitle("Profile")
    }
    
    func saveUser(){
        // TODO: New User Creation Logic
    }
}

#Preview {
    @Previewable @State var isPresented = true
    UserCreationView(isShowingUserCreation: $isPresented)
}
