import SwiftUI

struct CaseTextView: View {
    let legalCase: Case
    @State private var caseText: String?
    @State private var isLoading = true
    @State private var error: Error?
    
    var body: some View {
        Group {
            if let text = caseText {
                ScrollView {
                    Text(text)
                        .font(.body)
                        .padding()
                }
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        NavigationLink {
                            CaseDetailView(legalCase: legalCase, caseText: caseText)
                        } label: {
                            Text("Brief Case")
                        }
                    }
                }
            } else if isLoading {
                ProgressView("Loading case text...")
            } else if error != nil {
                Text("Failed to load case text")
            }
        }
        .navigationTitle(legalCase.title)
        .task {
            await loadCaseText()
        }
    }
    
    private func loadCaseText() async {
        do {
            caseText = try await APIService.shared.fetchFullText(for: legalCase.id)
        } catch {
            self.error = error
        }
        isLoading = false
    }
} 