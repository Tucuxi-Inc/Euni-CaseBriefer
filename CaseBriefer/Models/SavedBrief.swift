import SwiftData
import Foundation

@Model
class SavedBrief {
    var title: String
    var citation: String
    var court: String
    var dateFiled: Date
    var briefContent: String
    var dateCreated: Date
    
    init(title: String, citation: String, court: String, dateFiled: Date, briefContent: String) {
        self.title = title
        self.citation = citation
        self.court = court
        self.dateFiled = dateFiled
        self.briefContent = briefContent
        self.dateCreated = Date()
    }
} 