import SwiftUI
import SwiftData

struct UserTechniqueEditView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State var technique: Technique
    @State var name: String
    @State var classification: String
    
    init(technique: Technique) {
        self.technique = technique
        self.name = technique.name
        self.classification = technique.classification
    }
    
    var body: some View {
        Form {
            TextField("Name", text: $name)
            TextField("Classification", text: $classification)
            Section {
                Button("Update") {
                    technique.name = name
                    technique.classification = classification
                    dismiss()
                }
                .disabled(isUnchanged())
            }
            Section {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .navigationBarTitle("Edit Technique")
    }
    
    func isUnchanged() -> Bool {
        return technique.name == name && technique.classification == classification
    }
}

#Preview {
    NavigationStack {
        UserTechniqueEditView(technique: PreviewExamples.getSingleTechnique())
            .modelContainer(PreviewExamples.previewContainer)
    }
}
