import SwiftUI

struct DynamicLongPressButton: View {
    @Binding var counter: Int
    let isIncrementing: Bool
    
    @State var timer: Timer?
    @State private var isPressing = false
    
    var body: some View {
        Image(systemName: isIncrementing ? "plus" : "minus")
            .scaleEffect(2.5)
            .padding(.leading, 5)
            .onTapGesture {
                addToCounter(1)
            }
            .onLongPressGesture(minimumDuration: 0.5) {
                print("Long pressed!")
                timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
                    addToCounter(10)
                })
            } onPressingChanged: { inProgress in
                print("In progress: \(inProgress)!")
                if !inProgress {
                    timer?.invalidate()
                }
            }
    }
    
    func addToCounter(_ amount: Int) {
        let newCount = counter + (isIncrementing ? amount : -amount)
        counter = min(max(newCount, 1), 200)
    }
}

struct MetronomeView: View {
    @StateObject var model = MetronomeModel(beatsPerMinute: 120, timeSignature: .fourFour)
    
    @State private var isTimeSignaturePickerPresented: Bool = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Spacer()
            
            /// First row
            HStack(alignment: .center, spacing: 25) {
                ForEach(0 ..< model.timeSignature.getBeatsPerMeasure(), id: \.self) { beatIndicatorIndex in
                    Button {
                        model.toggleBeatSoundAtIndex(beatIndicatorIndex)
                    } label: {
                        Circle()
                            .stroke(getBeatIndicatorFill(at: beatIndicatorIndex), lineWidth: 4)
                            .fill(getBeatIndicatorFill(at: beatIndicatorIndex))
                            .frame(width: 30, height: 30)
                            .shadow(color: getBeatIndicatorFill(at: beatIndicatorIndex).opacity(model.currentBeatIndex == beatIndicatorIndex ? 0.9 : 0.0), radius: 10)
                    }
                }
            }
            Spacer()
            
            /// Second row
            TextFieldStepper(
                doubleValue: $model.beatsPerMinute,
                //unit: "oz",
                label: "BPM",
                increment: 1.0,
                minimum: model.minBeatsPerMinute,
                maximum: model.maxBeatsPerMinute,
                decrementImage: TextFieldStepperImage(
                    systemName: "minus",
                    color: .black,
                    size: 35
                ),
                incrementImage: TextFieldStepperImage(
                    systemName: "plus",
                    color: .black,
                    size: 35
                ),
            ).padding()
            Spacer()
            
            /// Third row
            Button(action: {
                self.isTimeSignaturePickerPresented = true
            }) {
                TimeSignatureView(timeSignature: model.timeSignature, isSelected: false)
                    .padding()
            }
            .popover(isPresented: $isTimeSignaturePickerPresented) {
                TimeSignaturePicker(selectedTimeSignature: $model.timeSignature)
                   .padding()
                   .frame(minWidth: 100, maxHeight: 100)
                   .presentationCompactAdaptation(.popover)
                   .onChange(of: model.timeSignature) { isTimeSignaturePickerPresented = false }
            }
            .padding(.vertical, 30)
            
            /// Fourth row
            HStack(alignment: .center) {
                Button() {
                    if model.isRunning {
                        model.stopTimer()
                    } else {
                        model.startTimer()
                    }
                } label: {
                    Image(systemName: model.isRunning ? "stop.fill" : "play.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
        .onAppear {
            model.timeSignature = .fourFour
            model.beatsPerMinute = 120
        }
    }
    
    
    func getBeatIndicatorFill(at index: Int) -> Color {
        let beatSound = model.getBeatSoundAtIndex(index)
        switch beatSound {
        case .mute: return .gray
        case .defaultSound: return .blue
        case .accentedSound: return .red
        }
    }
}

#Preview {
    MetronomeView()
        .padding(50)
}
