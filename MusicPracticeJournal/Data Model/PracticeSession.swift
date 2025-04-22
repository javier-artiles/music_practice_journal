import Foundation
import SwiftData

@Model
final class PracticeSession {
    var name: String
    var startTime: Date
    var practiceTasks: [PracticeTask]
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
        self.practiceTasks = practiceTasks
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
