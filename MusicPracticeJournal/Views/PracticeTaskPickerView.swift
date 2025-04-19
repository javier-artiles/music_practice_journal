import SwiftUI
import SwiftData

struct WorksSearchResultsListView: View {
    @Query var works: [Work]
    
    let pickedWork: (Work) -> Void
    
    init(searchText: String, pickedWork: @escaping (Work) -> Void) {
        self.pickedWork = pickedWork
        var descriptor = FetchDescriptor<Work>(
            predicate: #Predicate { work in
                work.title.localizedStandardContains(searchText)
                || work.alternativeTitle?.localizedStandardContains(searchText) ?? false
                || work.composerName?.localizedStandardContains(searchText) ?? false
            },
            sortBy: [SortDescriptor(\Work.title, order: .forward)]
        )
        descriptor.fetchLimit = 25
        _works = Query(descriptor)
    }
    
    var body: some View {
        List {
            ForEach(works) { work in
                Button {
                    pickedWork(work)
                } label: {
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
                }.buttonStyle(.plain)
            }
        }
    }
}

struct PracticeTaskPickerView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var searchText = ""
    
    @Query private var works: [Work]
    
    let addNewPracticeItem: (PracticeTask) -> Void
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                WorksSearchResultsListView(
                    searchText: searchText,
                    pickedWork: pickedWork
                )
                .toolbar {
                    // TODO allow user to add a work
                    ToolbarItemGroup(placement: .primaryAction) {
                        Button("Add", systemImage: "plus") {}
                    }
                }
                .searchable(text: $searchText, prompt: "Search")
                Spacer()
            }
        }
    }
    
    func pickedWork(work: Work) {
        let practiceItem = PracticeTask(
            work: work
        )
        addNewPracticeItem(practiceItem)
        dismiss()
    }
}

#Preview {
    let addNewPracticeItem : (PracticeTask) -> Void = { _ in }
    PracticeTaskPickerView(addNewPracticeItem: addNewPracticeItem)
        .modelContainer(PreviewExamples.previewContainer)
}
