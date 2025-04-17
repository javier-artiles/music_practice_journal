import SwiftUI
import SwiftData

struct PracticeSessionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(CurrentPracticeSession.self) private var currentSession
    
    @State var practiceSession: PracticeSession
    @State private var showingPracticeItemPicker: Bool = false
    private var shouldInsertNewPracticeSession: Bool = false
    
    init(practiceSession: PracticeSession? = nil) {
        if let practiceSession = practiceSession {
            self.practiceSession = practiceSession
        } else {
            let practicePlan = PracticePlan(name: "My awesome plan", practiceTasks: [])
            let newPracticeSession = PracticeSession(
                startTime: Date(),
                practicePlan: practicePlan
            );
            self.practiceSession = newPracticeSession;
            self.shouldInsertNewPracticeSession = true;
        }
    }
    
    var body: some View {
        VStack(alignment: .center) {
            PracticeSessionEditableNameView(
                name: practiceSession.practicePlan.name,
                changeName: { newName in
                    self.practiceSession.practicePlan.name = newName
                }
            )
            .font(.title)
            List {
                ForEach(practiceSession.practicePlan.practiceTasks){ practiceItem in
                    HStack {
                        Button()  {
                            let isCurrentTask = currentSession.isCurrentTask(practiceSession: practiceSession, item: practiceItem)
                            if (isCurrentTask) {
                                currentSession.toggleTimer();
                            } else {
                                currentSession.currentSession = self.practiceSession
                                currentSession.currentTask = practiceItem
                                currentSession.currentSubTask = practiceItem.practiceSubTasks.first
                                if (!currentSession.isTimerRunning()) {
                                    currentSession.toggleTimer();
                                }
                            }
                        } label: {
                            Image(systemName: currentSession.isCurrentTask(practiceSession: practiceSession, item: practiceItem) && currentSession.isTimerRunning() ? "pause.circle" : "play.circle")
                                .scaleEffect(1.5)
                        }.buttonStyle(PlainButtonStyle())
                        NavigationLink {
                            PracticeItemDetailView(practiceSession: practiceSession, practiceItem: practiceItem)
                        } label: {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(practiceItem.getTitle())
                                    Spacer()
                                    TimeElapsedView(timeElapsedInSeconds: practiceSession.getSecsSpentOnTask(practiceItem))
                                }
                                if (currentSession.isCurrentTask(practiceSession: practiceSession, item: practiceItem) &&  currentSession.currentSubTask != nil) {
                                    Text(currentSession.currentSubTask?.name ?? "no-name")
                                        .font(.caption)
                                } else if (practiceItem.practiceSubTasks.count > 0) {
                                    Text(practiceItem.practiceSubTasks[0].name ?? "no-name")
                                        .font(.caption)
                                }
                                
                            }
                        }
                    }
                }
                .onDelete(perform: deletePracticeItems)
                Button("Add New Practice Item") {
                    showingPracticeItemPicker.toggle();
                }
            }
            Spacer()
        }
        .sheet(isPresented: $showingPracticeItemPicker) {
            PracticeItemPickerView(addNewPracticeItem: self.addNewPracticeItem)
        }
        .onAppear {
            if shouldInsertNewPracticeSession {
                modelContext.insert(self.practiceSession);
            }
        }
    }
    
    func addNewPracticeItem(practiceItem: PracticeTask) {
        let subItem = PracticeSubTask(name: "General practice");
        practiceItem.practiceSubTasks.append(subItem);
        practiceSession.practicePlan.practiceTasks.append(practiceItem);
    }
    
    func deletePracticeItems(at offsets: IndexSet) {
        for offset in offsets {
            practiceSession.practicePlan.practiceTasks.remove(at: offset)
        }
    }
}

#Preview {
    let practiceSession = PreviewExamples.getPracticeSession();
    let currentSession = PreviewExamples.getCurrentPracticeSession();
    
    NavigationStack {
        PracticeSessionView(practiceSession: practiceSession)
            .onAppear {
                currentSession.currentSession = practiceSession;
            }
    }.environment(currentSession)
}
