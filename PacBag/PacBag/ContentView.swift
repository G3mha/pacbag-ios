//
//  ContentView.swift
//  PacBag
//
//  Created by Enricco Gemha on 18/06/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        TripListView()
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, CoreDataManager.shared.context)
}
