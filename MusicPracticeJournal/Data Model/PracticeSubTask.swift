import Foundation
import SwiftData

@Model
final class PracticeSubTask {
    var id = UUID()
    var name: String?
    var practiceNotes: [PracticeNote]
    var sortIndex: Int
    
    @Relationship(inverse: \PracticeTask.practiceSubTasksPersistent) var task: PracticeTask?
     
    
    init(id: UUID = UUID(), name: String? = nil, practiceNotes: [PracticeNote] = [], sortIndex: Int = 0) {
        self.id = id
        self.name = name
        self.practiceNotes = practiceNotes
        self.sortIndex = sortIndex
        self.task = nil
    }
}
