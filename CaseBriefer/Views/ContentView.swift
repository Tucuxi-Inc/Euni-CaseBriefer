import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var showSettings = false
    
    var body: some View {
        NavigationStack {
            TabView {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                
                SavedBriefsView()
                    .tabItem {
                        Label("History", systemImage: "clock")
                    }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gear")
                    }
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                SettingsView()
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: SavedBrief.self, inMemory: true)
}
