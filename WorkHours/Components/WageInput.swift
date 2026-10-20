//
//  WageInput.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-10-05.
//

import SwiftUI

struct WageInput: View {
    
    @Binding var value: Double
    
    var body: some View {
        HStack {
            Text("Pay / Hour")
            TextField("Wage", value: $value, format: .currency(code: "cad"))
                .multilineTextAlignment(.trailing)
                .keyboardType(.decimalPad)
                .scrollDismissesKeyboard(.immediately)
        }
    }
}

#Preview {
    
    @Previewable @State var v: Double = 0.0
    
    WageInput(value: $v)
}
