//
//  NewUserStartUp.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-10-22.
//

import SwiftUI

struct OnboardingView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @Binding var onboardingComplete: Bool
    
    @State private var currentStep: OnboardingStep = .user

        enum OnboardingStep {
            case user
            case employer
        }

        var body: some View {
            NavigationStack {
                Group {
                    switch currentStep {
                    case .user:
                        UserCreationView {
                            currentStep = .employer
                        }

                    case .employer:
                        EmployerCreationView(onComplete: {
                            onboardingComplete = true
                            dismiss()
                        },
                        onCancel:  {
                            onboardingComplete = true
                            dismiss()
                        })
                    }
                }
            }
        }
}

#Preview {
    @Previewable @State var onboardingComplete = false
    OnboardingView(onboardingComplete: $onboardingComplete)
}
