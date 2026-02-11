//
//  ContentView.swift
//  Campus Library Borrowing Tracker
//
//  Created by Derrick Mangari on 2026-02-10.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        TabView{
            BooksView()
                .tabItem {
                    Label("Books", systemImage: "book.fill")
                }
            MembersView()
                .tabItem{
                    Label("Members", systemImage: "person.fill")
                }
            LoansView()
                .tabItem{
                    Label("Loans", systemImage: "bookmark.fill")
                }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()
#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
