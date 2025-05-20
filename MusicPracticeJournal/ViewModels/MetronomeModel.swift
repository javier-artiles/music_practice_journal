import Foundation
import AVFoundation


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
    
    func getBeatsPerMeasure() -> Int {
        return rawValue.0
    }
}

class MetronomeModel: ObservableObject {
    var timer: Timer?
    var lastBeatDate: Date?
    var audioPlayers: [AVAudioPlayer?] = []
    
    let minBeatsPerMinute: Double = 1
    let maxBeatsPerMinute: Double = 400
    
    @Published var beatsPerMinute: Double {
        didSet {
            onUpdateBeatsPerMinute()
        }
    }
    @Published var timeSignature: TimeSignature {
        didSet {
            onUpdateTimeSignature()
        }
    }
    @Published var currentBeatIndex: Int = -1
    @Published var soundEnabled = true
    @Published var isRunning = false
    @Published var beatSounds: [BeatSound]
    
    init(beatsPerMinute: Double, timeSignature: TimeSignature = .fourFour) {
        self.beatsPerMinute = beatsPerMinute
        self.timeSignature = timeSignature
        
        let beatsPerMeasure = timeSignature.getBeatsPerMeasure()
        self.beatSounds = Array(repeating: .defaultSound, count: beatsPerMeasure)
        beatSounds[0] = .accentedSound
        
        // Initialize audio players for each beat
        self.audioPlayers = []
        for index in 0..<beatsPerMeasure {
            let beatSound = beatSounds[index, default: .mute]
            let audioPlayer = getAudioPlayer(beatSound: beatSound)
            audioPlayers.append(audioPlayer)
        }
    }
    
    func onUpdateTimeSignature() {
        let beatsPerMeasure = timeSignature.getBeatsPerMeasure()
        self.beatSounds = Array(repeating: .defaultSound, count: beatsPerMeasure)
        beatSounds[0] = .accentedSound
        
        // Initialize audio players for each beat
        self.audioPlayers = []
        for index in 0..<beatsPerMeasure {
            let beatSound = beatSounds[index, default: .mute]
            let audioPlayer = getAudioPlayer(beatSound: beatSound)
            audioPlayers.append(audioPlayer)
        }
    }
    
    func onUpdateBeatsPerMinute() {
        if isRunning {
            stopTimer()
            startTimer()
        }
    }
    
    func getBeatSoundAtIndex(_ index: Int) -> BeatSound {
        beatSounds[index, default: .mute]
    }
    
    func getAudioPlayer(beatSound: BeatSound) -> AVAudioPlayer? {
        var audioResource: String? = nil
        switch beatSound {
        case .mute:
            audioResource = nil
            break
        case .defaultSound:
            audioResource = "click-metronome-atonal-low"
            break
        case .accentedSound:
            audioResource = "click-metronome-atonal-high"
        }
        if let audioResource = audioResource {
            guard let audioUrl = Bundle.main.url(forResource: audioResource, withExtension: "wav") else {
                fatalError("click sound not found.")
            }
            do {
                let audioPlayer = try AVAudioPlayer(contentsOf: audioUrl)
                audioPlayer.volume = beatSound == .accentedSound ? 1.0 : 0.2
                audioPlayer.prepareToPlay()
                return audioPlayer
            } catch {
                fatalError("unable to load sound: \(error)")
            }
        } else {
            return nil
        }
    }
    
    func startTimer() {
        print("start timer")
        self.isRunning = true
        let beatInterval = 60.0 / Double(beatsPerMinute)
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true, block: { _ in
            // Given the last beat date, can we advance to the next beat?
            if let lastBeatDate = self.lastBeatDate {
                let timeInterval = Date.now.timeIntervalSince(lastBeatDate)
                if timeInterval >= beatInterval {
                    //print("CLICK")
                    var nextBeatIndex = self.currentBeatIndex + 1
                    if nextBeatIndex >= self.timeSignature.getBeatsPerMeasure() {
                        nextBeatIndex = 0
                    }
                    //print("Next beat index: \(nextBeatIndex)")
                    self.currentBeatIndex = nextBeatIndex
                    self.lastBeatDate = Date.now
                    self.playBeatSound()
                }
            } else {
                // This is the first click
                //print("First CLICK")
                self.currentBeatIndex = 0
                self.lastBeatDate = Date.now
                self.playBeatSound()
                return
            }
        })
    }
    
    func stopTimer() {
        self.isRunning = false
        self.timer?.invalidate()
        currentBeatIndex = -1
    }
    
    func playBeatSound() {
        self.audioPlayers[self.currentBeatIndex]?.play()
    }
    
    public func toggleBeatSoundAtIndex(_ index: Int) -> Void {
        let currentBeatSound = beatSounds[index]
        var newBeatSound = currentBeatSound
        switch currentBeatSound {
        case .accentedSound:
            newBeatSound = .defaultSound
        case .defaultSound:
            newBeatSound = .mute
        case .mute:
            newBeatSound = .accentedSound
        }
        beatSounds[index] = newBeatSound
        audioPlayers[index] = getAudioPlayer(beatSound: newBeatSound)
    }
}
