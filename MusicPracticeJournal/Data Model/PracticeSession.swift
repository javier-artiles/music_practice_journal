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
    
    func getSecsSpentOnSubItem(_ subItem: PracticeSubItem) -> Int {
        return secsSpentPerSubItem[subItem.id] ?? 0
    }
    
    func getSecsSpentOnItem(_ item: PracticeItem) -> Int {
        var totalSecs = 0;
        for subItem in item.practiceSubItems {
            totalSecs += getSecsSpentOnSubItem(subItem)
        }
        return totalSecs;
    }
    
    func incrementSecsSpentOnSubItem(_ subItem: PracticeSubItem) {
        secsSpentPerSubItem[subItem.id, default: 0] += 1
    }
}
