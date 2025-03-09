import SwiftUI

struct CaseSearchForm: View {
    @Binding var searchQuery: String
    @Binding var isAdvancedSearch: Bool
    @State private var caseName: String = ""
    @State private var citation: String = ""
    let onSubmit: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            if isAdvancedSearch {
                VStack(alignment: .leading, spacing: 12) {
                    TextField("Case Name (e.g., Roe v. Wade)", text: $caseName)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: caseName) { _, _ in
                            updateSearchQuery()
                        }
                    
                    TextField("Citation (e.g., 410 U.S. 113)", text: $citation)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: citation) { _, _ in
                            updateSearchQuery()
                        }
                }
            } else {
                SearchBar(text: $searchQuery, onSubmit: onSubmit)
            }
            
            Button(action: { isAdvancedSearch.toggle() }) {
                Text(isAdvancedSearch ? "Simple Search" : "Advanced Search")
                    .font(.caption)
            }
            .buttonStyle(.borderless)
        }
        .padding()
    }
    
    private func updateSearchQuery() {
        var components: [String] = []
        
        if !caseName.isEmpty {
            components.append("caseName:\"\(caseName)\"")
        }
        
        if !citation.isEmpty {
            components.append("citation:\"\(citation)\"")
        }
        
        searchQuery = components.joined(separator: " AND ")
    }
} 