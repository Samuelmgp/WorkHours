//
//  EmployerView.swift
//  WorkHours
//
//  Created by Samuel Garcia on 2026-10-21.
//

import SwiftUI
import SwiftData

struct EmployersView: View {
    
    @Environment(\.modelContext) private var context
    @Query(sort: \EmployerModel.employerName) private var employers: [EmployerModel]
    
    @State private var displayAddEmployer: Bool = false
    
    var body: some View {
        Group {
            if employers.count == 1 {
                
            } else if employers.count > 1 {
                List {
                    ForEach(employers, id: \.self) { employer in
                        // TODO: NavigationLink to EmployerView
                        EmployerCard(employerModel: employer)
                    }
                }
                .listStyle(.plain)
                .navigationTitle("Employers")
            } else {
                ContentUnavailableView("Unemployed", systemImage: "exclamationmark.circle", description: Text("Please add an employer to view Employer Information or a list of employers.")
                )
                .imageScale(.large)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing){
                Button {
                    displayAddEmployer = !displayAddEmployer
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $displayAddEmployer, content: {
            NavigationView(content: {
                EmployerCreationView()
            })
        })
    }

}

#Preview {
    NavigationView {
        EmployersView()
    }
}
