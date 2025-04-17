import Foundation
import SwiftData

@Model
final class PracticePlan {
    var name: String = ""
    var practiceTasks: [PracticeTask] = []
    
    init(name: String, practiceTasks: [PracticeTask]) {
        self.name = name
        self.practiceTasks = practiceTasks
    }
}
