import Foundation
import SwiftData

@Model
final class PracticeTask: Identifiable {
    var id = UUID()
    var technique: Technique?
    var work: Work?
    var practiceSubTasks: [PracticeSubTask]
    var practiceNotes: [PracticeNote]
    
    init(technique: Technique? = nil, work: Work? = nil, practiceSubTasks: [PracticeSubTask] = [], practiceNotes: [PracticeNote] = []) {
        self.technique = technique
        self.work = work
        self.practiceSubTasks = practiceSubTasks
        self.practiceNotes = practiceNotes
    }
    
    func getName() -> String {
        if technique == nil && work == nil {
            return "Untitled"
        } else if technique != nil && work == nil {
            return technique!.name
        } else if work != nil && technique == nil {
            return work!.title
        } else {
            return "\(work!.title) / \(technique!.name)"
        }
    }
    
    func getTitle() -> String {
        if let technique = technique {
            return technique.name
        } else if let work = work {
            return work.title
        } else {
            return "Untitled"
        }
    }
}
