import SwiftUI
import SwiftData

struct PracticeSessionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(CurrentPracticeSession.self) private var currentSession
    
    @State var practiceSession: PracticeSession?
    @State private var showingPracticeItemPicker: Bool = false
    
    var body: some View {
        VStack(alignment: .center) {
            PracticeSessionEditableNameView(
                name: practiceSession?.practicePlan.name ?? "",
                changeName: { newName in
                    self.practiceSession?.practicePlan.name = newName
                }
            )
            .font(.title)
            List {
                if let practiceSession = practiceSession {
                    ForEach(practiceSession.practicePlan.practiceItems){ practiceItem in
                        HStack {
                            Button()  {
                                let isCurrentTask = currentSession.isCurrentTask(practiceSession: practiceSession, item: practiceItem)
                                if (isCurrentTask) {
                                    currentSession.toggleTimer();
                                } else {
                                    currentSession.currentSession = self.practiceSession
                                    currentSession.currentItem = practiceItem
                                    currentSession.currentSubItem = practiceItem.practiceSubItems.first
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
                                        TimeElapsedView(timeElapsedInSeconds: practiceSession.getSecsSpentOnItem(practiceItem))
                                    }
                                    if (currentSession.isCurrentTask(practiceSession: practiceSession, item: practiceItem) &&  currentSession.currentSubItem != nil) {
                                        Text(currentSession.currentSubItem?.name ?? "no-name")
                                            .font(.caption)
                                    } else if (practiceItem.practiceSubItems.count > 0) {
                                        Text(practiceItem.practiceSubItems[0].name ?? "no-name")
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
            }
            Spacer()
        }
        .onAppear {
            if self.practiceSession == nil {
                practiceSession = self.createNewSession();
            }
        }
        .sheet(isPresented: $showingPracticeItemPicker) {
            PracticeItemPickerView(addNewPracticeItem: self.addNewPracticeItem)
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
    
    func addNewPracticeItem(practiceItem: PracticeItem) {
        if let practiceSession = practiceSession {
            let subItem = PracticeSubItem(name: "General practice");
            practiceItem.practiceSubItems.append(subItem);
            practiceSession.practicePlan.practiceItems.append(practiceItem);
        }
    }
    
    func deletePracticeItems(at offsets: IndexSet) {
        if let practiceSession = practiceSession {
            for offset in offsets {
                practiceSession.practicePlan.practiceItems.remove(at: offset)
            }
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
