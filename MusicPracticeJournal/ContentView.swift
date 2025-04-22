import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(CurrentPracticeSession.self) var currentPracticeSession
    @Query private var practiceSessions: [PracticeSession]
    @State private var showMiniPlayer: Bool = false
    @State private var hideMiniPlayer: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .center) {
                List {
                    ForEach(practiceSessions) { practiceSession in
                        NavigationLink {
                            PracticeSessionView(practiceSession: practiceSession)
                        } label: {
                            VStack(alignment: .leading) {
                                HStack(alignment: .top) {
                                    Text("\(practiceSession.name)")
                                    Spacer()
                                    Text("\(practiceSession.getSecsSpentOnSession()) secs")
                                }.padding(.bottom, 5)
                                ForEach(practiceSession.practiceTasks) { item in
                                    HStack {
                                        if let technique = item.technique {
                                            SharedElements.getTechniqueImage(isUserCreated: technique.isUserCreated)
                                            Text(item.getName())
                                                .font(.caption)
                                                .lineLimit(1)
                                        } else if let work = item.work {
                                            SharedElements.getWorkImage(isUserCreated: work.isUserCreated)
                                            Text(item.getName())
                                                .font(.caption)
                                        }
                                        
                                    }
                                }
                                Text("\(practiceSession.startTime.formatted(date: .complete, time: .omitted))")
                                    .font(.caption2)
                                    .padding(.top, 8)
                            }
                        }
                    }
                    .onDelete(perform: deleteSessions)
                }
                .contentMargins(.top, 40)
                
                if (practiceSessions.isEmpty) {
                    VStack {
                        Image(.welcome)
                            .resizable()
                            .frame(width: 60, height: 60)
                            .padding(10)
                        Text("Start Practicing")
                            .fontWeight(.bold)
                            .font(.title2)
                        Text("Create your first practice session.")
                            .foregroundColor(.gray)
                        Text("Tap the plus button to get started.")
                            .foregroundColor(.gray)
                        
                    }
                }
            }
            .safeAreaInset(edge: VerticalEdge.bottom) {
                NavigationLink {
                    PracticeSessionView()
                } label: {
                    Image(systemName: "plus")
                        .font(.largeTitle.weight(.bold))
                        .foregroundColor(.red)
                        .padding(25)
                        .background(.white)
                        .clipShape(Circle())
                        .shadow(radius: 10, x: 0, y: 6)
                }
            }
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle("Practice Journal")
        }
        .universalOverlay(show: $showMiniPlayer) {
            ExpandableMusicPlayer(
                show: $showMiniPlayer,
                hideMiniPlayer: $hideMiniPlayer
            )
            .environment(currentPracticeSession)
        }
        .onChange(of: currentPracticeSession.currentSession) {
            showMiniPlayer = currentPracticeSession.currentSession != nil && currentPracticeSession.currentTask != nil
        }
    }
    
    func deleteSessions(at offsets: IndexSet) {
        for offset in offsets {
            let session = practiceSessions[offset]
            modelContext.delete(session)
        }
    }
}

#Preview {
    let currentSession = PreviewExamples.getCurrentPracticeSession();
    
    RootView {
        ContentView()
    }
    .environment(currentSession)
    .modelContainer(PreviewExamples.previewContainer)
}
