import SwiftUI

struct PracticeItemPickerView: View {
    @Environment(\.dismiss) var dismiss
    
    let addNewPracticeItem: (PracticeItem) -> Void
    
    /*
     TODO: Populate both techniques and pieces at App startup
     then query here
    */
    let techniques: [Technique] = [
        Technique(name: "Tremolo"),
        Technique(name: "Slurs"),
        Technique(name: "Arpeggios"),
    ]
    let musicPieces: [MusicPiece] = [
        MusicPiece(name: "Twinkle Twinkle Little Star"),
        MusicPiece(name: "Mary Had a Little Lamb"),
        MusicPiece(name: "Jingle Bells"),
    ]
    
    var body: some View {
        VStack(alignment: .center) {
            Text("What shall we practice today?")
                .font(.title)
            // TODO: combine both lists (inheritance?)
            List {
                ForEach(techniques) { technique in
                    Button("[T] " + technique.name) {
                        addTechnique(technique: technique)
                    }
                }
                ForEach(musicPieces) { musicPiece in
                    Button("[P] " + musicPiece.name) {
                        addMusicPiece(musicPiece: musicPiece)
                    }
                }
            }
            Spacer()
            Button("Dismiss") {
                dismiss()
            }
            .font(.title3)
            .padding()
        }
    }
    
    func addTechnique(technique: Technique) {
        let practiceItem = PracticeItem(
            technique: technique
        )
        addNewPracticeItem(practiceItem)
        dismiss()
    }
    
    func addMusicPiece(musicPiece: MusicPiece) {
        let practiceItem = PracticeItem(
            musicPiece: musicPiece
        )
        addNewPracticeItem(practiceItem)
        dismiss()
    }
}

#Preview {
    let addNewPracticeItem : (PracticeItem) -> Void = { _ in }
    PracticeItemPickerView(addNewPracticeItem: addNewPracticeItem)
}
