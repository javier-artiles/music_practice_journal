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
                        Image(systemName: "oar.2.crossed")
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
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
                }.buttonStyle(.plain)
            }
            ForEach(works) { work in
                Button {
                    pickedWork(work)
                } label: {
                    HStack(alignment: .top) {
                        Image(systemName: "music.quarternote.3")
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
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
            VStack {
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
    
    @Query private var works: [Work]
    
    let addNewPracticeItem: (PracticeTask) -> Void
    
    var body: some View {
        NavigationStack {
            // Do not search single letter queries
            if searchContext.query.count >= 2 {
                TasksSearchResultsListView(
                    searchContext: searchContext,
                    pickedWork: pickedWork,
                    pickedTechnique: pickedTechnique
                ).toolbar {
                    ToolbarItemGroup(placement: .primaryAction) {
                        Button("Add", systemImage: "plus") {}
                    }
                }
            }
        }
        .searchable(text: $searchContext.query, prompt: "Search")
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
}

#Preview {
    let addNewPracticeItem : (PracticeTask) -> Void = { _ in }
    PracticeTaskPickerView(
        addNewPracticeItem: addNewPracticeItem
    )
        .modelContainer(PreviewExamples.previewContainer)
}
