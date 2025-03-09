import Foundation

// CourtListener API Response Models
struct CourtListenerResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [CourtListenerCase]
}

struct CourtListenerCase: Codable {
    let id: Int
    let caseName: String
    let citation: [String]?
    let court: String
    let dateFiled: String
    let snippet: String
    let absoluteUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case caseName = "case_name"
        case citation = "citations"
        case court = "court_name"
        case dateFiled = "date_filed"
        case snippet
        case absoluteUrl = "absolute_url"
    }
}

// OpenAI API Response Models
struct OpenAIResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: Message
}

struct Message: Codable {
    let content: String
}

struct CourtListenerSearchResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [SearchResult]
}

// For opinions in search results
struct OpinionSummary: Codable {
    let id: Int
    let author_id: Int?
    let joined_by_ids: [Int]?
    let type: String
    let download_url: String?
    let local_path: String?
}

// For individual opinion details
struct OpinionDetail: Codable {
    let id: Int
    let absolute_url: String
    let cluster_id: Int
    let author_id: Int?
    let html: String
    let html_with_citations: String
    let plain_text: String
}

struct SearchResult: Codable {
    let absolute_url: String
    let caseName: String
    let citation: [String]?
    let cluster_id: Int
    let court: String
    let dateFiled: String
    let docketNumber: String?
    let snippet: String?
    let opinions: [OpinionSummary]  // Changed from Opinion to OpinionSummary
    
    enum CodingKeys: String, CodingKey {
        case absolute_url
        case caseName
        case citation
        case cluster_id
        case court
        case dateFiled = "dateFiled"
        case docketNumber
        case snippet
        case opinions
    }
}

struct CourtListenerOpinion: Codable {
    let id: Int
    let absoluteUrl: String
    let caseName: String
    let citationCount: Int
    let dateFiled: String
    let docketNumber: String?
    let court: String
    let text: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case absoluteUrl = "absolute_url"
        case caseName = "case_name"
        case citationCount = "citation_count"
        case dateFiled = "date_filed"
        case docketNumber = "docket_number"
        case court
        case text
    }
} 