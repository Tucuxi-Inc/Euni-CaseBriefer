import SwiftUI

struct CaseSearchView: View {
    @State private var searchText = ""
    @State private var searchResults: [Case] = []
    @State private var isSearching = false
    @State private var error: Error?
    
    var body: some View {
        List {
            ForEach(searchResults) { case_ in
                NavigationLink {
                    CaseTextView(legalCase: case_)
                } label: {
                    CaseListItem(legalCase: case_)
                }
            }
        }
        .navigationTitle("Search Cases")
        .searchable(text: $searchText, prompt: "Search by case name or citation")
        .onChange(of: searchText) { oldValue, newValue in
            Task {
                await performSearch()
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if isSearching {
                    ProgressView()
                }
            }
        }
        .alert("Error", isPresented: .constant(error != nil)) {
            Button("OK") { error = nil }
        } message: {
            if let error = error {
                Text(error.localizedDescription)
            }
        }
    }
    
    private func performSearch() async {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        defer { isSearching = false }
        
        do {
            searchResults = try await APIService.shared.searchCases(query: searchText)
        } catch {
            self.error = error
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    let onSubmit: () -> Void
    
    var body: some View {
        HStack {
            TextField("Search cases...", text: $text)
                .textFieldStyle(.roundedBorder)
                .submitLabel(.search)
                .onSubmit(onSubmit)
            
            Button(action: onSubmit) {
                Image(systemName: "magnifyingglass")
            }
        }
    }
}

struct ErrorView: View {
    let error: Error
    
    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)
            Text("Error")
                .font(.headline)
            Text(error.localizedDescription)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
} 