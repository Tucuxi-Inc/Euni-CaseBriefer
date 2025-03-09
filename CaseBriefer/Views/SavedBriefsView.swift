import SwiftUI
import SwiftData

struct SavedBriefsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SavedBrief.dateCreated, order: .reverse) private var savedBriefs: [SavedBrief]
    
    var body: some View {
        NavigationView {
            if savedBriefs.isEmpty {
                ContentUnavailableView("No Briefs Yet", 
                    systemImage: "doc.text",
                    description: Text("Your briefed cases will appear here")
                )
            } else {
                List {
                    ForEach(savedBriefs) { brief in
                        NavigationLink {
                            SavedBriefDetailView(brief: brief)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(brief.title)
                                    .font(.headline)
                                Text(brief.citation)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(brief.dateCreated, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .onDelete(perform: deleteBriefs)
                }
                .navigationTitle("Case History")
            }
        }
    }
    
    private func deleteBriefs(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(savedBriefs[index])
        }
        try? modelContext.save()
    }
} 