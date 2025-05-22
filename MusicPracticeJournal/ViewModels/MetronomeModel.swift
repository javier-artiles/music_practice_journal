import Foundation
import AVFoundation


enum BeatSound {
    case mute
    case defaultSound
    case accentedSound
}

class MetronomeModel: ObservableObject {
    private let audioEngine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private var accentAudioBuffer: AVAudioPCMBuffer?
    private var defaultAudioBuffer: AVAudioPCMBuffer?
    
    let dispatchQueue = DispatchQueue(
        label: "com.javart.MusicPracticeJournal.metronome",
        qos: .userInteractive,
        attributes: .concurrent
    )
    var timer: DispatchSourceTimer?
    
    var lastBeatDate: Date = Date.now
    
    let minBeatsPerMinute: Double = 1
    let maxBeatsPerMinute: Double = 400
    
    let minBeatsPerMeasure: Int = 1
    let maxBeatsPerMeasure: Int = 15
    
    private var internalBeatIndex: Int = -1 {
        didSet {
            DispatchQueue.main.async {
                self.currentBeatIndex = self.internalBeatIndex
            }
        }
    }
    @Published var currentBeatIndex: Int = -1
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
    @Published var soundEnabled = true
    @Published var isRunning = false
    @Published var beatSounds: [BeatSound]
    
    init(beatsPerMinute: Double, beatsPerMeasure: Int) {
        self.beatsPerMinute = beatsPerMinute
        self.beatsPerMeasure = beatsPerMeasure
        self.beatSounds = Array(repeating: .defaultSound, count: beatsPerMeasure)
        
        // Initialize audio
        self.accentAudioBuffer = loadAudioBuffer(audioResource: "click-metronome-atonal-high")
        self.defaultAudioBuffer = loadAudioBuffer(audioResource: "click-metronome-atonal-low")
        
        // Ensure we accent first beat by default
        beatSounds[0] = .accentedSound
        
        // Wire engine
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: accentAudioBuffer?.format)
        audioEngine.prepare()
        try? audioEngine.start()
    }
    
    func loadAudioBuffer(audioResource: String) -> AVAudioPCMBuffer {
        guard let audioURL = Bundle.main.url(forResource: audioResource, withExtension: "wav") else {
            fatalError("click sound not found.")
        }
        let audioFile = try! AVAudioFile(forReading: audioURL)
        let audioFormat = audioFile.processingFormat
        let totalFrames = UInt32(audioFile.length)
        let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: totalFrames)!
        do {
            // Read the entire file into the buffer
            try audioFile.read(into: audioBuffer)
            // You can now use this buffer with AVAudioPlayerNode or other audio nodes
        } catch {
            print("Error reading into buffer: \(error)")
        }
        return audioBuffer
    }
    
    func onUpdateBeatsPerMeasure() {
        self.beatSounds = Array(repeating: .defaultSound, count: beatsPerMeasure)
        beatSounds[0] = .accentedSound
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
            let timeInterval = Date.now.timeIntervalSince(lastBeatDate)
            let delta = timeInterval - beatInterval
            // Trigger a click if we are within a range of the expected interval
            if abs(delta) <= 0.001 || delta > 1.0 {
                //print(String(format: "click time interval delta:\t%.4f", timeInterval - beatInterval))
                var nextBeatIndex = self.internalBeatIndex + 1
                if nextBeatIndex >= self.beatsPerMeasure {
                    nextBeatIndex = 0
                }
                self.playBeatSound(atIndex: nextBeatIndex)
                
                self.internalBeatIndex = nextBeatIndex
                self.lastBeatDate = Date.now
            }
        }
        self.timer?.schedule(deadline: .now(), repeating: 0.001, leeway: .milliseconds(10))
        self.timer?.activate()
    }
    
    func stopTimer() {
        self.isRunning = false
        self.timer?.cancel()
        self.timer = nil
        self.internalBeatIndex = -1
    }
    
    func playBeatSound(atIndex: Int) {
        switch beatSounds[atIndex, default: .mute] {
        case .accentedSound:
            playerNode.scheduleBuffer(accentAudioBuffer!, at: nil)
            break
        case .defaultSound:
            playerNode.scheduleBuffer(defaultAudioBuffer!, at: nil)
            break
        case .mute:
            return
        }
        playerNode.play()
    
        //let intervalSinceStartPlay = Date.now.timeIntervalSince(lastBeatDate)
        //print(String(format: "intervalSinceStartPlay \(self.internalBeatIndex):\t%.4f", intervalSinceStartPlay))
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
    }
}
