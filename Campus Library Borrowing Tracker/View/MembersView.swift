//
//  MembersView.swift
//  Campus Library Borrowing Tracker
//
//  Created by Derrick Mangari on 2026-02-10.
//

import SwiftUI

struct MembersView: View {
    
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject private var holder: LibraryHolder
    
    var body: some View {
        NavigationStack{
            List{
                ForEach(holder.members){ m in
                    NavigationLink(destination: MemberLoansView(member:m)){
                        HStack{
                            VStack{
                                Text(m.name ?? "Unknown")
                                    .font(.headline)
                                Text(m.email ?? "Unknown")
                                    .font(.subheadline)
                            }
                            Spacer()
                        }
                    }
                }.onDelete(perform: delete)
            }
            .navigationTitle("Members")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing){
                    NavigationLink {
                        AddMemberView()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear{holder.refreshAll(context)}
        }
    }
    
    private func delete(at offsets: IndexSet) {
        offsets.map { holder.members[$0] }.forEach { holder.deleteMember($0, context) }
    }
}

#Preview {
    MembersView()
}
