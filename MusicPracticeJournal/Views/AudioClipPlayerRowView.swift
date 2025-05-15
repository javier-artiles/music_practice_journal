import SwiftUI
import AVFoundation
import Combine

struct AudioClipPlayerRowView: View {
    let audioRecording: AudioRecording
    let presentAudioControls: Bool
    let audioPlayer: AVAudioPlayer?
    let onDelete: (AudioRecording) -> Void
    
    @State var timer = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()
    
    @State private var progress: CGFloat = 0.0
    @State private var duration: Double = 0.0
    @State private var isActive: Bool = false
    @State private var isPlaying: Bool = false
    @State private var editableTitle: String
    @Environment(\.colorScheme) var colorScheme
    
    var current: String {
        let minutes = Int(duration * progress) / 60
        let seconds = Int(duration * progress) % 60
        return String(format: "%01d:%02d", minutes, seconds)
    }
    
    var end: String {
        let durationLeft = duration - duration * progress
        let minutes = Int(durationLeft) / 60
        let seconds = Int(durationLeft) % 60
        return String(format: "-%01d:%02d", minutes, seconds)
    }
    
    init(audioRecording: AudioRecording, presentAudioControls: Bool = false, onDelete: @escaping (AudioRecording) -> Void) {
        self.audioRecording = audioRecording
        self.presentAudioControls = presentAudioControls
        if let audioUrl = audioRecording.getUrl() {
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOf: audioUrl)
            } catch {
                self.audioPlayer = nil
                print("Error while initializing audio player \(error)")
            }
        } else {
            self.audioPlayer = nil
        }
        self.onDelete = onDelete
        self.editableTitle = audioRecording.title
    }
    
    var body: some View {
        VStack(spacing: 6) {
            VStack(alignment: .leading) {
                HStack {
                    if (presentAudioControls) {
                        TextField("Audio clip title", text: $editableTitle)
                            .fontWeight(.medium)
                            .onSubmit {
                                if !editableTitle.isEmpty {
                                    audioRecording.title = editableTitle
                                }
                            }
                    } else {
                        Text(audioRecording.title)
                            .fontWeight(.medium)
                    }
                    Spacer()
                    if (presentAudioControls) {
                        Button {
                            self.onDelete(audioRecording)
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                }
                HStack {
                    Text(formatRelativeDate(audioRecording.dateRecorded))
                        .font(.footnote)
                        .foregroundStyle(.gray)
                    Spacer()
                    if (!presentAudioControls) {
                        Text(formatSecondsToMinutesSeconds(seconds: duration))
                            .font(.footnote)
                            .foregroundStyle(.gray)
                    }
                }
            }
            if (presentAudioControls) {
                if let audioUrl = audioRecording.getUrl() {
                    WaveformScrubber(
                        config: WaveformScrubber.Config.init(activeTint: colorScheme == .dark ? .white : .black),
                        url: audioUrl,
                        progress: $progress
                    ) { info in
                        // duration = info.duration
                    } onGestureActive: { status in
                        isActive = status
                    }
                    .frame(height: 60)
                    .scaleEffect(y: isActive ? 1.4 : 1, anchor: .center)
                    .animation(.bouncy, value: isActive)
                } else {
                    Text("Audio file could not be found")
                }
                
                HStack {
                    Text(current)
                        .font(.system(size: 12))
                        .foregroundStyle(.gray)
                        .frame(width: 60)
                    
                    Spacer()
                    
                    Button {
                        audioPlayer?.currentTime = (audioPlayer?.currentTime ?? 0) - 15
                        progress = (audioPlayer?.currentTime ?? .zero) / self.duration
                    } label: {
                        Image(systemName: "15.arrow.trianglehead.counterclockwise")
                            .font(.title3)
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        if (isPlaying) {
                            pausePlayback()
                        } else {
                            startPlayback()
                        }
                    } label: {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.largeTitle)
                    }
                    .padding(.horizontal, 15)
                    .buttonStyle(.plain)
                    
                    Button {
                        audioPlayer?.currentTime = (audioPlayer?.currentTime ?? 0) + 15
                        progress = (audioPlayer?.currentTime ?? .zero) / self.duration
                    } label: {
                        Image(systemName: "15.arrow.trianglehead.clockwise")
                            .font(.title3)
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    Text(end)
                        .font(.system(size: 12))
                        .foregroundStyle(.gray)
                        .frame(width: 60)
                }
                .onChange(of: progress) {
                    if isActive {
                        audioPlayer?.currentTime = Double(progress * duration)
                    }
                }
                .onReceive(timer, perform: { _ in
                    print("tick")
                    progress = (audioPlayer?.currentTime ?? .zero) / self.duration
                    if progress == 0.0 && !(audioPlayer?.isPlaying ?? false) {
                        stopPlayback()
                    }
                })
                .padding(.horizontal, 10)
                .padding(.bottom, 8)
            }
            Divider()
               .frame(maxWidth: .infinity, maxHeight:1)
               .background(Color.gray.opacity(0.1), alignment: .top)
               .padding(.bottom, 8)
        }
        .task {
            if let audioUrl = audioRecording.getUrl() {
                self.duration = (try? await AVURLAsset(url: audioUrl).load(.duration).seconds) ?? 0.0
            }
        }
    }
    
    
    func startPlayback() {
        print("play")
        timer = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()
        audioPlayer?.play()
        self.isPlaying = true
    }

    func pausePlayback() {
        print("pause")
        audioPlayer?.pause()
        isPlaying = false
        timer.upstream.connect().cancel()
    }
    
    func stopPlayback() {
        print("stop")
        audioPlayer?.stop()
        isPlaying = false
        timer.upstream.connect().cancel()
    }
}

#Preview("Folded") {
    AudioClipPlayerRowView(audioRecording: PreviewExamples.getAudioRecording(), onDelete: {_ in })
        .padding()
}


#Preview("Unfolded") {
    AudioClipPlayerRowView(audioRecording: PreviewExamples.getAudioRecording(), presentAudioControls: true, onDelete: {_ in })
        .padding()
}
