import Foundation

struct PreviewExamples {
    
    static func getCurrentPracticeSession() -> CurrentPracticeSession {
        return CurrentPracticeSession();
    }
    
    static func getPracticeSession() -> PracticeSession {
        let subItem = PracticeSubItem(name: "General practice");
        let item = PracticeItem(
            technique: Technique(name: "Tremolo"),
            practiceSubItems: [subItem]
        )
        let practicePlan = PracticePlan(name: "My awesome plan", practiceItems: [item])
        let practiceSession = PracticeSession(
            startTime: Date(),
            practicePlan: practicePlan
        );
        return practiceSession;
    }
    
    static func getPracticeItem() -> PracticeItem {
        return PracticeItem(
            technique: Technique(name: "Tremolo"),
            practiceSubItems: [
                PracticeSubItem(
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
                PracticeSubItem(name: "Legato"),
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
    
}
