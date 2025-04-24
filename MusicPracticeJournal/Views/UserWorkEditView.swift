import SwiftUI
import SwiftData

struct UserWorkEditView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State var work: Work
    @State var title: String
    @State var altTitle: String
    @State var composerName: String
    @State var instrumentation: String
    @State var userSuppliedURI: String
    
    init(work: Work) {
        self.work = work
        self.title = work.title
        self.altTitle = work.alternativeTitle ?? ""
        self.composerName = work.composerName ?? ""
        self.instrumentation = work.instrumentation.joined(separator: ", ")
        self.userSuppliedURI = work.userSuppliedURI  ?? ""
    }
    
    var body: some View {
        Form {
            Section(header: Text("Edit work")) {
                TextField("Title", text: $title)
                TextField("Composer name", text: $composerName)
                TextField("Alternative title (optional)", text: $altTitle)
                TextField("Instrument(s) (comma separated, optional)", text: $instrumentation)
                TextField("URL (optional)", text: $userSuppliedURI)
                    .keyboardType(.URL)
                    .textContentType(.URL)
            }
            Section {
                Button("Update") {
                    work.title = title
                    work.alternativeTitle = altTitle.isEmpty ? nil : altTitle
                    work.composerName = composerName
                    work.instrumentation = instrumentation.components(separatedBy: ",").map({$0.trimmingCharacters(in: .whitespacesAndNewlines)})
                    work.userSuppliedURI = (userSuppliedURI.isEmpty ? nil : userSuppliedURI)
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
        .navigationBarTitle("Edit Work")
    }
    
    func isUnchanged() -> Bool {
        return work.title == title &&
            work.alternativeTitle == (altTitle.isEmpty ? nil : altTitle) &&
            work.composerName == composerName &&
            work.instrumentation.joined(separator: ", ") == instrumentation &&
            work.userSuppliedURI == (userSuppliedURI.isEmpty ? nil : userSuppliedURI)
    }
}

#Preview {
    NavigationStack {
        UserWorkEditView(work: PreviewExamples.getSingleWork())
            .modelContainer(PreviewExamples.previewContainer)
    }
}
