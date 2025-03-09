struct CaseBriefDTO: Codable {
    let caseTitleCitation: String
    let parties: String
    let facts: String
    let proceduralHistory: String
    let issue: String
    let holding: String
    let rule: String
    let reasoning: String
    
    private enum CodingKeys: String, CodingKey {
        case caseTitleCitation = "case_title_citation"
        case parties
        case facts
        case proceduralHistory = "procedural_history"
        case issue
        case holding
        case rule
        case reasoning
    }
    
    func toCaseBrief() -> CaseBrief {
        return CaseBrief(
            caseTitleCitation: caseTitleCitation,
            parties: parties,
            facts: facts,
            proceduralHistory: proceduralHistory,
            issue: issue,
            holding: holding,
            rule: rule,
            reasoning: reasoning
        )
    }
} 