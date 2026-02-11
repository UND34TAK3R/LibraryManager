//
//  AddMemberView.swift
//  Campus Library Borrowing Tracker
//
//  Created by Derrick Mangari on 2026-02-10.
//

import SwiftUI

struct AddMemberView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var holder: LibraryHolder
    
    @State private var name = ""
    @State private var email = ""
    
    var body: some View {
        Form{
            Section("Member Information"){
                TextField("Name", text: $name)
                TextField("Email", text: $email)
            }
            Section{
                Button("Save"){
                    holder.createMember(name: name, email: email, context)
                    dismiss()
                }
                Button("Cancel Member", role: .destructive){
                    dismiss()
                }
            }
        }
        .navigationTitle("Add Member")
    }
}

#Preview {
    AddMemberView()
}
