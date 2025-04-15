
import SwiftUI

struct PracticeSessionEditableNameView: View {
    @State var isEditingName: Bool = false
    @State var name: String
    let changeName: (String) -> Void
    @FocusState private var isFocused: Bool
    
    var body: some View {
        if (isEditingName) {
            HStack(alignment: .center) {
                TextField(
                    "Practice session name",
                    text: $name
                ).onChange(of: name) {
                    changeName(name)
                }.onSubmit {
                    isEditingName = false;
                }
                .focused($isFocused)
                .onChange(of: isFocused) {
                    if (!isFocused) {
                        isEditingName = false;
                    }
                }
            }
        } else {
            Button() {
                isEditingName = true
            } label: {
                Text(name)
            }.buttonStyle(PlainButtonStyle())
        }
    }
}

#Preview {
    PracticeSessionEditableNameView(name: "My Awesome Practice Session", changeName: {_ in })
}
