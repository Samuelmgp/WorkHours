//
//  DeleteAccountOverview.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-09-23.
//

import SwiftUI
import SwiftData

struct DeleteAccountOverview: View {
    
    @Environment(\.modelContext) private var context
    
    @State var debounce: Bool = false
    
    @Binding var isPresented: Bool
    @Binding var user: UserModel?
    
    var body: some View {
        VStack(alignment: .center){
            Image(systemName: "exclamationmark.circle")
                .scaledToFit()
                .font(.system(size: 125))
                .foregroundStyle(.red)
            
            Text("Account Deletion Notice!")
                .font(.title)
            
            Text("You are about to delete your account. This will delete all the data that is currently stored and accessible. This cannot be undone. All data will be completely lost.")
                .font(.callout)
                .multilineTextAlignment(.center)
                
            HStack (spacing: 20){
                Button("Cancel"){
                    debounce = true
                    isPresented = false
                }
                .buttonStyle(.bordered)
                .disabled(debounce)
                
                Button("Delete"){
                    debounce = true
                    performDelete()
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .disabled(debounce)
            }
        }
        .padding(.horizontal, 10)
    }
    
    func performDelete(){
        // Delete all Work related details:
        do {
            try context.delete(model: PayPeriod.self)
            UserManager.shared.deleteUser()
            user = nil
            try context.save()
            isPresented = false
        } catch {
            print("Error Occurred: \(error)")
        }
    }
}

#Preview {
    @Previewable @State var isPresented: Bool = true
    @Previewable @State var user: UserModel? = nil
    
    DeleteAccountOverview(isPresented: $isPresented, user: $user)
}
