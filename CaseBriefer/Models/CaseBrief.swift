import Foundation
import SwiftData

@Model
final class CaseBrief {
    var caseTitleCitation: String
    var parties: String
    var facts: String
    var proceduralHistory: String
    var issue: String
    var holding: String
    var rule: String
    var reasoning: String
    var timestamp: Date
    var qualityScore: Int
    var qualityFlags: [String]
    
    init(caseTitleCitation: String, parties: String, facts: String, proceduralHistory: String, 
         issue: String, holding: String, rule: String, reasoning: String) {
        self.caseTitleCitation = caseTitleCitation
        self.parties = parties
        self.facts = facts
        self.proceduralHistory = proceduralHistory
        self.issue = issue
        self.holding = holding
        self.rule = rule
        self.reasoning = reasoning
        self.timestamp = Date()
        self.qualityScore = 0
        self.qualityFlags = []
    }
} 