import Foundation
import AVFoundation

struct AudioRecordingResult {
    var UUID: UUID
    var url: URL
}

class AudioRecorderViewModel: ObservableObject {
    var audioRecorder: AVAudioRecorder?
    var recordingSession: AVAudioSession?
    
    @Published var isRecording = false
    @Published var currentlyRecordingAudioUUID: UUID?
    @Published var currentlyRecordingAudioURL: URL?
    
    func getAudioURL(audioFileName: String) -> URL {
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentPath.appendingPathComponent("\(audioFileName).m4a")
    }

    func setupRecorder(audioURL: URL) throws {
        let recordingSettings = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ] as [String : Any]
        print("Audio file path: \(audioURL)")
        audioRecorder = try AVAudioRecorder(url: audioURL, settings: recordingSettings)
        audioRecorder?.isMeteringEnabled = true // Enable metering for level monitoring
        audioRecorder?.prepareToRecord()
    }
    
    func getLevel() -> Float {
        if let recorder = self.audioRecorder, recorder.isRecording {
            recorder.updateMeters() // Update the meters before getting the level
            return recorder.averagePower(forChannel: 0)
        }
        return -160 // Default value if not recording
    }
    
    func startRecording() {
        do {
            let uuid = UUID()
            self.currentlyRecordingAudioUUID = uuid
            let audioFilename = uuid.uuidString
            let audioURL = getAudioURL(audioFileName: audioFilename)
            self.currentlyRecordingAudioURL = audioURL
            try setupRecorder(audioURL: audioURL)
            audioRecorder?.record()
        } catch let error {
            print("Error recording audio \(error.localizedDescription)")
        }
    }

    func stopRecording() -> AudioRecordingResult? {
        audioRecorder?.stop()
        if let uuid = self.currentlyRecordingAudioUUID, let audioURL = self.currentlyRecordingAudioURL {
            let recordingResult = AudioRecordingResult(
                UUID: uuid,
                url: audioURL
            )
            audioRecorder = nil
            currentlyRecordingAudioURL = nil
            currentlyRecordingAudioUUID = nil
            return recordingResult
        } else {
            return nil
        }
    }
    
    func requestRecordPermission() async  {
        // Request permission to record.
        if await AVAudioApplication.requestRecordPermission() {
            // The user grants access. Present recording interface.
            print("Permission to record granted")
        } else {
            // The user denies access. Present a message that indicates
            // that they can change their permission settings in the
            // Privacy & Security section of the Settings app.
            print("Permission to record denied")
        }
    }    
}
