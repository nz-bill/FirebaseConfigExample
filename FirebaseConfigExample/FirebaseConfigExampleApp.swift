//
//  FirebaseConfigExampleApp.swift
//  FirebaseConfigExample
//
//  Created by Bill Palmestedt on 2025-05-07.
//

import SwiftUI

@main
struct FirebaseConfigExampleApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
