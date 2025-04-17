import Foundation
import SwiftData

@Model
final class PracticeSession {
    var startTime: Date
    var practicePlan: PracticePlan
    var endTime: Date?
    
    var secsSpentPerSubItem: [UUID: Int] = [:]
    
    init(startTime: Date,  practicePlan: PracticePlan, endTime: Date? = nil) {
        self.startTime = startTime
        self.practicePlan = practicePlan
        self.endTime = endTime
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
