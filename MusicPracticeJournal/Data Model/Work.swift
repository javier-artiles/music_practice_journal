import Foundation
import SwiftData

@Model
final class Work: Decodable {
    enum CodingKeys: CodingKey {
        case i
        case w
        case a
        case c
        case n
    }
    
    var id: String
    var title: String
    var alternativeTitle: String?
    var composerName: String?
    var composerId: String?
    var instrumentation: [String]
    var isUserCreated: Bool
    
    internal init(id: String, title: String, alternativeTitle: String? = nil, composerName: String? = nil, composerId: String? = nil, instrumentation: [String] = [], isUserCreated: Bool = false) {
        self.id = id
        self.title = title
        self.alternativeTitle = alternativeTitle
        self.composerName = composerName
        self.composerId = composerId
        self.instrumentation = instrumentation
        self.isUserCreated = isUserCreated
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .i)
        self.title = try container.decode(String.self, forKey: .w)
        self.alternativeTitle = try container.decodeIfPresent(String.self, forKey: .a)
        
        let composerField = try container.decode(String.self, forKey: .c)
        let composerFieldRegex = /\[(?<name>.+?)\]\(.+?"(?<id>.+?)"\)/
        if let result = try? composerFieldRegex.wholeMatch(in: composerField) {
            self.composerId = String(result.id)
            self.composerName = String(result.name)
        } else {
            self.composerId = nil
            self.composerName = nil
        }
        
        let instrumentationString = try container.decodeIfPresent(String.self, forKey: .n)
        if let ins = instrumentationString {
            self.instrumentation = ins.lowercased()
                .components(separatedBy: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
        } else {
            self.instrumentation = []
        }
        self.isUserCreated = false
    }
}


