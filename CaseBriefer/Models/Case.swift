import Foundation
import SwiftData

@Model
final class Case: Identifiable {
    var id: String
    var title: String
    var citation: String
    var court: String
    var dateFiled: Date
    var url: String
    var absoluteUrl: String
    
    init(id: String, title: String, citation: String, court: String, dateFiled: Date, url: String, absoluteUrl: String) {
        self.id = id
        self.title = title
        self.citation = citation
        self.court = court
        self.dateFiled = dateFiled
        self.url = url
        self.absoluteUrl = absoluteUrl
    }
} 