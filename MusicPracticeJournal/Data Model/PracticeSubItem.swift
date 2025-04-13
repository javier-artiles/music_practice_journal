import Foundation
import SwiftData

@Model
final class PracticeSubItem {
    var id = UUID()
    var name: String?
    var practiceNotes: [PracticeNote]
    
    init(id: UUID = UUID(), name: String? = nil, practiceNotes: [PracticeNote] = []) {
        self.id = id
        self.name = name
        self.practiceNotes = practiceNotes
    }
}
