import SwiftUI
import SwiftData

struct AudioClipToolView: View {
    @State var subTask: PracticeSubTask
    
    var body: some View {
        VStack {
            AudioClipsListView(subTask: $subTask)
            Spacer()
            AudioRecorderView(subTask: subTask)
        }
    }
}

#Preview {
    AudioClipToolView(subTask: PreviewExamples.getPracticeSubItem())
        .modelContainer(PreviewExamples.previewContainer)
}
