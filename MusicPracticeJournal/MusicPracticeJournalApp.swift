import SwiftUI
import SwiftData
import AVFoundation

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
            PracticeSubTask.self,
            AudioRecording.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: ProcessInfo.processInfo.isSwiftUIPreview)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        /*
        WindowGroup {
            MetronomeView()
                .onAppear() {
                    // Initialize audio
                    do {
                        let session = AVAudioSession.sharedInstance()
                        try session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
                        try session.setActive(true)
                    } catch {
                        print("Failed to set audio session category. Error: \(error)")
                    }
                }
        }
        */
        WindowGroup {
            VStack {
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
                    RootView {
                        ContentView()
                            .environment(currentSession)
                    }
                }
            }
            .onAppear() {
                // Initialize audio
                do {
                    let session = AVAudioSession.sharedInstance()
                    try session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
                    try session.setActive(true)
                } catch {
                    print("Failed to set audio session category. Error: \(error)")
                }
                
                // Populate works
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
