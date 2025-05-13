import SwiftUI

struct MetronomeView: View {
    @StateObject private var model = MetronomeViewModel()
    
    private var minBeatsPerMinute: Int { model.minBeatsPerMinute }
    private var maxBeatsPerMinute: Int { model.maxBeatsPerMinute }
    
    @State private var lastTapTempoDate = Date.distantPast
    @State private var isTimeSignaturePickerPresented: Bool = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            /// First row
            HStack {
                ForEach(1 ..< model.beatsPerMeasure + 1, id: \.self) { beatIndicatorIndex in
                    Button {
                        model.toggleBeatSoundAtIndex(beatIndicatorIndex)
                    } label: {
                        Circle()
                            .stroke(getBeatIndicatorFill(at: beatIndicatorIndex), lineWidth: 4)
                            .fill(getBeatIndicatorFill(at: beatIndicatorIndex))
                            .frame(width: 20, height: 20)
                            .shadow(color: getBeatIndicatorFill(at: beatIndicatorIndex).opacity(model.beatIndex == beatIndicatorIndex ? 0.9 : 0.0), radius: 10)
                            .padding()
                    }
                }
            }
            /// Second row
            HStack(alignment: .center) {
                Spacer()
                Button() {
                    model.beatsPerMinute -= 1
                } label: {
                    Image(systemName: "minus")
                        .scaleEffect(2.5)
                        .padding(.leading, 5)
                }
                .simultaneousGesture(LongPressGesture().onEnded { _ in
                    model.beatsPerMinute -= 10
                })
                Spacer()
                
                HStack {
                    Text(model.timeSignature.rawValue.1 == 2 ? "" : "")
                        .font(.custom("Leland",size: 22))
                        .padding(.top, 10)
                    Text("= ")
                    Text("\(model.beatsPerMinute)")
                        .font(.largeTitle)
                    Text("bpm")
                        .font(.caption)
                }
                
                Spacer()
                Button() {
                    model.beatsPerMinute += 1
                } label: {
                    Image(systemName: "plus")
                        .scaleEffect(2.5)
                        .padding(.leading, 5)
                }
                .simultaneousGesture(LongPressGesture().onEnded { _ in
                    model.beatsPerMinute += 10
                })
                Spacer()
            }
            /// Third row
            HStack(alignment: .center) {
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
                Button() {
                    model.isRunning.toggle()
                } label: {
                    Image(systemName: model.isRunning ? "stop.fill" : "play.fill")
                        .scaleEffect(2.5)
                        .padding(15)
                }
                
                Button() {
                    model.soundEnabled.toggle()
                } label: {
                    Image(systemName: model.soundEnabled ? "speaker" : "speaker.slash")
                        .scaleEffect(2.5)
                        .padding(15)
                }
                
                Button(action: tapTempo) {
                    HStack {
                        Image(systemName: "hand.tap")
                    }
                    .padding(6)
                }
                .buttonStyle(.borderedProminent)
                .clipShape(.capsule)
            }
        }
        .onAppear {
            model.timeSignature = .fourFour
            model.beatsPerMinute = 60
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
    
    private func tapTempo() {
        let now = Date.now
        
        let tapInterval = now.timeIntervalSince(lastTapTempoDate)
        if tapInterval < 2.0 && tapInterval >= 0.2 {
            let newBeatsPerMinute = 60.0 / tapInterval
            model.beatsPerMinute = Int(newBeatsPerMinute.rounded())
        }
        
        lastTapTempoDate = now
    }
}

#Preview {
    MetronomeView()
        .padding(50)
}
