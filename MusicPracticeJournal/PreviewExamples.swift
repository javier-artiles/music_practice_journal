import Foundation
import SwiftData

@MainActor
class PreviewExamples {
    
    static let previewContainer: ModelContainer = {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Work.self, configurations: config)

            for i in 1...9 {
                let work = Work(
                    id: String.init(format: "%02d", i),
                    title: "Work \(i)",
                    alternativeTitle: "Alternative title \(i)",
                    composerName: "Composer \(i % 3)",
                    composerId: "composer_\(i % 3)",
                    instrumentation: ["guitar"]
                )
                container.mainContext.insert(work)
            }
            return container
        } catch {
            fatalError("Failed to create model container for previewing: \(error.localizedDescription)")
        }
    }()
    
    static func getCurrentPracticeSession() -> CurrentPracticeSession {
        return CurrentPracticeSession();
    }
    
    static func getSingleWork() -> Work {
        return Work(
            id: "001",
            title: "Work 1",
            alternativeTitle: "Alternative title 1",
            composerName: "Composer 1",
            composerId: "composer_1",
            instrumentation: ["guitar"]
        )
    }
    
    static func getPracticeSession() -> PracticeSession {
        let task_1 = PracticeTask(
            work: getSingleWork(),
            practiceSubTasks: [
                PracticeSubTask(name: "Section A"),
                PracticeSubTask(name: "Section B"),
            ]
        )
        let task_2 = PracticeTask(
            technique: Technique(name: "Slurs"),
            practiceSubTasks: [
                PracticeSubTask(name: "Hammer on"),
                PracticeSubTask(name: "Pull off")
            ]
        )
        let practicePlan = PracticePlan(name: "My awesome plan", practiceTasks: [task_1, task_2])
        let practiceSession = PracticeSession(
            startTime: Date(),
            practicePlan: practicePlan
        );
        return practiceSession;
    }
    
    static func getPracticeItem() -> PracticeTask {
        return PracticeTask(
            technique: Technique(name: "Tremolo"),
            practiceSubTasks: [
                PracticeSubTask(
                    name: "Planting",
                    practiceNotes: [
                        PracticeNote(
                            creationDate: Date(),
                            latestUpdate: Date(),
                            title: "This is a note on a sub item",
                            text: "This is some text in the note itself"
                        ),
                    ]
                ),
                PracticeSubTask(name: "Legato"),
            ],
            practiceNotes: [
                PracticeNote(
                    creationDate: Date(),
                    latestUpdate: Date(),
                    title: "This is a note",
                    text: "This is some text in the note itself"
                ),
            ]
        );
    }
    
    
    static func getPracticeSubItem() -> PracticeSubTask {
        return PracticeSubTask(
            name: "Planting",
            practiceNotes: [
                PracticeNote(
                    creationDate: Date(),
                    latestUpdate: Date(),
                    title: "This is a note on a sub item",
                    text: "This is some text in the note itself"
                ),
            ]
        );
    }
    
}
