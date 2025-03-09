import SwiftUI

struct CaseListItem: View {
    let legalCase: Case
    
    var body: some View {
        NavigationLink(destination: CaseTextView(legalCase: legalCase)) {
            VStack(alignment: .leading, spacing: 8) {
                Text(legalCase.title)
                    .font(.headline)
                
                HStack {
                    Text(legalCase.citation)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(legalCase.dateFiled, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(legalCase.court)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        }
        .padding(.horizontal)
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
} 