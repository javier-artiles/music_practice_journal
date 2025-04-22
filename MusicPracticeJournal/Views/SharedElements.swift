import Foundation
import SwiftUI

class SharedElements {
    static let techniqueIcon = "oar.2.crossed"
    static let workIcon = "music.quarternote.3"
    
    public static func getTechniqueImage(isUserCreated: Bool = false) -> some View {
        return Image(systemName: SharedElements.techniqueIcon)
            .fontWeight(.bold)
            .foregroundColor(isUserCreated ? .green : .gray)
    }
    
    public static func getWorkImage(isUserCreated: Bool = false) -> some View {
        return Image(systemName: SharedElements.workIcon)
            .fontWeight(.bold)
            .foregroundColor(isUserCreated ? .green : .gray)
    }
}
