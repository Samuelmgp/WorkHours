//
//  ProfileView.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-09-20.
//

import SwiftUI

struct ProfileView: View {
    
    private var user: UserModel?
    
    init(user: UserModel? = UserManager.shared.user()) {
        self.user = user
    }
    
    var body: some View {
        if (user == nil){
            ContentUnavailableView("User Unavailable", systemImage: "exclamationmark.circle", description: Text("There has been an error loading the User. Please try again. If the error presists file a bug report."))
        } else {
            UserInformation(user: user!)
        }
    }
}

#Preview {
    ProfileView(user: UserModel(firstName: "Test", lastName: "User", trackTravelTime: true))
}
