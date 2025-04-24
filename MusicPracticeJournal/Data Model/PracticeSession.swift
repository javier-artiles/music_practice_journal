import Foundation
import SwiftData

@Model
final class PracticeSession {
    var name: String
    var startTime: Date
    /// Persistent storage for tasks (unordered by default)
    var practiceTasksPersistent: [PracticeTask]
    /// Computed property returning tasks sorted by `sortIndex`.
    var practiceTasks: [PracticeTask] {
        get {
            practiceTasksPersistent.sorted { $0.sortIndex < $1.sortIndex }
        }
        set {
            // Update the persistent array while maintaining order.
            practiceTasksPersistent = newValue
        }
    }
    
    var secsSpentPerSubItem: [UUID: Int] = [:]
    
    init(startTime: Date = Date(), practiceTasks: [PracticeTask] = [], name: String = "") {
        self.startTime = startTime
        if !name.isEmpty {
            self.name = name
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.setLocalizedDateFormatFromTemplate("EEEE, MMMM dd")
            self.name = dateFormatter.string(from: startTime)
        }
        self.practiceTasksPersistent = practiceTasks
    }
    
    /// Helper method to add a task and sort automatically.
    func appendTask(_ task: PracticeTask) {
        if let lastTask = practiceTasksPersistent.last {
            task.sortIndex = lastTask.sortIndex + 1
        }
        practiceTasksPersistent.append(task)
        practiceTasksPersistent.sort { $0.sortIndex < $1.sortIndex }
    }
    
    func isDefaultName() -> Bool {
        return name == getDefaultSessionName()
    }
    
    func getDefaultSessionName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("EEEE, MMMM dd")
        return dateFormatter.string(from: self.startTime)
    }
    
    func getSecsSpentOnSubTask(_ subItem: PracticeSubTask) -> Int {
        return secsSpentPerSubItem[subItem.id] ?? 0
    }
    
    func getSecsSpentOnTask(_ item: PracticeTask) -> Int {
        var totalSecs = 0;
        for subItem in item.practiceSubTasks {
            totalSecs += getSecsSpentOnSubTask(subItem)
        }
        return totalSecs;
    }
    
    func getSecsSpentOnSession() -> Int {
        return secsSpentPerSubItem.reduce(0) {$0 + $1.value};
    }
    
    func incrementSecsSpentOnSubItem(_ subItem: PracticeSubTask) {
        secsSpentPerSubItem[subItem.id, default: 0] += 1
    }
}
