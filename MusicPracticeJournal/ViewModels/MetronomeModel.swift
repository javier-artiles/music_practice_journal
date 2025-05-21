import Foundation
import AVFoundation


enum BeatSound {
    case mute
    case defaultSound
    case accentedSound
}

class MetronomeModel: ObservableObject {
    let dispatchQueue = DispatchQueue(
        label: "com.javart.MusicPracticeJournal.metronome",
        qos: .userInteractive,
        attributes: .concurrent
    )
    var timer: DispatchSourceTimer?
    
    var lastBeatDate: Date?
    var audioPlayers: [AVAudioPlayer?] = []
    
    let minBeatsPerMinute: Double = 1
    let maxBeatsPerMinute: Double = 400
    
    
    let minBeatsPerMeasure: Int = 1
    let maxBeatsPerMeasure: Int = 15
    
    @Published var beatsPerMinute: Double {
        didSet {
            onUpdateBeatsPerMinute()
        }
    }
    @Published var beatsPerMeasure: Int {
        didSet {
            onUpdateBeatsPerMeasure()
        }
    }
    @Published var currentBeatIndex: Int = -1
    @Published var soundEnabled = true
    @Published var isRunning = false
    @Published var beatSounds: [BeatSound]
    
    init(beatsPerMinute: Double, beatsPerMeasure: Int) {
        self.beatsPerMinute = beatsPerMinute
        self.beatsPerMeasure = beatsPerMeasure
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
    
    func onUpdateBeatsPerMeasure() {
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
                audioPlayer.volume = 1.0
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
        
        self.timer = DispatchSource.makeTimerSource(
            flags: .strict,
            queue: dispatchQueue
        )
        self.timer?.setEventHandler { [weak self] in
                    guard let self else { return }
            // Given the last beat date, can we advance to the next beat?
            if let lastBeatDate = self.lastBeatDate {
                let timeInterval = Date.now.timeIntervalSince(lastBeatDate)
                let delta = timeInterval - beatInterval
                // Trigger a click if we are within a range of the expected interval
                // OR if we are past that interval, but need to fill in the click
                if abs(delta) <= 0.001 || delta >= 0.01 {
                    print(String(format: "click time interval delta:\t%.4f", timeInterval - beatInterval))
                    //print("CLICK")
                    var nextBeatIndex = self.currentBeatIndex + 1
                    if nextBeatIndex >= self.beatsPerMeasure {
                        nextBeatIndex = 0
                    }
                    //print("Next beat index: \(nextBeatIndex)")
                    DispatchQueue.main.async {
                        self.currentBeatIndex = nextBeatIndex
                        self.lastBeatDate = Date.now
                        self.playBeatSound()
                    }
                }
            } else {
                // This is the first click
                //print("First CLICK")
                DispatchQueue.main.async {
                    self.currentBeatIndex = 0
                    self.lastBeatDate = Date.now
                    self.playBeatSound()
                }
                return
            }
        }
        self.timer?.schedule(deadline: .now(), repeating: 0.001, leeway: .milliseconds(10))
        self.timer?.activate()
    }
    
    func stopTimer() {
        self.isRunning = false
        self.timer?.cancel()
        self.timer = nil
        currentBeatIndex = -1
        self.lastBeatDate = nil
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
