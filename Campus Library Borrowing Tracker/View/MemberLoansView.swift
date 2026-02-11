//
//  MemberLoansView.swift
//  Campus Library Borrowing Tracker
//
//  Created by Derrick Mangari on 2026-02-11.
//
import SwiftUI
import CoreData
import Combine

struct MemberLoansView: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject private var holder: LibraryHolder
    
    @State var member: Member
    
    var activeLoans: [Loan] {
        holder.loans.filter { $0.members == member && $0.status == "Active" }
    }
    
    var pastLoans: [Loan] {
        holder.loans.filter { $0.members == member && $0.status == "Returned" }
    }
    
    var body: some View {
        List {
            Section("Active Loans") {
                if activeLoans.isEmpty {
                    Text("No active loans")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(activeLoans) { l in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(l.books?.title ?? "Unknown Book")
                                    .font(.headline)
                                Text("Due: \(l.dueAt ?? Date(), style: .date)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button {
                                holder.returnBook(l, context)
                                holder.refreshAll(context)
                            } label: {
                                Text("Return")
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                }
            }
            
            Section("Past Loans") {
                if pastLoans.isEmpty {
                    Text("No past loans")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(pastLoans) { l in
                        VStack(alignment: .leading) {
                            Text(l.books?.title ?? "Unknown Book")
                                .font(.headline)
                            Text("Returned: \(l.returnedAt ?? Date(), style: .date)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Member's Loans")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    AddLoanMemberView(member: member)
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .onAppear {
            holder.refreshLoans(context)
        }
    }
}
