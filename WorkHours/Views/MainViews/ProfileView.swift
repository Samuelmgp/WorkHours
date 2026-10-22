//
//  ProfileView.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-09-20.
//

import SwiftUI

struct ProfileView: View {
    
    private var user: UserModel?
    @State private var userPerformedDeletedAccount: Bool = false
    
    init(user: UserModel?) {
        self.user = user
    }
    
    var body: some View {
        if (user == nil){
            ContentUnavailableView("User Unavailable", systemImage: "exclamationmark.circle", description: Text("There has been an error loading the User. Please try again. If the error presists file a bug report."))
        } else {
            UserInformation(user: user!, userPerformedDeleteAccount: $userPerformedDeletedAccount)
                .fullScreenCover(isPresented: $userPerformedDeletedAccount){
                    DeleteAccountOverview(isPresented: $userPerformedDeletedAccount, user: user)
                }
        }
    }
}

#Preview {
    @Previewable var user: UserModel? = nil
    ProfileView(user: user)
}
