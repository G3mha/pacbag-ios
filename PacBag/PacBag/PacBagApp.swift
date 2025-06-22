//
//  PacBagApp.swift
//  PacBag
//
//  Created by Enricco Gemha on 18/06/25.
//

import SwiftUI

@main
struct PacBagApp: App {
    let coreDataManager = CoreDataManager.shared
    let notificationManager = NotificationManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, coreDataManager.context)
                .onAppear {
                    // Check notification permissions on app launch
                    notificationManager.checkAuthorizationStatus()
                }
        }
    }
}
