import SwiftUI
import SwiftData

struct UserWorkCreationView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State var title: String = ""
    @State var altTitle: String = ""
    @State var composerName: String = ""
    @State var instrumentation: String = ""
    @State var url: String = ""
    let createdWork: (Work) -> Void
    
    var body: some View {
        Form {
            Section(header: Text("New work")) {
                TextField("Title", text: $title)
                TextField("Composer name", text: $composerName)
                TextField("Alternative title (optional)", text: $altTitle)
                TextField("Instrument(s) (comma separated, optional)", text: $instrumentation)
                TextField("URL (optional)", text: $url)
                    .keyboardType(.URL)
                    .textContentType(.URL)
            }
            Section {
                Button("Create and add to session") {
                    let newWork = Work(
                        id: UUID().uuidString,
                        title: title,
                        alternativeTitle: altTitle,
                        composerName: composerName,
                        composerId: composerName,
                        instrumentation: instrumentation.components(separatedBy: ",").map({$0.trimmingCharacters(in: .whitespacesAndNewlines)}),
                        isUserCreated: true,
                        userSuppliedURI: url
                    )
                    modelContext.insert(newWork)
                    createdWork(newWork)
                }
                .disabled(!isValidForm())
            }
        }
        .navigationBarTitle("New Work")
    }
    
    func isValidForm() -> Bool {
        return !title.isEmpty &&
        !composerName.isEmpty
        
    }
}

#Preview {
    NavigationStack {
        UserWorkCreationView(createdWork: {_ in })
            .modelContainer(PreviewExamples.previewContainer)
    }
}
