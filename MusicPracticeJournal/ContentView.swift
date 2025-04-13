import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var practiceSessions: [PracticeSession]

    var body: some View {
        NavigationStack {
            List {
                ForEach(practiceSessions) { practiceSession in
                    NavigationLink(
                        "\(practiceSession.startTime)",
                        destination: PracticeSessionView(practiceSession: practiceSession)
                    )
                }
                .onDelete(perform: deleteSessions)
            }
            NavigationLink("New Practice Session") {
                PracticeSessionView()
            }
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
    ContentView()
        .modelContainer(for: PracticeSession.self, inMemory: true)
        .environment(currentSession)
}
