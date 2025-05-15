import Foundation
import SwiftData

@Model
final class AudioRecording {
    var id: String
    var type: String
    var title: String
    var dateRecorded: Date
    var note: String?
    var subTask: PracticeSubTask?
    
    init(id: String = UUID().uuidString, type: String = "m4a", title: String, subTask: PracticeSubTask, note: String? = nil, dateRecorded: Date = Date()) {
        self.id = id
        self.type = type
        self.title = title
        self.note = note
        self.subTask = subTask
        self.dateRecorded = dateRecorded
    }
    
    func getUrl() -> URL? {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        if let path = paths.first {
            let url = URL(fileURLWithPath: path).appendingPathComponent("\(id).\(type)")
            if FileManager.default.fileExists(atPath: url.path) {
                print("url: \(url.description)")
                return url
            } else {
                print("Couldn't find audio file at \(url.absoluteString)")
            }
            if let bundleUrl = Bundle.main.url(forResource: id, withExtension: "mp3") {
                if FileManager.default.fileExists(atPath: bundleUrl.path) {
                    print("bundleUrl: \(bundleUrl.description)")
                    return bundleUrl
                }
            }
            print("Couldn't find audio file in bundle at \(url.absoluteString)")
        }
        return nil
    }
}
