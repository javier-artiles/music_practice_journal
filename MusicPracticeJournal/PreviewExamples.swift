import Foundation

struct PreviewExamples {
    
    static func getCurrentPracticeSession() -> CurrentPracticeSession {
        return CurrentPracticeSession();
    }
    
    static func getPracticeSession() -> PracticeSession {
        let task_1 = PracticeTask(
            technique: Technique(name: "Tremolo"),
            practiceSubTasks: [
                PracticeSubTask(name: "General practice")
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
