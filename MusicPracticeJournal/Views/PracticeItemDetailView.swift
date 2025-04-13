import SwiftUI

struct PracticeItemDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(CurrentPracticeSession.self) private var currentSession
    
    @State var practiceSession: PracticeSession
    @State var practiceItem: PracticeItem
    
    var body: some View {
        VStack(alignment: .center) {
            Text(practiceItem.getTitle())
                .font(.title)
            List {
                Section {
                    ForEach(practiceItem.practiceSubItems) { subItem in
                        HStack {
                            Button()  {
                                let isCurrentSubTask = currentSession.isCurrentSubTask(practiceSession: practiceSession, item: practiceItem, subItem: subItem)
                                if (isCurrentSubTask) {
                                    currentSession.toggleTimer();
                                } else {
                                    currentSession.currentSession = self.practiceSession
                                    currentSession.currentItem = practiceItem
                                    currentSession.currentSubItem = subItem
                                    if (!currentSession.isTimerRunning()) {
                                        currentSession.toggleTimer();
                                    }
                                }
                            } label: {
                                Image(systemName: currentSession.isCurrentSubTask(practiceSession: practiceSession, item: practiceItem, subItem: subItem) && currentSession.isTimerRunning() ? "pause.circle" : "play.circle")
                                    .scaleEffect(1.25)
                            }.buttonStyle(PlainButtonStyle())
                            Text(subItem.name ?? "?")
                            Spacer()
                            TimeElapsedView(timeElapsedInSeconds: practiceSession.getSecsSpentOnSubItem(subItem))
                        }.deleteDisabled(practiceItem.practiceSubItems.count == 1)
                        ForEach(subItem.practiceNotes) { practiceNote in
                            Text("|| " + practiceNote.title)
                        }.onDelete { indexSet in
                            for offset in indexSet {
                                subItem.practiceNotes.remove(at: offset)
                            }
                        }
                    }.onDelete(perform: deletePracticeSubItems)
                    Button("Add a sub-item") {
                        // TODO: sheet dialog?
                        practiceItem.practiceSubItems.append(PracticeSubItem(name: "New Subitem", practiceNotes: []));
                    }
                }
                Section {
                    ForEach(practiceItem.practiceNotes) { practiceNote in
                        Text(practiceNote.title)
                    }.onDelete(perform: deletePracticeItemNotes)
                    Button("Add a note") {
                        // TODO: sheet dialog?
                        let newPracticeNote = PracticeNote(
                            creationDate: Date(),
                            latestUpdate: Date(),
                            title: "New Note",
                            text: ""
                        );
                        practiceItem.practiceNotes.append(newPracticeNote);
                    }
                }
            }
            Spacer()
        }
    }
    
    func deletePracticeSubItems(at offsets: IndexSet) {
        for offset in offsets {
            practiceItem.practiceSubItems.remove(at: offset)
        }
    }
    
    func deletePracticeItemNotes(at offsets: IndexSet) {
        for offset in offsets {
            practiceItem.practiceNotes.remove(at: offset)
        }
    }
}

#Preview {
    let currentSession = PreviewExamples.getCurrentPracticeSession();
    let practiceSession = PreviewExamples.getPracticeSession();
    PracticeItemDetailView(
        practiceSession: practiceSession,
        practiceItem: practiceSession.practicePlan.practiceItems.first!
    )
    .environment(currentSession)
    .onAppear {
        currentSession.currentSession = practiceSession;
    }
}
