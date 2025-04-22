import SwiftUI
import SwiftData

class SearchContext: ObservableObject {
    init() {
       $query
           .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
           .assign(to: &$debouncedQuery)
    }

    @Published var query = ""
    @Published var debouncedQuery = ""
}

struct TasksSearchResultsListView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query var techniques: [Technique]
    
    @State var works: [Work] = []
    @State var totalWorks: Int = 0
    @State var shouldLoadMoreWorks: Bool = false
    @State var showingTechniqueDeleteAlert: Bool = false
    
    var searchContext: SearchContext
    let pickedWork: (Work) -> Void
    let pickedTechnique: (Technique) -> Void
    
    init(
        searchContext: SearchContext,
        pickedWork: @escaping (Work) -> Void,
        pickedTechnique: @escaping (Technique) -> Void
    ) {
        self.searchContext = searchContext
        self.pickedWork = pickedWork
        self.pickedTechnique = pickedTechnique
        
        // Total techniques are so few that can be fetched in one go
        // Works are deferred to a separate task with pagination
        let debouncedQuery = searchContext.debouncedQuery
        let techniqueDescriptor = FetchDescriptor<Technique>(
            predicate: #Predicate { technique in
                technique.name.localizedStandardContains(debouncedQuery)
            },
            sortBy: [SortDescriptor(\Technique.name, order: .forward)]
        )
        _techniques = Query(techniqueDescriptor)
    }
    
    var body: some View {
        // For debugging purposes
        /*
        Text("'\(searchContext.debouncedQuery)' found \(totalWorks) works")
        Text("shouldLoadMoreWorks '\(shouldLoadMoreWorks)'")
        */
        List {
            ForEach(techniques) { technique in
                Button {
                    pickedTechnique(technique)
                } label: {
                    HStack(alignment: .top) {
                        SharedElements.getTechniqueImage(isUserCreated: technique.isUserCreated)
                            .padding(.trailing, 5)
                            .padding(.top, 5)
                            .background(.white)
                        VStack(alignment: .leading) {
                            Text(technique.name)
                                .fontWeight(.bold)
                            Text(technique.classification)
                                .font(.caption)
                        }
                    }
                }
                .buttonStyle(.plain)
                .alert(
                    "Confirmation",
                    isPresented: $showingTechniqueDeleteAlert
                ) {
                    Button("Delete", role: .destructive) {
                        deleteTechnique(technique)
                    }
                    Button("Cancel", role: .cancel) { }
                }
                message: {
                    Text("Deleting this technique will also remove all tasks associated to it on your practice sessions. Are you sure?")
                }
                .swipeActions {
                    NavigationLink {
                        UserTechniqueEditView(technique: technique)
                    } label: {
                        Text("Edit")
                            
                    }
                    .tint(.green)
                    if technique.isUserCreated {
                        Button {
                            self.showingTechniqueDeleteAlert = true
                        } label: {
                            Text("Delete")
                        }
                        .tint(.red)
                        
                    }
                }
            }
            
            
            ForEach(works) { work in
                Button {
                    pickedWork(work)
                } label: {
                    HStack(alignment: .top) {
                        SharedElements.getWorkImage(isUserCreated: work.isUserCreated)
                            .padding(.trailing, 5)
                            .padding(.top, 5)
                            .background(.white)
                        VStack(alignment: .leading) {
                            Text(work.title)
                                .fontWeight(.bold)
                            if let altTitle = work.alternativeTitle {
                                Text(altTitle)
                                    .italic()
                                    .font(.caption)
                            }
                            if let composer = work.composerName {
                                Text(composer)
                                    .font(.caption)
                            }
                        }
                    }
                }.buttonStyle(.plain)
            }
            ZStack {
            }.onAppear {
                self.shouldLoadMoreWorks = true
            }
        }
        .onAppear {
            self.works = fetchWorks(query: searchContext.debouncedQuery)
            self.totalWorks = fetchTotalWorksCount(query: searchContext.debouncedQuery)
        }
        .onChange(of: searchContext.debouncedQuery) {
            self.works = fetchWorks(query: searchContext.debouncedQuery)
            self.totalWorks = fetchTotalWorksCount(query: searchContext.debouncedQuery)
        }
        .onChange(of: shouldLoadMoreWorks) {
            if shouldLoadMoreWorks {
                self.shouldLoadMoreWorks = false
                if works.count < totalWorks {
                    let moreWorks = fetchWorks(query: searchContext.debouncedQuery, offset: works.count)
                    self.works.append(contentsOf: moreWorks)
                    self.totalWorks = fetchTotalWorksCount(query: searchContext.debouncedQuery)
                }
            }
        }
    }
    
    private func deleteTechnique(_ technique: Technique) {
        if technique.isUserCreated {
            do {
                // Clean up all tasks that have been orphaned
                let name = technique.name
                let classification = technique.classification
                
                let orphanedTasksDescriptor = FetchDescriptor<PracticeTask>(
                    predicate: #Predicate<PracticeTask> { task in
                        return  task.technique?.isUserCreated ?? false &&
                            task.technique?.name == name &&
                        task.technique?.classification == classification
                    }
                )
                let orphanedTasks = try modelContext.fetch(orphanedTasksDescriptor)
                
                for orphanedTask in orphanedTasks {
                    for session in orphanedTask.sessions {
                        session.practiceTasks.removeAll(where: {$0 === orphanedTask})
                        for subTask in orphanedTask.practiceSubTasks {
                            session.secsSpentPerSubItem.removeValue(forKey: subTask.id)
                        }
                    }
                }
                
                for orphanedTask in orphanedTasks {
                    print("Delete orphaned task: \(orphanedTask)")
                    modelContext.delete(orphanedTask)
                }
                
                modelContext.delete(technique)
                try modelContext.save()
            } catch {
                print("Error saving after deleting technique: \(error)")
            }
        }
    }
    
    private func getWorkFetchDescriptor(query: String) -> FetchDescriptor<Work> {
        return FetchDescriptor<Work>(
            predicate: #Predicate { work in
                work.title.localizedStandardContains(query)
                || work.alternativeTitle?.localizedStandardContains(query) ?? false
                || work.composerName?.localizedStandardContains(query) ?? false
            },
            sortBy: [SortDescriptor(\Work.title, order: .forward)]
        )
    }
    
    private func fetchTotalWorksCount(query: String) -> Int {
        var workDescriptor = getWorkFetchDescriptor(query: query)
        workDescriptor.fetchLimit = nil
        var totalWorksCount: Int = 0
        do {
            totalWorksCount = try modelContext.fetchCount(workDescriptor)
        } catch {
            print("Failed to fetch works count: \(error)")
        }
        return totalWorksCount
    }
    
    private func fetchWorks(query: String, offset: Int = 0, limit: Int = 30) -> [Work] {
        var workDescriptor = getWorkFetchDescriptor(query: query)
        workDescriptor.fetchOffset = offset
        workDescriptor.fetchLimit = limit
        var fetchedWorks: [Work] = []
        do {
            fetchedWorks = try modelContext.fetch(workDescriptor)
        } catch {
            print("Failed to fetch works: \(error)")
        }
        print("Fetched \(fetchedWorks.count) works for the query \(searchContext.debouncedQuery), offset \(offset), limit \(limit)")
        return fetchedWorks;
    }
}

struct PracticeTaskPickerView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject var searchContext = SearchContext()
    
    @State private var selection: Int = 0
    @State var presentUserTechniqueCreation: Bool = false
    
    let addNewPracticeItem: (PracticeTask) -> Void
    
    var body: some View {
        TasksSearchResultsListView(
            searchContext: searchContext,
            pickedWork: pickedWork,
            pickedTechnique: pickedTechnique
        )
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Menu {
                    Button {
                        
                    } label: {
                        Text("Add a new work")
                    }
                    Button {
                        presentUserTechniqueCreation.toggle()
                    } label: {
                        Text("Add a new technique")
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $presentUserTechniqueCreation) {
            UserTechniqueCreationView(createdTechnique: createdTechnique)
        }
        .searchable(
            text: $searchContext.query,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search for a work or technique"
        )
    }
    
    func pickedWork(work: Work) {
        let practiceItem = PracticeTask(
            work: work
        )
        addNewPracticeItem(practiceItem)
        dismiss()
    }
    
    func pickedTechnique(technique: Technique) {
        let practiceItem = PracticeTask(
            technique: technique
        )
        addNewPracticeItem(practiceItem)
        dismiss()
    }
    
    func createdTechnique(technique: Technique) {
        self.presentUserTechniqueCreation = false
        let practiceItem = PracticeTask(
            technique: technique
        )
        addNewPracticeItem(practiceItem)
        dismiss()
    }
}

#Preview {
    let addNewPracticeItem : (PracticeTask) -> Void = { _ in }
    NavigationStack {
        PracticeTaskPickerView(
            addNewPracticeItem: addNewPracticeItem
        )
        .modelContainer(PreviewExamples.previewContainer)
    }
}
