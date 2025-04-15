import Foundation
import SwiftData

@Model
final class PracticeItem: Identifiable {
    var id = UUID()
    var technique: Technique?
    var musicPiece: MusicPiece?
    var practiceSubItems: [PracticeSubItem]
    var practiceNotes: [PracticeNote]
    
    init(technique: Technique? = nil, musicPiece: MusicPiece? = nil, practiceSubItems: [PracticeSubItem] = [], practiceNotes: [PracticeNote] = []) {
        self.technique = technique
        self.musicPiece = musicPiece
        self.practiceSubItems = practiceSubItems
        self.practiceNotes = practiceNotes
    }
    
    func getName() -> String {
        if technique == nil && musicPiece == nil {
            return "Untitled"
        } else if technique != nil && musicPiece == nil {
            return technique!.name
        } else if musicPiece != nil && technique == nil {
            return musicPiece!.name
        } else {
            return "\(musicPiece!.name) / \(technique!.name)"
        }
    }
    
    func getTitle() -> String {
        if let technique = technique {
            return technique.name
        } else if let musicPiece = musicPiece {
            return musicPiece.name
        } else {
            return "Untitled"
        }
    }
}
