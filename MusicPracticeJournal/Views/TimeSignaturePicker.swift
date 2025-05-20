import SwiftUI

struct TimeSignatureView: View {
    let timeSignature: TimeSignature
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text(timeSignature.getNumeratorRepresentation())
                .font(.custom("Leland",size: 26))
                .foregroundStyle(isSelected ? Color.red : Color.black)
                .padding(.vertical, -44)
            Text(timeSignature.getDenominatorRepresentation())
                .font(.custom("Leland",size: 26))
                .foregroundStyle(isSelected ? Color.red : Color.black)
                .padding(.vertical, -44)
        }
    }
}

struct TimeSignaturePicker: View {
    @Binding var selectedTimeSignature: TimeSignature
    
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                VStack(alignment: .leading) {
                    HStack {
                        ForEach(TimeSignature.allCases.filter({ $0.rawValue.1 == 2 }), id: \.self) { timeSignature in
                            Button {
                                selectedTimeSignature = timeSignature
                            } label: {
                                TimeSignatureView(
                                    timeSignature: timeSignature,
                                    isSelected: timeSignature == selectedTimeSignature
                                )
                            }
                        }
                    }
                }
            }
            ScrollView(.horizontal) {
                VStack(alignment: .leading) {
                    HStack {
                        ForEach(TimeSignature.allCases.filter({ $0.rawValue.1 == 4 }), id: \.self) { timeSignature in
                            Button {
                                selectedTimeSignature = timeSignature
                            } label: {
                                TimeSignatureView(
                                    timeSignature: timeSignature,
                                    isSelected: timeSignature == selectedTimeSignature
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}


#Preview("View") {
    TimeSignatureView(timeSignature: .fourFour, isSelected: false)
}

#Preview("Picker") {
    TimeSignaturePicker(selectedTimeSignature: .constant(.fourFour))
}
