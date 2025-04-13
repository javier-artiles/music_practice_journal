import Foundation
import SwiftData

@Model
final class MusicPiece {
    var name: String
    
    init(name: String) {
        self.name = name
    }
}
