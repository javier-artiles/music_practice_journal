import SwiftUI
import SwiftData

enum DataImportState: String {
    case loadingWorks = "Loading works..."
    case decodingWorks = "Decoding works..."
    case insertingWorks = "Inserting works..."
    case completed = "Completed"
    case failed = "Failed"
    case unknown = "Unknown"
}

@main
struct MusicPracticeJournalApp: App {
    @State private var currentSession = CurrentPracticeSession();
    @State private var dataImportState: DataImportState = .unknown;
    @State private var numLoadedWorks: Int = 0;
    

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
                if dataImportState == .unknown {
                    // show nothing here
                } else if dataImportState == .insertingWorks {
                    VStack(alignment: .center) {
                        ProgressView(
                            self.dataImportState.rawValue,
                            value: Double(self.numLoadedWorks),
                            total: Double(232400)
                        )
                    }.padding()
                } else if dataImportState == .decodingWorks || dataImportState == .loadingWorks {
                    ProgressView(
                        self.dataImportState.rawValue
                    )
                } else {
                    ContentView()
                        .environment(currentSession)
                }
            }
            .onAppear() {
                let existingWorks = try! sharedModelContainer.mainContext.fetchCount(FetchDescriptor<Work>())
                print("Number of existing works: \(existingWorks)")
                if existingWorks > 0 {
                    self.dataImportState = .completed
                    return;
                } else {
                    let backgroundImporter = BackgroundImporter(modelContainer: sharedModelContainer, updateImportProgress: updateImportProgress)
                    Task {
                        do {
                            try await backgroundImporter.backgroundInsert()
                        } catch {
                            print("Background importer failed: \(error)")
                            self.dataImportState = .failed
                        }
                    }
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
    
    func updateImportProgress(dataImportState: DataImportState, numLoadedWorks: Int) {
        self.dataImportState = dataImportState
        self.numLoadedWorks = numLoadedWorks
    }
}
