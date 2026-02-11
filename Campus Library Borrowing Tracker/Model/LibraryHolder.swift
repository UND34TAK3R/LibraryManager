//
//  LibraryHolder.swift
//  Campus Library Borrowing Tracker
//
//  Created by Derrick Mangari on 2026-02-10.
//

import SwiftUI
import CoreData
import Combine

final class LibraryHolder: ObservableObject{
    //MARK: UI STATE
    @Published var selectedCategory: Category? = nil
    @Published var searchText: String = ""
    
    //MARK: - Published Data
    @Published var categories: [Category] = []
    @Published var books: [Book] = []
    @Published var loans: [Loan] = []
    @Published var members: [Member] = []
    
    init(_ context: NSManagedObjectContext) {
        seedIfNeeded(context)
        refreshAll(context)
    }
    //MARK: - REFRESH FUNCTIONS
    func refreshAll(_ context: NSManagedObjectContext){
        refreshCategories(context)
        refreshBooks(context)
        refreshLoans(context)
        refreshMembers(context)
    }
    func refreshCategories(_ context: NSManagedObjectContext){
        categories = fetchCategories(context)
    }
    func refreshBooks(_ context: NSManagedObjectContext){
        books = fetchBooks(context)
    }
    func refreshLoans(_ context: NSManagedObjectContext){
        loans = fetchLoans(context)
    }
    func refreshMembers(_ context: NSManagedObjectContext){
        members = fetchMembers(context)
    }
    //MARK: - FETCHERS
    func fetchCategories(_ context: NSManagedObjectContext) -> [Category]{
        do{ return try context.fetch(categoriesFetch())}
        catch { fatalError("Unresolved Error: \(error)")}
    }
    func fetchBooks(_ context: NSManagedObjectContext) -> [Book]{
        do{ return try context.fetch(booksFetch())}
        catch { fatalError("Unresolved Error: \(error)")}
    }
    func fetchLoans(_ context: NSManagedObjectContext) -> [Loan]{
        do{ return try context.fetch(loansFetch())}
        catch { fatalError("Unresolved Error: \(error)")}
    }
    func fetchMembers(_ context: NSManagedObjectContext) -> [Member]{
        do{ return try context.fetch(membersFetch())}
        catch { fatalError("Unresolved Error: \(error)")}
    }
    //MARK: - FETCH REQUESTS
    func categoriesFetch() -> NSFetchRequest<Category>{
        let request = Category.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Category.name, ascending: true)
        ]
        return request
    }
    func booksFetch() -> NSFetchRequest<Book>{
        let request = Book.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Book.title, ascending: true),
            NSSortDescriptor(keyPath: \Book.addedAt, ascending: true)
        ]
        request.predicate = booksPredicate()
        return request
    }
    func loansFetch() -> NSFetchRequest<Loan>{
        let request = Loan.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Loan.status, ascending: true),
            NSSortDescriptor(keyPath: \Loan.dueAt, ascending: true)
        ]
        return request
    }
    func membersFetch() -> NSFetchRequest<Member>{
        let request = Member.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Member.name, ascending: true),
            NSSortDescriptor(keyPath: \Member.joinedAt, ascending: true)
        ]
        return request
    }
    //MARK: - PREDICATE
    private func booksPredicate() -> NSPredicate? {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        var parts: [NSPredicate] = []
        if let category = selectedCategory {
            parts.append(NSPredicate(format: "categories == %@", category))
        }
        if !trimmed.isEmpty {
            parts.append(
                NSPredicate(
                    format: "(title CONTAINS[cd] %@) OR (author CONTAINS[cd] %@)",
                    trimmed, trimmed))
        }
        if parts.isEmpty { return nil }
        if parts.count == 1 { return parts[0] }
        return NSCompoundPredicate(andPredicateWithSubpredicates: parts)
    }

    //MARK: - FILTER CONTROLS
    func setCategory(_ category: Category?, _ context: NSManagedObjectContext){
        selectedCategory = category
        //refresh Books
        refreshBooks(context)
    }
    func setSearch(_ text: String, _ context: NSManagedObjectContext){
        searchText = text
        //refresh books
        refreshBooks(context)
    }
    //MARK: - BORROW/RETURN LOGIC
    func borrowBook(_ book: Book, selectedMember: Member, _ context: NSManagedObjectContext){
        let l = Loan(context: context)
        l.id = UUID()
        l.books = book
        l.borrowedAt = Date()
        l.members = selectedMember
        l.returnedAt = nil
        l.status = "Active"
        l.dueAt = Date().addingTimeInterval(60*60*24*7)
        
        book.isAvailable = false
        
        saveContext(context)
        refreshAll(context)
    }
    
    func returnBook(_ loan: Loan, _ context: NSManagedObjectContext){
        loan.status = "Returned"
        loan.returnedAt = Date()
        
        loan.books?.isAvailable = true
        
        saveContext(context)
        refreshAll(context)
    }
    
    func lateBook(_ loan:Loan, _ context: NSManagedObjectContext){
        if Date() > loan.dueAt!{
            loan.status = "Overdue"
        }
        saveContext(context)
        refreshAll(context)
    }
    
    //MARK: - CRUD MEMBERS
    func createMember(name: String, email: String, _ context: NSManagedObjectContext){
        let n = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let e = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !n.isEmpty, !e.isEmpty else {return}
        
        let m = Member(context: context)
        m.id = UUID()
        m.name = n
        m.email = e
        m.joinedAt = Date()
        saveContext(context)
    }
    func deleteMember(_ member:Member, _ context: NSManagedObjectContext){
        context.delete(member)
        saveContext(context)
    }
    //MARK: - CRUD BOOKS
    func createBook(title: String, isbn: String?, author: String, category: Category?, _ context: NSManagedObjectContext){
        let t = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let a = author.trimmingCharacters(in: .whitespacesAndNewlines)
        let isbn = isbn?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty, !a.isEmpty else {return}
        
        let b = Book(context: context)
        b.id = UUID()
        b.title = t
        b.author = a
        b.addedAt = Date()
        b.isAvailable = true
        b.categories = category
        if isbn == nil { b.isbn = ""}
        else {b.isbn = isbn!}
    
        saveContext(context)
    }
    func updateBook(
        book: Book,
        title: String,
        isbn: String?,
        author: String,
        isAvailable: Bool,
        category: Category?,
        _ context: NSManagedObjectContext
    ){
        book.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        book.author = author.trimmingCharacters(in: .whitespacesAndNewlines)
        book.isbn = isbn?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        book.isAvailable = isAvailable
        book.categories = category
    
        saveContext(context)
    }
    func deleteBook(_ book: Book, _ context: NSManagedObjectContext){
        context.delete(book)
        saveContext(context)
    }
    //MARK: - CRUD CATEGORIES
    func createCategory(name: String, _ context: NSManagedObjectContext){
        let n = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !n.isEmpty else {return}
        
        let c = Category(context: context)
        c.id = UUID()
        c.name = n
        saveContext(context)
    }
    func deleteCategory(_ category: Category, context: NSManagedObjectContext){
        if selectedCategory == category {
            selectedCategory = nil
        }
        context.delete(category)
        saveContext(context)
    }
    //MARK: - SEED
    private func seedIfNeeded(_ context: NSManagedObjectContext){
        let req = Category.fetchRequest()
        req.fetchLimit = 1
        let count = (try? context.count(for: req)) ?? 0
        guard count == 0 else {return}
        
        let fantasy = Category(context: context)
        fantasy.id = UUID()
        fantasy.name = "Fantasy"
        
        let sci_fi = Category(context: context)
        sci_fi.name = "Sci-Fi"
        sci_fi.id = UUID()
        
        let b1 = Book(context: context)
        b1.id = UUID()
        b1.title = "The Hobbit"
        b1.isbn = "321"
        b1.author = "J.R.R Tolkien"
        b1.addedAt = Date()
        b1.isAvailable = true
        b1.categories = fantasy
        
        let b2 = Book(context: context)
        b2.id = UUID()
        b2.title = "Dune"
        b2.isbn = "431"
        b2.author = "Frank Herbert"
        b2.addedAt = Date()
        b2.isAvailable = true
        b2.categories = sci_fi
        
        saveContext(context)
    }
    //MARK: - SAVE
    func saveContext(_ context: NSManagedObjectContext){
        do {
            try context.save()
            // refresh content
            refreshAll(context)
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}



