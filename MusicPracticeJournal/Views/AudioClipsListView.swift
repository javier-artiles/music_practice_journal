import SwiftUI
import SwiftData

struct AudioClipsListView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Binding var subTask: PracticeSubTask
    
    @State var selectedAudioClip: AudioRecording? = nil
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach (subTask.audioRecordings ?? [], id: \.id) { audioRecording in
                    AudioClipPlayerRowView(
                        audioRecording: audioRecording,
                        presentAudioControls: audioRecording == selectedAudioClip,
                        onDelete: deleteAudioRecording
                    )
                    .frame( maxWidth: .infinity)
                    .onTapGesture {
                        selectedAudioClip = audioRecording
                    }
                }
            }
            .onAppear() {
                if let singleAudioRecording = subTask.audioRecordings?.first {
                    selectedAudioClip = singleAudioRecording
                }
            }
        }
    }
    
    func deleteAudioRecording(_ audioRecording: AudioRecording) {
        print("Deleting audio recording: \(audioRecording.id)")
        do {
            selectedAudioClip = nil
            if let audioURL = audioRecording.getUrl() {
                try FileManager.default.removeItem(at: audioURL)
            }
            subTask.audioRecordings?.removeAll { $0.id == audioRecording.id }
            modelContext.delete(audioRecording)
            try modelContext.save()
        } catch {
            print("Failed to delete file: \(error)")
        }
    }
    
    func listContentsOfDocumentsDir() -> [URL] {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directoryContents = try! fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)
        for audio in directoryContents {
            print(audio)
        }
        return directoryContents
    }
}

#Preview {
    let modelContainer = PreviewExamples.previewContainer
    let subTask = PreviewExamples.getPracticeSubItemWithAudio()
    AudioClipsListView(subTask: .constant(subTask))
        .modelContainer(modelContainer)
        .onAppear {
            modelContainer.mainContext.insert(subTask)
        }
        .padding()
}
