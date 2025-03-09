import SwiftUI
import SwiftData

struct SavedBriefDetailView: View {
    let brief: SavedBrief
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(brief.title)
                        .font(.title)
                    Text(brief.citation)
                        .font(.subheadline)
                    Text(brief.court)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Briefed on \(brief.dateCreated, style: .date)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom)
                
                // Brief content
                Text(brief.briefContent)
                    .font(.body)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
} 