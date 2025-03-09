//
//  CaseBrieferApp.swift
//  CaseBriefer
//
//  Created by Kevin Keller on 3/4/25.
//

import SwiftUI
import SwiftData

@main
struct CaseBrieferApp: App {
    let modelContainer: ModelContainer
    
    init() {
        do {
            modelContainer = try ModelContainer(for: SavedBrief.self)
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}
