import Foundation
import SwiftData

@Model
final class Technique: Decodable {
    enum CodingKeys: CodingKey {
        case name
        case classification
    }
    
    var name: String
    var classification: String
    
    internal init(name: String, classification: String = "General") {
        self.name = name
        self.classification = classification
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.classification = try container.decode(String.self, forKey: .classification)
    }
}
