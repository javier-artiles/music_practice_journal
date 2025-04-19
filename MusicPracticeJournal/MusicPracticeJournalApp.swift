import SwiftUI
import SwiftData


@main
struct MusicPracticeJournalApp: App {
    @State private var currentSession = CurrentPracticeSession();

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PracticeSession.self,
            Work.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView {
                ContentView()
                    .environment(currentSession)
            }
            .task {
                do {
                    let existingWorks = try sharedModelContainer.mainContext.fetchCount(FetchDescriptor<Work>())
                    print("Number of existing works: \(existingWorks)")
                    if existingWorks > 0 {
                        return;
                    }
                    
                    print("Loading works...")
                    guard let url = Bundle.main.url(forResource: "works", withExtension: "lzfse") else {
                        fatalError("Failed to find works.lzfse")
                    }
                    let compressedData = try Data(contentsOf: url)
                    let data = try (compressedData as NSData).decompressed(using: .lzfse)
                    
                    print("Decoding works...")
                    let works = try JSONDecoder().decode([Work].self, from: data as Data)
                    
                    print("Inserting \(works.count) works...")
                    for i in 0...(works.count - 1)  {
                        let work = works[i]
                        sharedModelContainer.mainContext.insert(work)
                        if i % 1000 == 0 {
                            try sharedModelContainer.mainContext.save()
                        }
                    }
                    try sharedModelContainer.mainContext.save()
                    print("Saved")
                } catch {
                    print("Failed to populate database \(error)")
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
