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
            NavigationLink("New Practice Session") {
                PracticeSessionView()
            }
            List {
                ForEach(practiceSessions) { practiceSession in
                    NavigationLink {
                        PracticeSessionView(practiceSession: practiceSession)
                    } label: {
                        VStack(alignment: .leading) {
                            HStack(alignment: .top) {
                                Text("\(practiceSession.practicePlan.name)")
                                Spacer()
                                Text("\(practiceSession.getSecsSpentOnSession()) secs")
                            }
                            ForEach(practiceSession.practicePlan.practiceTasks) { item in
                                Text("· " + item.getName())
                                    .font(.caption)
                            }
                            Text("\(practiceSession.startTime.formatted(date: .complete, time: .omitted))")
                                .font(.caption2)
                                .padding(.top, 8)
                        }
                    }
                }
                .onDelete(perform: deleteSessions)
            }
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
    
    func createNewSession() -> PracticeSession {
        let practicePlan = PracticePlan(name: "My awesome plan", practiceTasks: [])
        let practiceSession = PracticeSession(
            startTime: Date(),
            practicePlan: practicePlan
        );
        modelContext.insert(practiceSession);
        return practiceSession;
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
    .modelContainer(for: PracticeSession.self, inMemory: true)
}
