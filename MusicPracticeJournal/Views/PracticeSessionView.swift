import SwiftUI
import SwiftData

struct PracticeSessionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(CurrentPracticeSession.self) private var currentSession
    
    @State var practiceSession: PracticeSession
    @State private var showingSessionRenamingAlert: Bool = false
    private var shouldInsertNewPracticeSession: Bool = false
    
    init(practiceSession: PracticeSession? = nil) {
        if let practiceSession = practiceSession {
            self.practiceSession = practiceSession
        } else {
            let newPracticeSession = PracticeSession();
            self.practiceSession = newPracticeSession;
            self.shouldInsertNewPracticeSession = true;
        }
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            VStack(alignment: .leading) {
                if !practiceSession.isDefaultName() {
                    Text(practiceSession.getDefaultSessionName())
                        .padding(.leading, 20)
                }
                List {
                    ForEach(practiceSession.practiceTasks) { practiceItem in
                        HStack {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(
                                    self.currentSession.isCurrentTask(practiceSession: practiceSession, item: practiceItem)
                                    ? .red : .gray
                                )
                                .frame(width: 6)
                        
                            if let technique = practiceItem.technique {
                                SharedElements.getTechniqueImage(isUserCreated: technique.isUserCreated)
                                    .padding(.trailing, 5)
                                    .padding(.top, 5)
                                    .background(.white)
                            } else if let work = practiceItem.work {
                                SharedElements.getWorkImage(isUserCreated: work.isUserCreated)
                                    .padding(.trailing, 5)
                                    .padding(.top, 5)
                                    .background(.white)
                            }
                            
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
                        .listRowInsets(EdgeInsets())
                        .padding(.leading, 10)
                        .padding(.trailing, 10)
                        .padding(.vertical, 10)
                    }
                    .onDelete(perform: deletePracticeItems)
                }
                .contentMargins(.top, 10)
                Spacer()
            }
            
            if (practiceSession.practiceTasks.isEmpty) {
                VStack {
                    Image(.welcome)
                        .resizable()
                        .frame(width: 60, height: 60)
                        .padding(10)
                    Text("Add Practice Items")
                        .fontWeight(.bold)
                        .font(.title2)
                    Text("Tap the plus button to add works or techniques to your practice session.")
                        .foregroundColor(.gray)
                        .padding(.leading, 40)
                        .padding(.trailing, 40)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                Button {
                    currentSession.clearSession()
                } label: {
                    Image(systemName: "stop.fill")
                        .font(.largeTitle.weight(.bold))
                        .foregroundColor(currentSession.isPracticeSet() ? .red : .gray)
                        .padding(15)
                        .background(.white)
                        .clipShape(Circle())
                        .shadow(radius: 10, x: 0, y: 6)
                }
                .disabled(!currentSession.isPracticeSet())
                Spacer()
                Button {
                    if !self.currentSession.isPracticeSet() {
                        if let firstTask = practiceSession.practiceTasks.first,
                           let firstSubTask = firstTask.practiceSubTasks.first {
                            self.currentSession.setPractice(
                                session: practiceSession,
                                task: firstTask,
                                subTask: firstSubTask
                            )
                        }
                    }
                    currentSession.toggleTimer()
                } label: {
                    Image(systemName: !currentSession.isTimerRunning() ? "play.fill" : "pause.fill")
                        .font(.largeTitle.weight(.bold))
                        .foregroundColor(!practiceSession.practiceTasks.isEmpty ? .red : .gray)
                        .padding(15)
                        .background(.white)
                        .clipShape(Circle())
                        .shadow(radius: 10, x: 0, y: 6)
                }
                .disabled(practiceSession.practiceTasks.isEmpty)
                Spacer()
                NavigationLink {
                    PracticeTaskPickerView(addNewPracticeItem: self.addNewPracticeItem)
                } label: {
                    Image(systemName: "plus")
                        .font(.largeTitle.weight(.bold))
                        .foregroundColor(.red)
                        .padding(15)
                        .background(.white)
                        .clipShape(Circle())
                        .shadow(radius: 10, x: 0, y: 6)
                }
                Spacer()
            }
        }
        .navigationTitle(practiceSession.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Rename session") {
                        showingSessionRenamingAlert.toggle()
                    }
                    
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                
            }
        }
        .alert("Change the session name", isPresented: $showingSessionRenamingAlert) {
            TextField("Session name", text: $practiceSession.name)
            Button("OK", action: {
                if practiceSession.name.isEmpty {
                    practiceSession.name = practiceSession.getDefaultSessionName()
                }
            })
        }
        .onAppear {
            if shouldInsertNewPracticeSession {
                modelContext.insert(self.practiceSession);
            }
        }
        .onDisappear {
            if practiceSession.practiceTasks.isEmpty {
                modelContext.delete(self.practiceSession);
            }
        }
    }
    
    func addNewPracticeItem(practiceItem: PracticeTask) {
        let subItem = PracticeSubTask(name: "General practice");
        practiceItem.practiceSubTasks.append(subItem);
        practiceSession.practiceTasks.append(practiceItem);
    }
    
    func deletePracticeItems(at offsets: IndexSet) {
        for offset in offsets {
            practiceSession.practiceTasks.remove(at: offset)
        }
    }
}

#Preview("No tasks") {
    let practiceSession = PreviewExamples.getEmptyPracticeSession();
    let currentSession = PreviewExamples.getCurrentPracticeSession();
    
    NavigationStack {
        PracticeSessionView(practiceSession: practiceSession)
            .onAppear {
                currentSession.currentSession = practiceSession;
            }
    }
    .environment(currentSession)
    .modelContainer(PreviewExamples.previewContainer)
}

#Preview("Populated with tasks") {
    let practiceSession = PreviewExamples.getPracticeSession();
    let currentSession = PreviewExamples.getCurrentPracticeSession();
    
    NavigationStack {
        PracticeSessionView(practiceSession: practiceSession)
            .onAppear {
                currentSession.currentSession = practiceSession;
            }
    }
    .environment(currentSession)
    .modelContainer(PreviewExamples.previewContainer)
}
