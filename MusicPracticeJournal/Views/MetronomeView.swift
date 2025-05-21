import SwiftUI

struct TempoMarkings {
    enum TempoMarkingType: String, CaseIterable {
        case larghissimo = "Larghissimo"
        case grave = "Grave"
        case lento = "Lento"
        case largo = "Largo"
        case larghetto = "Larghetto"
        case adagio = "Adagio"
        case adagietto = "Adagietto"
        case andanteModerato = "Andante Moderato"
        case andante = "Andante"
        case andantino = "Andantino"
        case marciaModerata = "Marcia Moderata"
        case moderato = "Moderato"
        case allegretto = "Allegretto"
        case allegro = "Allegro"
        case vivace = "Vivace"
        case vivacissimo = "Vivacissimo"
        case allegrissimo = "Allegriissimo"
        case presto = "Presto"
        case prestissimo = "Prestissimo"
    }
    
    static let tempoToBPMRange: [TempoMarkingType: ClosedRange<Int>] = [
        .larghissimo: 1...19,
        .grave: 20...39,
        .lento: 40...44,
        .largo: 45...49,
        .larghetto: 50...54,
        .adagio: 55...64,
        .adagietto: 65...68,
        .andanteModerato: 69...72,
        .andante: 73...77,
        .andantino: 78...82,
        .marciaModerata: 83...85,
        .moderato: 86...97,
        .allegretto: 98...109,
        .allegro: 110...131,
        .vivace: 132...139,
        .vivacissimo: 140...149,
        .allegrissimo: 150...167,
        .presto: 168...177,
        .prestissimo: 178...400
    ]
    
    static func classifyBPM(_ bpm: Int) -> TempoMarkingType? {
        for (type, range) in tempoToBPMRange {
            if range.contains(bpm) {
                return type
            }
        }
        return nil
    }
}

struct MetronomeView: View {
    @StateObject var model = MetronomeModel(beatsPerMinute: 120, beatsPerMeasure: 4)
    
    @State var tempoMarking: TempoMarkings.TempoMarkingType = .adagio
    
    @State var presentTempoPicker: Bool = false
    
    func median(of range: ClosedRange<Int>) -> Double {
        let count = range.count
        if count == 0 {
            return Double.nan // Handle empty range, return Not a Number
        } else {
            // Convert range to an array to easily calculate the median.
            let values = Array(range)
            
            if count % 2 == 0 {
                // Even number of elements: average of the two middle elements.
                let middle1 = values[count / 2 - 1]
                let middle2 = values[count / 2]
                return Double((middle1 + middle2)) / 2.0
            } else {
                // Odd number of elements: the middle element.
                return Double(values[count / 2])
            }
        }
    }
    
    func getBeatIndicatorsRow(start: Int, end: Int) -> some View {
        return HStack(alignment: .center, spacing: 20) {
            withAnimation(.easeInOut(duration: 1)) {
                ForEach(start ... end, id: \.self) { beatIndicatorIndex in
                    Button {
                        model.toggleBeatSoundAtIndex(beatIndicatorIndex)
                    } label: {
                        Circle()
                            .stroke(getBeatIndicatorFill(at: beatIndicatorIndex), lineWidth: 4)
                            .fill(getBeatIndicatorFill(at: beatIndicatorIndex))
                            .frame(width: 30, height: 30)
                            .shadow(color: getBeatIndicatorFill(at: beatIndicatorIndex).opacity(model.currentBeatIndex == beatIndicatorIndex ? 0.9 : 0.0), radius: 10)
                           
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Spacer()
            HStack {
                Button {
                    model.beatsPerMeasure -= 1
                } label: {
                    Image(systemName: "minus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                }
                .disabled(model.beatsPerMeasure == model.minBeatsPerMeasure)
                .padding()
                .buttonStyle(.plain)
                Spacer()
                VStack(spacing: 20) {
                    /// first row
                    getBeatIndicatorsRow(
                        start: 0,
                        end: min(model.beatsPerMeasure - 1, 4)
                    )
                    // second row
                    if model.beatsPerMeasure > 5 {
                        getBeatIndicatorsRow(
                            start: 5,
                            end: min(model.beatsPerMeasure - 1, 9)
                        )
                    }
                    // third row
                    if model.beatsPerMeasure > 10 {
                        getBeatIndicatorsRow(
                            start: 10,
                            end: min(model.beatsPerMeasure - 1, model.maxBeatsPerMeasure - 1)
                        )
                    }
                }
                .padding(.vertical, 40)
                Spacer()
                Button {
                    model.beatsPerMeasure += 1
                } label: {
                    Image(systemName: "plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                }
                .disabled(model.beatsPerMeasure == model.maxBeatsPerMeasure)
                .padding()
                .buttonStyle(.plain)
            }
            .background(Color.gray.opacity(0.15))
            .cornerRadius(15)
            .padding(.vertical, 40)
            
            VStack(alignment: .center) {
                Button {
                    presentTempoPicker.toggle()
                } label: {
                    Text(tempoMarking.rawValue)
                        .font(.caption)
                        .italic()
                        .padding(.top, 20)
                        .onChange(of: model.beatsPerMinute) {
                            if let newTempoMarking = TempoMarkings.classifyBPM(Int(model.beatsPerMinute.rounded())) {
                                self.tempoMarking = newTempoMarking
                            }
                        }
                }
                if presentTempoPicker {
                    Picker(selection: $tempoMarking) {
                        ForEach(TempoMarkings.TempoMarkingType.allCases, id: \.rawValue) { tempoMarking in
                            let tempoRange = TempoMarkings.tempoToBPMRange[tempoMarking]
                            let lowerBound = tempoRange?.lowerBound ?? 0
                            let upperBound = tempoRange?.upperBound ?? 0
                            Text("\(tempoMarking.rawValue) (\(lowerBound) - \(upperBound))")
                                .font(.caption)
                                .italic()
                                .tag(tempoMarking)
                        }
                    } label: {
                        Text(tempoMarking.rawValue)
                            .font(.caption)
                            .italic()
                            .padding(.top, 20)
                    }
                    .onChange(of: tempoMarking) {
                        let tempoRange = TempoMarkings.tempoToBPMRange[tempoMarking]
                        if let tempoRange = tempoRange {
                            model.beatsPerMinute = median(of: tempoRange).rounded()
                        }
                    }
                    .pickerStyle(.wheel)
                }
                TextFieldStepper(
                    doubleValue: $model.beatsPerMinute,
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
                )
                .padding(.top, 0)
                .padding(.bottom, 20)
                .padding(.horizontal, 20)
            }
            .background(Color.gray.opacity(0.15))
            .cornerRadius(15)
            Spacer()
            Divider()
            Spacer()
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
            model.beatsPerMeasure = 4
            model.beatsPerMinute = 120
            tempoMarking = .allegro
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
        .padding(30)
}
