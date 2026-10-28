//
//  InputField.swift
//  Modules
//
//  Created by Samuel Garcia on 2026-10-09.
//

import SwiftUI

/*
 * Adding some styling effects to input fields.
 * There are some pre programmed option styles.
 * Bordered: Generates a basic rounded border around the input field.
 * Modern: Generates a linear spacer at the bottom of the input field.
 * Specialized: Generates a bubble styled border & background around the input field.
 * Plain: Just the input field.
 */
enum InputFieldStyle: ViewModifier {
    
    case bordered
    case modern
    case plain
    case specialized
    
    func body(content: Content) -> some View {
        switch self {
        case .bordered: content
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(.secondary, lineWidth: 1.5)
                        .shadow(color: .primary.opacity(0.8), radius: 8, y: 4)
                )
                .padding(.horizontal)
        case .modern: content
                .overlay(
                    Rectangle().fill(
                        LinearGradient(colors: [.blue, .green], startPoint: .bottomLeading, endPoint: .bottomTrailing)
                        )
                    .frame(height: 1.5)
                        .offset(y: 25)
                        .scaleEffect(x: 0.9)
                )
                .padding(.horizontal)
        case .specialized:
                    content
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(.ultraThinMaterial)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(
                                    LinearGradient(
                                        colors: [.blue.opacity(1), .green.opacity(1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                        .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
                        .padding(.horizontal)
        case .plain: content
                .padding(.horizontal)
        }
    }
}

extension View {
    func inputFieldStyle(_ style: InputFieldStyle) -> some View {
        modifier(style)
    }
}

struct InputField: View {
    
    @State var placeholder: String
    @State var systemName: String
    @Binding var text: String
    @State var toggleSecurity: Bool
    
    let isSecure: Bool
    
    /**
     * Standardized Component for a custom TextField / InputField. This component comes equipt with 3 variations.
     * Standard TextField, IconTextField, and a Secure option.
     * - Parameters: placeholder?, systemName?, text, secure?
     * - Returns: InputField View.
     */
    
    init(_ placeholder: String, _ systemName: String, text: Binding<String>, _ secure: Bool = false) {
        self.placeholder = placeholder
        self.systemName = systemName
        self._text = text
        self.isSecure = secure
        self.toggleSecurity = secure
    }
    
    init(systemName: String, text: Binding<String>, secure: Bool){
        self.init("Placeholder", systemName, text: text, secure)
    }
    
    init(systemName: String, text: Binding<String>){
        self.init("Placeholder", systemName, text: text)
    }
    
    init(text: Binding<String>, secure: Bool){
        self.init("Placeholder", "", text: text, secure)
    }
    
    init(text: Binding<String>){
        self.init("Placeholder", "", text: text)
    }
    
    var body: some View {
        HStack {
            systemName.isEmpty ? nil : Image(systemName: systemName)
            if (toggleSecurity) {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
            isSecure ? Button {
                toggleSecurity = !toggleSecurity
            } label: { Image(systemName: "eye") }
                .tint(.blue.opacity(0.8)): nil
        }
        .padding()
    }
}



#Preview {
    @Previewable @State var text: String = ""
    InputField(text: $text)
        .inputFieldStyle(.bordered)
    InputField(systemName: "person", text: $text)
        .inputFieldStyle(.modern)
    InputField(systemName: "lock", text: $text, secure: true)
        .inputFieldStyle(.specialized)
}
