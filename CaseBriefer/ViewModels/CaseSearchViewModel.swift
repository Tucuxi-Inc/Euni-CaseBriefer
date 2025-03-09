import Foundation
import SwiftUI
import SwiftData

@MainActor
class CaseSearchViewModel: ObservableObject {
    @Published var searchQuery = ""
    @Published var searchResults: [Case] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var showError = false
    @Published var selectedCase: Case?
    @Published var isGeneratingBrief = false
    @Published var brief: CaseBrief?
    
    private let apiService = APIService.shared
    @Environment(\.modelContext) private var modelContext
    
    func searchCases() async {
        guard !searchQuery.isEmpty else { return }
        
        isLoading = true
        error = nil
        showError = false
        
        do {
            searchResults = try await apiService.searchCases(query: searchQuery)
        } catch {
            self.error = error
            self.showError = true
        }
        
        isLoading = false
    }
    
    func generateBrief(for legalCase: Case) {
        isGeneratingBrief = true
        
        Task {
            do {
                // Extract the ID from the absolute_url
                let absoluteUrl = legalCase.absoluteUrl
                let components = absoluteUrl.split(separator: "/")
                guard let idString = components.dropLast().last.map(String.init) else {
                    throw APIError.invalidURL
                }
                
                // First fetch the full text
                let fullText = try await apiService.fetchFullText(for: idString)
                
                // Then generate the brief
                let brief = try await apiService.generateBrief(for: fullText)
                
                // Save the brief
                await MainActor.run {
                    modelContext.insert(brief)
                    self.brief = brief
                    isGeneratingBrief = false
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    showError = true
                    isGeneratingBrief = false
                }
            }
        }
    }
} 