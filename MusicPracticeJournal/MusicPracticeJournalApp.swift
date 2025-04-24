import SwiftUI
import SwiftData


@main
struct MusicPracticeJournalApp: App {
    @State private var currentSession = CurrentPracticeSession();

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Technique.self,
            Work.self,
            PracticeTask.self,
            PracticeSession.self,
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
                    
                    print("Loading techniques...")
                    guard let techniquesUrl = Bundle.main.url(forResource: "techniques", withExtension: "json") else {
                        fatalError("Failed to find techniques.json")
                    }
                    let techniquesData = try Data(contentsOf: techniquesUrl)
                    let techniques = try JSONDecoder().decode([Technique].self, from: techniquesData)
                    print("Inserting \(techniques.count) techniques...")
                    for i in 0...(techniques.count - 1)  {
                        let technique = techniques[i]
                        sharedModelContainer.mainContext.insert(technique)
                    }
                    
                    print("Loading works...")
                    guard let worksUrl = Bundle.main.url(forResource: "works", withExtension: "lzfse") else {
                        fatalError("Failed to find works.lzfse")
                    }
                    let compressedWorksData = try Data(contentsOf: worksUrl)
                    let worksData = try (compressedWorksData as NSData).decompressed(using: .lzfse)
                    
                    print("Decoding works...")
                    let works = try JSONDecoder().decode([Work].self, from: worksData as Data)
                    
                    print("Inserting \(works.count) works...")
                    for i in 0...(works.count - 1)  {
                        let work = works[i]
                        sharedModelContainer.mainContext.insert(work)
                        if i % 10000 == 0 {
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
