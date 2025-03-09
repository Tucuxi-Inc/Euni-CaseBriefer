import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                NavigationLink(destination: CaseSearchView()) {
                    HomeOptionCard(
                        title: "Search for a Case to Brief",
                        subtitle: "Search and brief cases from our database",
                        systemImage: "magnifyingglass"
                    )
                }
                
                NavigationLink(destination: CaseInputView()) {
                    HomeOptionCard(
                        title: "Provide a Case to Review",
                        subtitle: "Upload or paste your own case text",
                        systemImage: "doc.text"
                    )
                }
            }
            .padding()
            .navigationTitle("Euni™ - Case Briefer")
        }
    }
}

struct HomeOptionCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .font(.largeTitle)
                .foregroundColor(.blue)
                .frame(width: 60)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
} 