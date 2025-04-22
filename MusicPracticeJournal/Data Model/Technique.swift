import Foundation
import SwiftData

@Model
final class Technique: Decodable {
    enum CodingKeys: CodingKey {
        case name
        case classification
    }
    
    var id: UUID = UUID()
    var name: String
    var classification: String
    var isUserCreated: Bool
    
    internal init(name: String, classification: String = "General", isUserCreated: Bool = false) {
        self.name = name
        self.classification = classification
        self.isUserCreated = isUserCreated
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.classification = try container.decode(String.self, forKey: .classification)
        self.isUserCreated = false
    }
}
