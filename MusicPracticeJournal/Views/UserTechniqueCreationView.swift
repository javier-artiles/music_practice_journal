import SwiftUI
import SwiftData

struct UserTechniqueCreationView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State var name: String = ""
    @State var classification: String = ""
    let createdTechnique: (Technique) -> Void
    
    var body: some View {
        Form {
            Section(header: Text("New technique")) {
                TextField("Name", text: $name)
                TextField("Classification", text: $classification)
            }
            Section {
                Button("Create and add to session") {
                    let newTechnique = Technique(
                        name: name,
                        classification: classification,
                        isUserCreated: true
                    )
                    modelContext.insert(newTechnique)
                    createdTechnique(newTechnique)
                }
                .disabled(!isValidForm())
            }
        }
        .navigationBarTitle("New Technique")
    }
    
    func isValidForm() -> Bool {
        return !name.isEmpty && !classification.isEmpty
    }
}

#Preview {
    NavigationStack {
        UserTechniqueCreationView(createdTechnique: {_ in })
            .modelContainer(PreviewExamples.previewContainer)
    }
}
