import Foundation
import AVFoundation
import Combine

enum BeatSound {
    case mute
    case defaultSound
    case accentedSound
}

enum TimeSignature: RawRepresentable, CaseIterable, Equatable {
    case oneTwo
    case twoTwo
    case threeTwo
    case fourTwo
    case fiveTwo
    case sixTwo
    case sevenTwo
    case eightTwo
    case nineTwo
    case tenTwo
    case elevenTwo
    case twelveTwo
    case thirteenTwo
    
    case oneFour
    case twoFour
    case threeFour
    case fourFour
    case fiveFour
    case sixFour
    case sevenFour
    case eightFour
    case nineFour
    case tenFour
    case elevenFour
    case twelveFour
    case thirteenFour
    
    static func ==(lhs: TimeSignature, rhs: TimeSignature) -> Bool {
        lhs.rawValue.0 == rhs.rawValue.0 && lhs.rawValue.1 == rhs.rawValue.1
    }
    
    var rawValue: (Int, Int) {
        switch self {
        case .oneTwo: return (1, 2)
        case .twoTwo: return (2, 2)
        case .threeTwo: return (3, 2)
        case .fourTwo: return (4, 2)
        case .fiveTwo: return (5, 2)
        case .sixTwo: return (6, 2)
        case .sevenTwo: return (7, 2)
        case .eightTwo: return (8, 2)
        case .nineTwo: return (9, 2)
        case .tenTwo: return (10, 2)
        case .elevenTwo: return (11, 2)
        case .twelveTwo: return (12, 2)
        case .thirteenTwo: return (13, 2)
        
        case .oneFour: return (1, 4)
        case .twoFour: return (2, 4)
        case .threeFour: return (3, 4)
        case .fourFour: return (4, 4)
        case .fiveFour: return (5, 4)
        case .sixFour: return (6, 4)
        case .sevenFour: return (7, 4)
        case .eightFour: return (8, 4)
        case .nineFour: return (9, 4)
        case .tenFour: return (10, 4)
        case .elevenFour: return (11, 4)
        case .twelveFour: return (12, 4)
        case .thirteenFour: return (13, 4)
        }
    }

    init?(rawValue: (Int, Int)) {
        switch rawValue {
        case (1, 2): self = .oneTwo
        case (2, 2): self = .twoTwo
        case (3, 2): self = .threeTwo
        case (4, 2): self = .fourTwo
        case (5, 2): self = .fiveTwo
        case (6, 2): self = .sixTwo
        case (7, 2): self = .sevenTwo
        case (8, 2): self = .eightTwo
        case (9, 2): self = .nineTwo
        case (10, 2): self = .tenTwo
        case (11, 2): self = .elevenTwo
        case (12, 2): self = .twelveTwo
        case (13, 2): self = .thirteenTwo
        
        case (1, 4): self = .oneFour
        case (2, 4): self = .twoFour
        case (3, 4): self = .threeFour
        case (4, 4): self = .fourFour
        case (5, 4): self = .fiveFour
        case (6, 4): self = .sixFour
        case (7, 4): self = .sevenFour
        case (8, 4): self = .eightFour
        case (9, 4): self = .nineFour
        case (10, 4): self = .tenFour
        case (11, 4): self = .elevenFour
        case (12, 4): self = .twelveFour
        case (13, 4): self = .thirteenFour
        default: return nil
        }
    }
    
    func getNumeratorRepresentation() -> String {
        return getNumeralRepresentation(rawValue.0)
    }
    
    func getDenominatorRepresentation() -> String {
        return getNumeralRepresentation(rawValue.1)
    }
    
    func getNumeralRepresentation(_ number: Int) -> String {
        switch number {
        case 1: return ""
        case 2: return ""
        case 3: return ""
        case 4: return ""
        case 5: return ""
        case 6: return ""
        case 7: return ""
        case 8: return ""
        case 9: return ""
        case 10: return ""
        case 11: return ""
        case 12: return ""
        case 13: return ""
            
        default: return String(number)
        }
    }
}

/// Implementation of metronome state and operation for use by ContentView.
class MetronomeViewModel: ObservableObject {
    
    let minBeatsPerMinute = 30
    let maxBeatsPerMinute = 300
    
    @Published var beatSounds: [BeatSound] = []
    
    @Published var timeSignature = TimeSignature.fourFour {
        didSet {
            // Update how many beats in a measure
            beatsPerMeasure = timeSignature.rawValue.0
            // Reset beat sound list
            beatSounds = Array(repeating: .defaultSound, count: beatsPerMeasure)
            beatSounds[0] = .accentedSound
        }
    }
    
    /// Set true to enable the metronome's periodic clicking.
    @Published var isRunning = false {
        didSet {
            if isRunning {
                startTimer()
            } else {
                stopTimer()
            }
        }
    }
    
    /// Tempo
    @Published var beatsPerMinute: Int {
        didSet {
            assert(beatsPerMinute >= 1)
            
            UserDefaults.standard.setValue(beatsPerMinute, forKey: Defaults.beatsPerMinute)
            
            if isRunning {
                startTimer()
            }
        }
    }
    
    /// Current beat index
    @Published var beatIndex = 0
    
    /// Number of beats per measure
    @Published var beatsPerMeasure: Int {
        didSet {
            UserDefaults.standard.setValue(beatsPerMeasure, forKey: Defaults.beatsPerMeasure)
        }
    }
    
    /// Which beats of a measure to play sounds on
    @Published var beatsPlayed: BeatsPlayed {
        didSet {
            UserDefaults.standard.setValue(beatsPlayed.rawValue, forKey: Defaults.beatsPlayed)
        }
    }
    
    /// If true, make audio sounds.  Otherwise, silent.
    @Published var soundEnabled: Bool {
        didSet {
            UserDefaults.standard.setValue(soundEnabled, forKey: Defaults.soundEnabled)
        }
    }
    
    private let metronomeDispatchQueue = DispatchQueue(label: "com.javart.MusicPracticeJournal.metronome", qos: .userInteractive, attributes: .concurrent)
    
    private var metronomeTimer: DispatchSourceTimer?
    
    private var clickAudioPlayer: AVAudioPlayer?
    private var accentAudioPlayer: AVAudioPlayer?
    
    init() {	
        let userDefaults = UserDefaults.standard
        
        beatsPerMinute = max(
            min(
                userDefaults.integer(forKey: Defaults.beatsPerMinute),
                maxBeatsPerMinute
            ),
            minBeatsPerMinute)
        
        beatsPerMeasure = userDefaults.integer(forKey: Defaults.beatsPerMeasure)
        beatsPlayed = BeatsPlayed(rawValue: userDefaults.string(forKey: Defaults.beatsPlayed) ?? BeatsPlayed.all.rawValue) ?? .all
        soundEnabled = userDefaults.bool(forKey: Defaults.soundEnabled)
        
        loadSounds()
    }
    
    private func startTimer() {
        stopTimer()
        
        beatIndex = 0
        let interval = 60.0 / Double(beatsPerMinute)
        
        metronomeTimer = DispatchSource.makeTimerSource(
            flags: .strict,
            queue: metronomeDispatchQueue)
        
        metronomeTimer?.setEventHandler { [weak self] in
            guard let self else { return }
            
            DispatchQueue.main.async {
                if !self.isRunning {
                    return
                }
                
                var nextBeatIndex = self.beatIndex + 1
                if nextBeatIndex > self.beatsPerMeasure {
                    nextBeatIndex = 1
                }
                self.beatIndex = nextBeatIndex
                
                let beatSound = self.getBeatSoundAtIndex(self.beatIndex)
                self.playSound(beatSound: beatSound)
                
            }
        }
        
        metronomeTimer?.schedule(deadline: .now(), repeating: interval, leeway: .milliseconds(10))
        metronomeTimer?.activate()
    }
    
    private func stopTimer() {
        beatIndex = 0
        metronomeTimer?.cancel()
        metronomeTimer = nil
    }
    
    private func loadSounds() {
        guard let clickUrl = Bundle.main.url(forResource: "click-metronome-atonal-low", withExtension: "wav") else {
            fatalError("click sound not found.")
        }
        
        guard let accentUrl = Bundle.main.url(forResource: "click-metronome-atonal-high", withExtension: "wav") else {
            fatalError("accent sound not found.")
        }
        
        do {
            clickAudioPlayer = try AVAudioPlayer(contentsOf: clickUrl)
            clickAudioPlayer?.prepareToPlay()
            
            accentAudioPlayer = try AVAudioPlayer(contentsOf: accentUrl)
            accentAudioPlayer?.prepareToPlay()
        } catch {
            fatalError("unable to load click sound: \(error)")
        }
    }
    
    private func playSound(beatSound: BeatSound) {
        if soundEnabled {
            switch beatSound {
            case .mute:
                break
            case .defaultSound:
                clickAudioPlayer?.play()
                break
            case .accentedSound:
                accentAudioPlayer?.play()
                return
            }
        } else {
            print("sound is NOT enabled")
        }
    }
    
    public func getBeatSoundAtIndex(_ index: Int) -> BeatSound {
        return beatSounds[index - 1, default: .mute]
    }
    
    public func toggleBeatSoundAtIndex(_ index: Int) -> Void {
        let currentBeatSound = beatSounds[index - 1]
        var newBeatSound = currentBeatSound
        switch currentBeatSound {
        case .accentedSound:
            newBeatSound = .defaultSound
        case .defaultSound:
            newBeatSound = .mute
        case .mute:
            newBeatSound = .accentedSound
        }
        beatSounds[index - 1] = newBeatSound
    }
}
