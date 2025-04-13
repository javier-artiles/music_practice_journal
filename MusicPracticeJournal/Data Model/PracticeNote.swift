import Foundation
import SwiftData

@Model
final class PracticeNote {
    var creationDate: Date
    var latestUpdate: Date
    var title: String
    var text: String
    
    init(creationDate: Date, latestUpdate: Date, title: String, text: String) {
        self.creationDate = creationDate
        self.latestUpdate = latestUpdate
        self.title = title
        self.text = text
    }
}
