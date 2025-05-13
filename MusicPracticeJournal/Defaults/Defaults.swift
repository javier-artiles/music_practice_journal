import Foundation

enum BeatsPlayed: String, CaseIterable, Identifiable {
    case all = "All beats"
    case odd = "Odd beats"
    case even = "Even beats"
    
    var id: String { self.rawValue }
}

/// UserDefaults keys
struct Defaults {
    static let beatsPerMinute = "beatsPerMinute"
    static let beatsPerMeasure = "beatsPerMeasure"
    static let accentFirstBeatEnabled = "accentFirstBeatEnabled"
    static let beatsPlayed = "beatsPlayed"
    static let soundEnabled = "soundEnabled"
    
    /// Default values for UserDefaults keys
    static let defaults: [String: Any] = [
        beatsPerMinute: 120,
        beatsPerMeasure: 4,
        accentFirstBeatEnabled: true,
        beatsPlayed: BeatsPlayed.all.rawValue,
        soundEnabled: true
    ]
    
    /// Register the default values for user preferences.
    static func registerDefaults() {
        UserDefaults.standard.register(defaults: defaults)
    }
}
