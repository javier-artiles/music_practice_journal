import Foundation
import SwiftData

@Model
final class Technique {
    var name: String
    
    init(name: String) {
        self.name = name
    }
}
