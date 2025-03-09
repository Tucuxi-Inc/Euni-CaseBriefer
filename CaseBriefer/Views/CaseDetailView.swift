import SwiftUI
import SwiftData

struct CaseDetailView: View {
    let legalCase: Case?
    let caseText: String?
    @Environment(\.modelContext) private var modelContext
    @State private var sections: [String: String] = [:]
    @State private var isLoading = false
    @State private var error: Error?
    @State private var showError = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                CaseHeaderView(legalCase: legalCase)
                
                if isLoading {
                    ProgressView("Generating brief...")
                        .progressViewStyle(.circular)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if !sections.isEmpty {
                    CaseBriefView(sections: sections)
                } else {
                    Button(action: { Task { await generateBrief() } }) {
                        Text("Generate Brief")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isLoading)
                    .padding(.vertical)
                }
                
                if !sections.isEmpty {
                    let briefText = sections.map { key, value in
                        "\(key)\n\n\(value)"
                    }.joined(separator: "\n\n")
                    
                    NavigationLink("View Brief", destination: BriefView(briefText: briefText))
                        .buttonStyle(.bordered)
                }
            }
            .padding()
        }
        .navigationTitle(legalCase?.title ?? "Case Detail")
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(error?.localizedDescription ?? "Unknown error")
        }
        .task {
            await generateBrief()
        }
    }
    
    private func generateBrief() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let text: String
            if let providedText = caseText {
                text = providedText
            } else if let case_ = legalCase {
                text = try await APIService.shared.fetchFullText(for: case_.id)
            } else {
                throw NSError(domain: "CaseDetailView", code: 1, userInfo: [NSLocalizedDescriptionKey: "No case text available"])
            }
            
            let brief = try await APIService.shared.generateBrief(for: text)
            
            sections = [
                "Facts": brief.facts,
                "Issue": brief.issue,
                "Rule": brief.rule,
                "Analysis": brief.reasoning,
                "Conclusion": brief.holding
            ]
            
            // Save the brief if we have case information
            if let case_ = legalCase {
                let briefContent = sections.map { "\($0.key)\n\n\($0.value)" }.joined(separator: "\n\n")
                let savedBrief = SavedBrief(
                    title: case_.title,
                    citation: case_.citation,
                    court: case_.court,
                    dateFiled: case_.dateFiled,
                    briefContent: briefContent
                )
                modelContext.insert(savedBrief)
            }
        } catch {
            self.error = error
            showError = true
        }
    }
}

struct CaseHeaderView: View {
    let legalCase: Case?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(legalCase?.citation ?? "Unknown Case")
                .font(.headline)
            Text(legalCase?.court ?? "Unknown Court")
                .font(.subheadline)
            if let date = legalCase?.dateFiled {
                Text(date, style: .date)
                    .font(.caption)
            } else {
                Text("Unknown Date")
                    .font(.caption)
            }
        }
    }
}

struct CaseBriefView: View {
    let sections: [String: String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(Array(sections.keys.sorted()), id: \.self) { key in
                if let content = sections[key] {
                    BriefSection(title: key, content: content)
                }
            }
        }
    }
}

struct BriefSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(content)
                .font(.body)
        }
    }
} 