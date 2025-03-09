import SwiftUI

struct BriefView: View {
    let briefText: String
    
    var body: some View {
        ScrollView {
            Text(briefText)
                .font(.body)
                .padding()
        }
        .navigationTitle("Case Brief")
    }
} 