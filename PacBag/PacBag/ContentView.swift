//
//  ContentView.swift
//  PacBag
//
//  Created by Enricco Gemha on 18/06/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject private var onboardingManager = OnboardingManager.shared
    
    var body: some View {
        Group {
            if onboardingManager.hasCompletedOnboarding {
                TripListView()
            } else {
                LandingPageView()
            }
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, CoreDataManager.shared.context)
}
