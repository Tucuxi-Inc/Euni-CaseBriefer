import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)
    case emptyResponse
    case keychainError(KeychainError)
    case invalidAPIKey
    case unauthorized
    case serverError(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL configuration"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .emptyResponse:
            return "Empty response from server"
        case .keychainError(let error):
            return "Keychain error: \(error.localizedDescription)"
        case .invalidAPIKey:
            return "Invalid API key provided"
        case .unauthorized:
            return "Unauthorized access"
        case .serverError(let code):
            return "Server error: \(code)"
        }
    }
}

class APIService {
    static let shared = APIService()
    private let courtListenerBaseURL = "https://www.courtlistener.com"
    private let openAIBaseURL = "https://api.openai.com/v1"
    
    private var courtListenerAPIKey: String {
        do {
            let key = try KeychainManager.shared.getAPIKey(forService: "courtlistener")
            print("Debug - Retrieved key from keychain: \(key)")
            return key.replacingOccurrences(of: "Token ", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            print("Failed to retrieve CourtListener API key: \(error)")
            return ""
        }
    }
    
    private var openAIAPIKey: String {
        do {
            return try KeychainManager.shared.getAPIKey(forService: "openai")
        } catch {
            // In a production app, you might want to handle this differently
            return "YOUR_OPENAI_API_KEY"
        }
    }
    
    // Function to set up API keys (call this during app setup)
    func configureAPIKeys(courtListener: String, openAI: String) throws {
        print("Debug - Configuring API keys")
        print("Debug - CourtListener key length: \(courtListener.count)")
        
        guard !courtListener.isEmpty else {
            print("Error: Empty CourtListener API key")
            throw APIError.invalidAPIKey
        }
        
        do {
            try KeychainManager.shared.saveAPIKey(courtListener, forService: "courtlistener")
            try KeychainManager.shared.saveAPIKey(openAI, forService: "openai")
            print("Debug - API keys configured successfully")
        } catch let error as KeychainError {
            print("Debug - Keychain error: \(error)")
            throw APIError.keychainError(error)
        }
    }
    
    func searchCases(query: String) async throws -> [Case] {
        print("Debug - Starting case search with query: \(query)")
        
        // Construct the search URL with proper encoding and parameters
        var components = URLComponents(string: "\(courtListenerBaseURL)/api/rest/v4/search/")!
        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "type", value: "o"), // Search for opinions/case law
            URLQueryItem(name: "order_by", value: "score desc"), // Sort by relevance
            URLQueryItem(name: "format", value: "json")
        ]
        
        guard let url = components.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Add required headers
        let apiKey = try KeychainManager.shared.getAPIKey(forService: "courtlistener")
        request.addValue("Token \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        print("Debug - Request URL: \(url)")
        print("Debug - Request headers: \(request.allHTTPHeaderFields ?? [:])")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        // Debug response info
        print("API Response Status Code: \(httpResponse.statusCode)")
        print("API Response Headers: \(httpResponse.allHeaderFields)")
        
        if httpResponse.statusCode == 401 {
            throw APIError.unauthorized
        }
        
        if httpResponse.statusCode != 200 {
            if let responseStr = String(data: data, encoding: .utf8) {
                print("API Response Data: \(responseStr)")
            }
            throw APIError.serverError(httpResponse.statusCode)
        }
        
        do {
            let searchResponse = try JSONDecoder().decode(CourtListenerSearchResponse.self, from: data)
            return searchResponse.results.map { result in
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let date = dateFormatter.date(from: result.dateFiled) ?? Date()
                
                // Get the opinion ID from the opinions array
                let opinionId = result.opinions.first?.id ?? 0
                
                let citation = result.citation?.first ?? result.docketNumber ?? "No citation available"
                
                return Case(
                    id: String(opinionId),  // Use opinion ID instead of cluster_id
                    title: result.caseName,
                    citation: citation,
                    court: result.court,
                    dateFiled: date,
                    url: "https://www.courtlistener.com\(result.absolute_url)",
                    absoluteUrl: result.absolute_url
                )
            }
        } catch {
            print("Decoding error: \(error)")
            throw APIError.decodingError(error)
        }
    }
    
    func generateBrief(for fullText: String) async throws -> CaseBrief {
        let apiKey = try KeychainManager.shared.getAPIKey(forService: "openai")
        
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let prompt = """
        Please analyze this legal case and provide a brief in the following format:
        Case Title & Citation: [case name and citation]
        Parties: [identify the parties]
        Facts: [key facts of the case]
        Procedural History: [prior proceedings]
        Issue: [main legal question(s)]
        Holding: [court's decision]
        Rule: [relevant legal rules/principles]
        Reasoning: [court's analysis]
        
        Case text:
        \(fullText)
        """
        
        let requestBody: [String: Any] = [
            "model": "o3-mini",
            "messages": [
                ["role": "system", "content": "You are a legal assistant tasked with creating case briefs."],
                ["role": "user", "content": prompt]
            ],
            "reasoning_effort": "medium",
            "max_completion_tokens": 25000,  // Reserve space for reasoning and output
            "store": true  // Store the completion for analysis
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("Error: Not an HTTP response")
            throw APIError.invalidResponse
        }
        
        print("OpenAI Status Code: \(httpResponse.statusCode)")
        print("OpenAI Headers: \(httpResponse.allHeaderFields)")
        
        // Debug print the raw response
        if let responseString = String(data: data, encoding: .utf8) {
            print("OpenAI Raw Response: \(responseString)")
        }
        
        guard httpResponse.statusCode == 200 else {
            print("Error: Non-200 status code")
            throw APIError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        do {
            let openAIResponse = try decoder.decode(OpenAIResponse.self, from: data)
            print("Decoded OpenAI Response: \(openAIResponse)")
            
            guard let briefText = openAIResponse.choices.first?.message.content else {
                print("Error: No content in response")
                throw APIError.emptyResponse
            }
            
            print("Brief Text: \(briefText)")
            
            // Parse the brief text into sections
            let sections = parseBriefText(briefText)
            print("Parsed Sections: \(sections)")
            
            return CaseBrief(
                caseTitleCitation: sections["Case Title & Citation"] ?? "",
                parties: sections["Parties"] ?? "",
                facts: sections["Facts"] ?? "",
                proceduralHistory: sections["Procedural History"] ?? "",
                issue: sections["Issue"] ?? "",
                holding: sections["Holding"] ?? "",
                rule: sections["Rule"] ?? "",
                reasoning: sections["Reasoning"] ?? ""
            )
        } catch {
            print("Decoding Error: \(error)")
            throw APIError.decodingError(error)
        }
    }
    
    private func parseBriefText(_ text: String) -> [String: String] {
        var sections: [String: String] = [:]
        let lines = text.components(separatedBy: .newlines)
        var currentSection = ""
        var currentContent: [String] = []
        
        let sectionHeaders = [
            "Case Title & Citation",
            "Parties",
            "Facts",
            "Procedural History",
            "Issue",
            "Holding",
            "Rule",
            "Reasoning"
        ]
        
        for line in lines {
            if let header = sectionHeaders.first(where: { line.hasPrefix($0) }),
               line.contains(":") {
                if !currentSection.isEmpty {
                    sections[currentSection] = currentContent.joined(separator: "\n").trimmingCharacters(in: .whitespaces)
                    currentContent = []
                }
                currentSection = header
                let parts = line.split(separator: ":", maxSplits: 1).map(String.init)
                if parts.count > 1 {
                    currentContent.append(parts[1].trimmingCharacters(in: .whitespaces))
                }
            } else if !currentSection.isEmpty {
                currentContent.append(line)
            }
        }
        
        if !currentSection.isEmpty {
            sections[currentSection] = currentContent.joined(separator: "\n").trimmingCharacters(in: .whitespaces)
        }
        
        return sections
    }
    
    struct OpenAIResponse: Codable {
        let choices: [Choice]
        
        struct Choice: Codable {
            let message: Message
        }
        
        struct Message: Codable {
            let content: String
        }
    }
    
    func fetchFullText(for caseId: String) async throws -> String {
        print("Debug - Fetching full text for case ID: \(caseId)")
        
        let apiKey = try KeychainManager.shared.getAPIKey(forService: "courtlistener")
        
        guard let url = URL(string: "\(courtListenerBaseURL)/api/rest/v4/opinions/\(caseId)/") else {
            print("Debug - Invalid URL constructed for case ID: \(caseId)")
            throw APIError.invalidURL
        }
        
        print("Debug - Requesting full text from URL: \(url)")
        
        var request = URLRequest(url: url)
        request.setValue("Token \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("Debug - Not an HTTP response")
            throw APIError.invalidResponse
        }
        
        print("Debug - Full text response status code: \(httpResponse.statusCode)")
        
        if let responseStr = String(data: data, encoding: .utf8) {
            print("Debug - Response body: \(responseStr)")
        }
        
        guard httpResponse.statusCode == 200 else {
            if let errorText = String(data: data, encoding: .utf8) {
                print("Debug - Error response: \(errorText)")
            }
            throw APIError.serverError(httpResponse.statusCode)
        }
        
        do {
            let decoder = JSONDecoder()
            let opinion = try decoder.decode(OpinionDetail.self, from: data)
            
            // Try plain_text first
            if !opinion.plain_text.isEmpty {
                print("Debug - Using plain text content")
                return opinion.plain_text
            }
            
            // If no plain text, use html content and strip HTML tags
            if !opinion.html_with_citations.isEmpty {
                print("Debug - Using HTML content with citations")
                return stripHTMLTags(from: opinion.html_with_citations)
            }
            
            if !opinion.html.isEmpty {
                print("Debug - Using HTML content")
                return stripHTMLTags(from: opinion.html)
            }
            
            print("Debug - No content found in response")
            throw APIError.emptyResponse
            
        } catch {
            print("Debug - Decoding error: \(error)")
            throw APIError.decodingError(error)
        }
    }
    
    private func stripHTMLTags(from html: String) -> String {
        // Basic HTML tag stripping - you might want to use a more sophisticated approach
        let stripped = html.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        return stripped.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\n\\s*\n", with: "\n\n", options: .regularExpression)
    }
} 