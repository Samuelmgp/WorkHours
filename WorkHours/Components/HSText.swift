//
//  HSText.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-10-21.
//

import SwiftUI

struct HSText: View {
    
    @State var lhText: String
    @State var mText: String
    @State var rhText: String
    @State var systemImage: String
    
    init(lhText: String, mText: String = "", rhText: String = "", systemImage: String = "") {
        self.lhText = lhText
        self.mText = mText
        self.rhText = rhText
        self.systemImage = systemImage
    }
    
    init(){
        self.init(lhText: "", rhText: "")
    }
    
    var body: some View {
        HStack {
            systemImage.isEmpty ? nil : Image(systemName: systemImage)
            Text(lhText)
            Spacer()
            if (!mText.isEmpty){
                Text(mText)
                Spacer()
            }
            Text(rhText)
        }
    }
}

#Preview {
    HSText()
}
