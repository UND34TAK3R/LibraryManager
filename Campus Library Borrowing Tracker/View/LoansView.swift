//
//  LoansView.swift
//  Campus Library Borrowing Tracker
//
//  Created by Derrick Mangari on 2026-02-10.
//

import SwiftUI

struct LoansView: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject private var holder: LibraryHolder
    var activeLoans: [Loan] {
        holder.loans
            .filter { $0.status == "Active"}
            .sorted{ $0.borrowedAt ?? Date() > $1.borrowedAt ?? Date()}
    }
    
    var pastLoans: [Loan] {
        holder.loans.filter { $0.status == "Returned" }
            .sorted{ $0.borrowedAt ?? Date() > $1.borrowedAt ?? Date()}
    }
    
    var overdueLoans: [Loan] {
        holder.loans.filter { $0.status == "Overdue"}
            .sorted{ $0.borrowedAt ?? Date() > $1.borrowedAt ?? Date()}
    }
    var body: some View {
        NavigationStack{
            List{
                Section("Active Loans"){
                    ForEach(activeLoans) { l in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(l.books?.title ?? "Unknown Book")
                                    .font(.headline)
                                Text("Due: \(l.dueAt ?? Date(), style: .date)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text(l.members?.name ?? "Unknown Member")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                Section("Returned Loans"){
                    ForEach(pastLoans) { l in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(l.books?.title ?? "Unknown Book")
                                    .font(.headline)
                                Text("Due: \(l.dueAt ?? Date(), style: .date)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text(l.members?.name ?? "Unknown Member")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                Section("Overdue Loans"){
                    ForEach(overdueLoans) { l in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(l.books?.title ?? "Unknown Book")
                                    .font(.headline)
                                    .foregroundStyle(.red)
                                Text("Due: \(l.dueAt ?? Date(), style: .date)")
                                    .font(.subheadline)
                                    .foregroundStyle(.red)
                                Text(l.members?.name ?? "Unknown Member")
                                    .font(.subheadline)
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Loans")
            .onAppear {
                checkOverdueLoans()
            }
        }
    }
    
    
    private func checkOverdueLoans() {
        for loan in holder.loans {
            if loan.dueAt! < Date() && loan.status != "Returned" {
                holder.lateBook(loan, context)
            }
        }
    }
}

#Preview {
    LoansView()
}
