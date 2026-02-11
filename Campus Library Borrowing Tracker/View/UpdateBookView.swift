//
//  UodateBookView.swift
//  Campus Library Borrowing Tracker
//
//  Created by Derrick Mangari on 2026-02-10.
//

import SwiftUI
import CoreData

struct UpdateBookView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var holder: LibraryHolder
    
    @ObservedObject var book: Book
    @State private var title = ""
    @State private var isbn = ""
    @State private var author = ""
    @State private var selectedCategory: Category?
    
    var body: some View {
        Form{
            Section("Book"){
                TextField("Title", text: $title)
                TextField("Author", text: $author)
                TextField("ISBN", text: $isbn)
            }
            Section("Category"){
                Picker("Category", selection: $selectedCategory){
                    Text("None").tag(Category?.none)
                    ForEach(holder.categories){ cat in
                        Text(cat.name ?? "Category").tag(Category?.some(cat))
                    }
                }
            }
            Section{
                Button("Save"){
                    holder.updateBook(book: book, title: title, isbn: isbn, author: author, isAvailable: book.isAvailable, category: selectedCategory, context)
                    dismiss()
                }
                Button("Delete Book", role: .destructive){
                    holder.deleteBook(book, context)
                    dismiss()
                }
            }
        }
        .navigationTitle("Edit Book")
        .onAppear{
            holder.refreshCategories(context)
            
            title = book.title ?? ""
            author = book.author ?? ""
            isbn = book.isbn ?? ""
            selectedCategory = book.categories
        }
    }
}

//#Preview {
   // UpdateBookView()
//}
