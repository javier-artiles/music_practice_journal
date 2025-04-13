import Foundation
import SwiftData

@Model
final class PracticePlan {
    var name: String = ""
    var practiceItems: [PracticeItem] = []
    
    init(name: String, practiceItems: [PracticeItem]) {
        self.name = name
        self.practiceItems = practiceItems
    }
}
