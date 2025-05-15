import Foundation
import SwiftData

@Model
final class PracticeSubTask {
    var id = UUID()
    var name: String?
    var practiceNotes: [PracticeNote]
    var sortIndex: Int
    
    @Relationship(deleteRule: .cascade, inverse: \AudioRecording.subTask)
    var audioRecordings: [AudioRecording]? = []
    
    @Relationship(inverse: \PracticeTask.practiceSubTasksPersistent)
    var task: PracticeTask?
    
    init(id: UUID = UUID(), name: String? = nil, practiceNotes: [PracticeNote] = [], sortIndex: Int = 0, audioRecordings: [AudioRecording] = []) {
        self.id = id
        self.name = name
        self.practiceNotes = practiceNotes
        self.sortIndex = sortIndex
        self.audioRecordings = audioRecordings
        self.task = nil
    }
    
    func generateDefaultAudioRecordingTitle() -> String {
        return "Recording #\((audioRecordings?.count ?? 0) + 1)"
    }
}
