//
//  PacBagApp.swift
//  PacBag
//
//  Created by Enricco Gemha on 18/06/25.
//

import SwiftUI

@main
struct PacBagApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
