import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var practiceSessions: [PracticeSession]

    var body: some View {
        NavigationStack {
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
                            ForEach(practiceSession.practicePlan.practiceItems) { item in
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
            NavigationLink("New Practice Session") {
                PracticeSessionView()
            }
        }
    }
    
    func createNewSession() -> PracticeSession {
        let practicePlan = PracticePlan(name: "My awesome plan", practiceItems: [])
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
    ContentView()
        .modelContainer(for: PracticeSession.self, inMemory: true)
        .environment(currentSession)
}
