import SwiftUI
import Combine

struct AudioRecorderView: View {
    @Environment(\.modelContext) private var modelContext
    
    let subTask: PracticeSubTask
    
    @StateObject private var model = AudioRecorderViewModel()
    
    @State var timer = Timer.publish(every: 0.1, on: .main, in: .common)
    @State var cancellable: (any Cancellable)?
    @State var startRecordingDate: Date?
    @State var elapsedTime: TimeInterval?
    
    var body: some View {
        VStack {
            if let elapsedTime {
                let minutes = (Int(elapsedTime) % 3600) / 60
                let seconds = Int(elapsedTime) % 60
                Text(String(format: "%02d:%02d", minutes, seconds))
            }
        
            RecordButton(isRecording: $model.isRecording) {
                print("Start")
                model.startRecording()
                startRecordingDate = Date.now
                cancellable = timer.connect()
            } stopAction: {
                print("Stop")
                cancellable?.cancel()
                if let recordingResult = model.stopRecording() {
                    let newAudioRecording = AudioRecording(
                        id: recordingResult.UUID.uuidString,
                        title: subTask.generateDefaultAudioRecordingTitle(),
                        subTask: subTask
                    )
                    subTask.audioRecordings?.append(newAudioRecording)
                    do {
                        try modelContext.save()
                    } catch {
                        print("Failed to save audio recording \(error)")
                    }
                }
            }
            .frame(width: 70, height: 70)
        }
        .onReceive(timer, perform: { _ in
            if let startRecordingDate {
                self.elapsedTime = Date.now.timeIntervalSince(startRecordingDate)
            }
        })
        
    }
}

#Preview {
    AudioRecorderView(subTask: PreviewExamples.getPracticeSubItem())
        .modelContainer(PreviewExamples.previewContainer)
}
