import SwiftUI

struct PracticeItemDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(CurrentPracticeSession.self) private var currentSession
    
    @State var practiceSession: PracticeSession
    @State var practiceItem: PracticeTask
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text(practiceItem.getTitle())
                        .font(.title)
                    if let altWorkTitle = practiceItem.work?.alternativeTitle {
                        Text(altWorkTitle)
                            .italic()
                    }
                    if let composerName = practiceItem.work?.composerName {
                        Text(composerName)
                    }
                }
                Spacer()
                if practiceItem.work?.composerId != nil || practiceItem.work?.id != nil  {
                    Menu {
                        if let composerId = practiceItem.work?.composerId {
                            Link("Composer at IMSLP", destination: URL(string: "https://imslp.org/wiki/\(composerId)")!)
                        }
                        if let workId = practiceItem.work?.id {
                            Link("Work at IMSLP", destination: URL(string: "https://imslp.org/wiki/\(workId)")!)
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
                
            }
            .padding(.leading, 15)
            .padding(.trailing, 15)
            List {
                Section {
                    ForEach(practiceItem.practiceSubTasks) { subItem in
                        HStack {
                            Button()  {
                                let isCurrentSubTask = currentSession.isCurrentSubTask(practiceSession: practiceSession, item: practiceItem, subItem: subItem)
                                if (isCurrentSubTask) {
                                    currentSession.toggleTimer();
                                } else {
                                    currentSession.currentSession = self.practiceSession
                                    currentSession.currentTask = practiceItem
                                    currentSession.currentSubTask = subItem
                                    if (!currentSession.isTimerRunning()) {
                                        currentSession.toggleTimer();
                                    }
                                }
                            } label: {
                                Image(systemName: currentSession.isCurrentSubTask(practiceSession: practiceSession, item: practiceItem, subItem: subItem) && currentSession.isTimerRunning() ? "pause.circle" : "play.circle")
                                    .scaleEffect(1.25)
                            }.buttonStyle(PlainButtonStyle())
                            SubItemEditableNameView(subItemName: subItem.name ?? "", changeName: {newName in subItem.name = newName })
                            Spacer()
                            TimeElapsedView(timeElapsedInSeconds: practiceSession.getSecsSpentOnSubTask(subItem))
                        }.deleteDisabled(practiceItem.practiceSubTasks.count == 1)
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
                        practiceItem.practiceSubTasks.append(PracticeSubTask(name: "New Subitem", practiceNotes: []));
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
            practiceItem.practiceSubTasks.remove(at: offset)
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
    
    NavigationStack {
        PracticeItemDetailView(
            practiceSession: practiceSession,
            practiceItem: practiceSession.practiceTasks.first!
        )
        .environment(currentSession)
        .onAppear {
            currentSession.currentSession = practiceSession;
        }
    }
}
