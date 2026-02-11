//
//  Campus_Library_Borrowing_TrackerApp.swift
//  Campus Library Borrowing Tracker
//
//  Created by Derrick Mangari on 2026-02-10.
//

import SwiftUI
import CoreData

@main
struct Campus_Library_Borrowing_TrackerApp: App {
    let persistenceController = PersistenceController.shared
    

    var body: some Scene {
        WindowGroup {
            let ctx = persistenceController.container.viewContext
            ContentView()
                .environment(\.managedObjectContext, ctx)
                .environmentObject(LibraryHolder(ctx))
        }
    }
}
