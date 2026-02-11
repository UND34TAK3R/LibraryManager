//
//  AddLoanMemberView.swift
//  Campus Library Borrowing Tracker
//
//  Created by Derrick Mangari on 2026-02-11.
//

import SwiftUI
import CoreData

struct AddLoanMemberView: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject private var holder: LibraryHolder
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchDraft: String = ""
    private let cols = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    @State var member: Member
    var body: some View {
        NavigationStack{
            VStack(spacing:10){
                //Search
                HStack{
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Search Books...", text: $searchDraft)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                .padding(12)
                .background(.secondary.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal)
                .onChange(of: searchDraft) { _, newValue in
                    holder.setSearch(newValue, context)
                }
                categoryBar
                ScrollView{
                    LazyVGrid(columns: cols, spacing: 12){
                        ForEach(holder.books) { b in
                            BookLoanCard(book: b){
                                holder.borrowBook(b, selectedMember:member, context)
                                dismiss()
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                }
            }
            .navigationTitle("Books")
            .onAppear{
                holder.refreshAll(context)
                searchDraft = holder.searchText
            }
        }
    }
    
    private var categoryBar: some View {
        ScrollView(.horizontal, showsIndicators: false){
            HStack(spacing: 12){
                Button{
                    holder.setCategory(nil, context)
                } label: {
                    Text("All")
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            holder.selectedCategory == nil
                            ? Color.primary.opacity(0.12)
                            : Color.clear
                        )
                        .clipShape(Capsule())
                }
                ForEach(holder.categories) { c in
                    Button{
                        holder.setCategory(c, context)
                    } label: {
                        Text(c.name ?? "Category")
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                holder.selectedCategory == c
                                ? Color.primary.opacity(0.12)
                                : Color.clear
                            )
                            .clipShape(Capsule())
                    }
                }
            }.padding(.horizontal)
        }
    }
}


struct BookLoanCard: View{
    let book: Book
    let onAdd: () -> Void
    
    var body: some View{
        VStack(alignment: .leading, spacing: 10){
            ZStack{
                RoundedRectangle(cornerRadius: 16)
                    .fill(.secondary.opacity(0.12))
                    .frame(height: 110)
                Image(systemName: "book")
                    .font(.system(size: 34, weight: .semibold))
            }
            Text(book.title ?? "Book")
                .font(.headline)
                .lineLimit(1)
            Text(book.author ?? "Author")
                .font(.subheadline)
                .lineLimit(1)
            Text(book.isbn ?? "isbn")
                .font(Font.subheadline.italic())
                .lineLimit(1)
            
            Button(action: onAdd) {
                Label("Borrow", systemImage: "cart.badge.plus")
                    .frame(maxWidth: .infinity)
            }
            .disabled(!book.isAvailable)
            .buttonStyle(.borderedProminent)
        }
        .padding(12)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(.secondary.opacity(0.15), lineWidth: 1)
        )
    }
}
//#Preview {
 //   AddLoanMemberView()
//}
