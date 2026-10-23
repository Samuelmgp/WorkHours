//
//  UserCreationView.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-09-20.
//

import SwiftUI
import SwiftData

struct UserCreationView: View {
    
    var onCreated: () -> Void = {}
    
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var travelTimeTracking: Bool = false

    @State private var isProcessing: Bool = false
    
    @State private var errorMessage: String = ""
    
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
            
            !errorMessage.isEmpty ?
            Text(errorMessage)
                .font(.footnote)
                .tint(.red)
            : nil
            
            Button {
                isProcessing = true
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
            .disabled(isProcessing)
        }
        .navigationTitle("User Creation")
    }
    
    func saveUser(){
        // Validate Inputs:
        if (firstName.isEmpty && lastName.isEmpty){
            isProcessing = false
            errorMessage = "First Name & Last Name cannot be empty."
            return
        }
        
        // Otherwise save:
        let user = UserManager.shared.createUser(firstName: firstName, lastName: lastName, trackTravelTime: travelTimeTracking)
        
        if (user == nil){
            errorMessage = "An error occurred creating user. Task cannot be completed at this time."
            isProcessing = false
        } else {
            onCreated()
        }
    }
}

#Preview {
    NavigationView {
        UserCreationView()
    }
}
