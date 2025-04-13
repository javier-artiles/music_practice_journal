import SwiftUI

struct SubItemEditableNameView: View {
    @State var isEditingName: Bool = true
    @State var subItemName: String
    let changeName: (String) -> Void
    @FocusState private var isFocused: Bool
    
    var body: some View {
        if (isEditingName) {
            TextField(
                "Practice sub-item name",
                text: $subItemName
            ).onChange(of: subItemName) {
                changeName(subItemName)
            }.onSubmit {
                isEditingName = false;
            }
            .focused($isFocused)
            .onChange(of: isFocused) {
                if (!isFocused) {
                    isEditingName = false;
                }
            }
        } else {
            Button() {
                isEditingName = true
            } label: {
                Text(subItemName)
            }.buttonStyle(PlainButtonStyle())
        }
    }
}

#Preview {
    let subItem = PreviewExamples.getPracticeSubItem()
    SubItemEditableNameView(subItemName: subItem.name ?? "", changeName: { newName in subItem.name = newName})
}
