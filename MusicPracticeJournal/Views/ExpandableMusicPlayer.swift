import SwiftUI
import MusicKit
import AVFoundation
import MediaPlayer

struct ExpandableMusicPlayer: View {
    @Environment(CurrentPracticeSession.self) private var practiceSession
    
    @Binding var show: Bool
    @Binding var hideMiniPlayer: Bool
    
    /// View Properties
    @State private var expandPlayer: Bool = false
    @State private var offsetY: CGFloat = 0
    @State private var offsetX: CGFloat = 0
    @State private var mainWindow: UIWindow?
    @State private var windowProgress: CGFloat = 0
    @Namespace private var animation
    
    @State private var color: Color = .white
    private var normalFillColor: Color { color.opacity(0.5) }
    private var emptyColor: Color { color.opacity(0.3) }
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            let safeArea = $0.safeAreaInsets
            let cornerRadius: CGFloat = safeArea.bottom == 0 ? 0 : 45
            
            ZStack(alignment: .top) {
                /// Background
                ZStack {
                    Rectangle()
                        .fill(.playerBackground)
                    
                    Rectangle()
                        .fill(.white)
                        // TODO review background options below
                        //.fill(.linearGradient(colors: [.artwork1, .artwork2, .artwork3], startPoint: .top, endPoint: .bottom))
                        .opacity(expandPlayer ? 1 : 0)
                }
                .clipShape(.rect(cornerRadius: expandPlayer ? cornerRadius : 15))
                .frame(height: expandPlayer ? nil : 55)
                /// Shadows
                .shadow(color: .primary.opacity(0.06), radius: 5, x: 5, y: 5)
                .shadow(color: .primary.opacity(0.05), radius: 5, x: -5, y: -5)
                
                MiniPlayer()
                    .opacity(expandPlayer ? 0 : 1)
                
                ExpandedPlayer(size, safeArea)
                    .opacity(expandPlayer ? 1 : 0)
                    .frame(width: size.width * 0.90)
            }
            .frame(height: expandPlayer ? nil : 55, alignment: .top)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, expandPlayer ? 0 : safeArea.bottom + 90)
            .padding(.horizontal, expandPlayer ? 0 : 15)
            .offset(y: offsetY)
            .gesture(
                PanGesture { value in
                    guard expandPlayer else { return }
                    
                    let translation = max(value.translation.height, 0)
                    offsetY = translation
                    windowProgress = max(min(translation / size.height, 1), 0) * 0.1
                    
                    resizeWindow(0.1 - windowProgress)
                } onEnd: { value in
                    guard expandPlayer else { return }
                    
                    let translation = max(value.translation.height, 0)
                    let velocity = value.velocity.height / 5
                    
                    withAnimation(.smooth(duration: 0.3, extraBounce: 0)) {
                        if (translation + velocity) > (size.height * 0.5) {
                            /// Closing View
                            expandPlayer = false
                            windowProgress = 0
                            /// Resetting Window To Identity With Animation
                            resetWindowWithAnimation()
                        } else {
                            /// Reset Window To 0.1 With Animation
                            UIView.animate(withDuration: 0.3) {
                                resizeWindow(0.1)
                            }
                        }
                        
                        offsetY = 0
                    }
                }
            )
            .offset(y: hideMiniPlayer && !expandPlayer ? safeArea.bottom + 200 : 0)
            .ignoresSafeArea()
        }
        .onAppear {
            if let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow, mainWindow == nil {
                mainWindow = window
            }
        }
    }
    
    /// Mini Player
    @ViewBuilder
    func MiniPlayer() -> some View {
        HStack(spacing: 12) {
            if let technique = practiceSession.currentTask?.technique {
                SharedElements.getTechniqueImage(isUserCreated: technique.isUserCreated)
                    .padding(.trailing, 5)
                    .padding(.top, 5)
                    .background(.white)
            } else if let work = practiceSession.currentTask?.work {
                SharedElements.getWorkImage(isUserCreated: work.isUserCreated)
                    .padding(.trailing, 5)
                    .padding(.top, 5)
                    .background(.white)
            }
            VStack(alignment: .leading) {
                Text(practiceSession.currentTask?.getTitle() ?? "")
                Text(practiceSession.currentSubTask?.name ?? "")
                    .font(.caption)
            }
            Spacer(minLength: 0)
            VStack(alignment: .leading) {
                if practiceSession.currentSubTask != nil {
                    TimeElapsedView(timeElapsedInSeconds: practiceSession.getSecsSpentOnCurrentSubTask())
                            .font(.largeTitle)
                            .foregroundStyle(.gray)
                }
                
            }
            
        }
        .padding(.horizontal, 10)
        .frame(height: 55)
        .contentShape(.rect)
        .onTapGesture {
            withAnimation(.smooth(duration: 0.3, extraBounce: 0)) {
                expandPlayer = true
            }
            
            /// Reszing Window When Opening Player
            UIView.animate(withDuration: 0.3) {
                resizeWindow(0.1)
            }
        }
    }
    
    
    /// Expanded Player
    @ViewBuilder
    func ExpandedPlayer(_ size: CGSize, _ safeArea: EdgeInsets) -> some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(.white.secondary)
                .frame(width: 35, height: 5)
                .offset(y: -10)
            
            if expandPlayer {
                VStack(alignment: .leading) {
                    Text(practiceSession.currentTask?.getTitle() ?? "")
                        .font(.largeTitle)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(practiceSession.currentSubTask?.name ?? "")
                        .font(.title2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity)
                Spacer()
                TabView {
                    Tab("Time", systemImage: "timer") {
                        VStack(alignment: .leading) {
                            TimeElapsedView(timeElapsedInSeconds: practiceSession.getSecsSpentOnCurrentSubTask())
                                    .font(.title)
                                    .foregroundStyle(.gray)
                                    .scaleEffect(2.0)
                        }
                        .padding(75)
                        HStack(alignment: .center) {
                            Spacer()
                            Button()  {
                                practiceSession.goToPrevSubtask()
                            } label: {
                                Image(systemName: "backward.fill")
                                    .scaleEffect(2.5)
                                    .padding(.leading, 5)
                            }.disabled(!practiceSession.hasPrevSubTask())
                            Spacer()
                            Button()  {
                                practiceSession.toggleTimer();
                            } label: {
                                Image(systemName:  practiceSession.isTimerRunning() ? "pause.fill" : "play.fill")
                                    .scaleEffect(4)
                                    .padding(.leading, 5)
                            }
                            Spacer()
                            Button()  {
                                practiceSession.goToNextSubtask()
                            } label: {
                                Image(systemName: "forward.fill")
                                    .scaleEffect(2.5)
                                    .padding(.leading, 5)
                            }.disabled(!practiceSession.hasNextSubTask())
                            Spacer()
                        }
                        .padding(.bottom, 75)
                    }
                    Tab("Metronome", systemImage: "metronome") {
                        MetronomeView()
                    }
                    if let subTask = practiceSession.currentSubTask {
                        Tab("Recorder", systemImage: "record.circle") {
                            AudioClipToolView(subTask: subTask)
                        }
                    }
                    Tab("Tuner", systemImage: "gauge.with.dots.needle.33percent") {
                        
                    }
                    Tab("Notes", systemImage: "note.text") {
                        
                    }
                }
                .padding(.horizontal, 0)
            }
        }
        .padding(0)
        .padding(.top, safeArea.top)
    }
    
    
    func resizeWindow(_ progress: CGFloat) {
        if let mainWindow = mainWindow?.subviews.first {
            let offsetY = (mainWindow.frame.height * progress) / 2
            
            /// Your Custom Corner Radius
            mainWindow.layer.cornerRadius = (progress / 0.1) * 30
            mainWindow.layer.masksToBounds = true
            
            mainWindow.transform = .identity.scaledBy(x: 1 - progress, y: 1 - progress).translatedBy(x: 0, y: offsetY)
        }
    }
    
    func resetWindowWithAnimation() {
        if let mainWindow = mainWindow?.subviews.first {
            UIView.animate(withDuration: 0.3) {
                mainWindow.layer.cornerRadius = 0
                mainWindow.transform = .identity
            }
        }
    }
}


#Preview {
    struct AsyncHomeView: View {
        @State var showMiniPlayer: Bool = false
        @State var hideMiniPlayer: Bool = false
        var currentSession = CurrentPracticeSession()
        
        var body: some View {
            RootView {
                VStack {
                    Button("Toggle mini player") {
                        self.showMiniPlayer.toggle()
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity)
                .universalOverlay(show: $showMiniPlayer) {
                    ExpandableMusicPlayer(
                        show: $showMiniPlayer,
                        hideMiniPlayer: $hideMiniPlayer
                    )
                    .environment(currentSession)
                }
            }
            .onAppear {
                currentSession.currentSession = PreviewExamples.getPracticeSession()
                currentSession.currentTask = currentSession.currentSession?.practiceTasks.first
                currentSession.currentSubTask = currentSession.currentTask?.practiceSubTasks.first
                showMiniPlayer = true
            }
        }
    }
    return AsyncHomeView()
}
