import Foundation
import SwiftData

@Model
final class PracticeTask: Identifiable {
    var id = UUID()
    var technique: Technique?
    var work: Work?
    /// Persistent storage for subtasks (unordered by default)
    var practiceSubTasksPersistent: [PracticeSubTask]
    
    /// Computed property returning tasks sorted by `sortIndex`.
     var practiceSubTasks: [PracticeSubTask] {
         get {
             practiceSubTasksPersistent.sorted { $0.sortIndex < $1.sortIndex }
         }
         set {
             // Update the persistent array while maintaining order.
             practiceSubTasksPersistent = newValue
         }
     }
    
    var practiceNotes: [PracticeNote]
    var sortIndex: Int
    
    @Relationship(inverse: \PracticeSession.practiceTasksPersistent) var session: PracticeSession?
    
    init(technique: Technique? = nil, work: Work? = nil, practiceSubTasks: [PracticeSubTask] = [], practiceNotes: [PracticeNote] = [], sortIndex: Int = 0) {
        self.technique = technique
        self.work = work
        self.practiceSubTasksPersistent = practiceSubTasks
        self.practiceNotes = practiceNotes
        self.sortIndex = sortIndex
        self.session = nil
    }
    
    /// Helper method to add a subtask and sort automatically.
     func appendSubTask(_ subTask: PracticeSubTask) {
         if let lastSubTask = practiceSubTasksPersistent.last {
             subTask.sortIndex = lastSubTask.sortIndex + 1
         }
         practiceSubTasksPersistent.append(subTask)
         practiceSubTasksPersistent.sort { $0.sortIndex < $1.sortIndex }
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
