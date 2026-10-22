//
//  HSText.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-10-21.
//

import SwiftUI

struct HSText: View {
    
    @State var lhText: String
    @State var rhText: String
    @State var systemImage: String
    
    init(lhText: String, rhText: String, systemImage: String) {
        self.lhText = lhText
        self.rhText = rhText
        self.systemImage = systemImage
    }
    
    init(lhText:String, rhText: String){
        self.init(lhText: lhText, rhText: rhText, systemImage: "")
    }
    
    init(){
        self.init(lhText: "", rhText: "")
    }
    
    var body: some View {
        HStack {
            systemImage.isEmpty ? nil : Image(systemName: systemImage)
            Text(lhText)
            Spacer()
            Text(rhText)
        }
    }
}

#Preview {
    HSText()
}
