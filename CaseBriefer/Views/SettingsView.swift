import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var courtListenerKey = ""
    @State private var openAIKey = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isSuccess = false
    @State private var isTestingAPI = false
    @State private var apiStatus: APIStatus = .unknown
    
    private let apiService = APIService.shared
    
    enum APIStatus {
        case unknown, success, failed
        
        var icon: String {
            switch self {
            case .unknown: return "questionmark.circle"
            case .success: return "checkmark.circle"
            case .failed: return "xmark.circle"
            }
        }
        
        var color: Color {
            switch self {
            case .unknown: return .gray
            case .success: return .green
            case .failed: return .red
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("API Keys") {
                    SecureField("CourtListener API Key", text: $courtListenerKey)
                        .textContentType(.password)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    
                    SecureField("OpenAI API Key", text: $openAIKey)
                        .textContentType(.password)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    
                    Button(action: saveAPIKeys) {
                        Text("Save Keys")
                    }
                }
                
                Section {
                    Text("Obtaining a CourtListener API Key:")
                    Link("https://www.courtlistener.com/help/api/rest/",
                         destination: URL(string: "https://www.courtlistener.com/help/api/rest/")!)
                }
                
                Section {
                    Text("Obtaining a OpenAI API Key:")
                    Link("https://platform.openai.com/docs/quickstart",
                         destination: URL(string: "https://platform.openai.com/docs/quickstart")!)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert(isSuccess ? "Success" : "Error", isPresented: $showAlert) {
                Button("OK") { 
                    if isSuccess {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                loadExistingKeys()
            }
        }
    }
    
    private func saveAPIKeys() {
        print("Debug - Saving keys")
        print("Debug - CourtListener key length: \(courtListenerKey.count)")
        
        do {
            try apiService.configureAPIKeys(
                courtListener: courtListenerKey.trimmingCharacters(in: .whitespacesAndNewlines),
                openAI: openAIKey.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            isSuccess = true
            alertMessage = "API keys saved successfully"
        } catch {
            isSuccess = false
            alertMessage = error.localizedDescription
        }
        showAlert = true
    }
    
    private func loadExistingKeys() {
        do {
            courtListenerKey = try KeychainManager.shared.getAPIKey(forService: "courtlistener")
            openAIKey = try KeychainManager.shared.getAPIKey(forService: "openai")
        } catch {
            // Keys don't exist yet, that's okay
            print("Debug - No existing keys found: \(error)")
        }
    }
}

#Preview {
    SettingsView()
} 