import SwiftUI

public struct TextFieldStepper: View {
    @Binding var doubleValue: Double
    
    @FocusState private var keyboardOpened
    
    @State private var confirmEdit = false
    @State private var textValue = ""
    @State private var showAlert = false
    @State private var cancelled = false
    @State private var confirmed = false
    @State private var defaultValue: Double = 0.0
    
    // Alert
    @State private var alertTitle = ""
    @State private var alertMessage = ""

    @State private var lastTapTempoDate = Date.distantPast
    
    private let config: TextFieldStepperConfig
    
    private var cancelButton: some View {
        Button(action: {
            textValue = formatTextValue(doubleValue)
            cancelled = true
            keyboardOpened = false
        }) {
            config.declineImage
        }
        .foregroundColor(config.declineImage.color)
    }
    
    private var confirmButton: some View {
        Button(action: {
            confirmed = true
            validateValue()
        }) {
            config.confirmImage
        }
        .foregroundColor(config.confirmImage.color)
    }
    
    private var fastDecrementButton: some View {
        LongPressButton(
            doubleValue: $doubleValue,
            config: config,
            image: TextFieldStepperImage(
                image: Image(systemName: "10.arrow.trianglehead.counterclockwise"),
                color: config.incrementImage.color.opacity(0.7),
                size: 35
            ),
            action: .decrement,
            valueMultiplier: 10
        )
    }
    
    private var fastIncrementButton: some View {
        LongPressButton(
            doubleValue: $doubleValue,
            config: config,
            image: TextFieldStepperImage(
                image: Image(systemName: "10.arrow.trianglehead.clockwise"),
                color: config.incrementImage.color.opacity(0.7),
                size: 35
            ),
            action: .increment,
            valueMultiplier: 10
        )
    }
    
    private var decrementButton: some View {
        LongPressButton(
            doubleValue: $doubleValue,
            config: config,
            image: config.decrementImage,
            action: .decrement
        )
    }
    
    private var incrementButton: some View {
        LongPressButton(
            doubleValue: $doubleValue,
            config: config,
            image: config.incrementImage,
            action: .increment
        )
    }
    
    /**
     * init(doubleValue: Binding<Double>, unit: String, label: String, config: TextFieldStepperConfig)
     */
    public init(
        doubleValue: Binding<Double>,
        unit: String? = nil,
        label: String? = nil,
        increment: Double? = nil,
        minimum: Double? = nil,
        maximum: Double? = nil,
        decrementImage: TextFieldStepperImage? = nil,
        incrementImage: TextFieldStepperImage? = nil,
        declineImage: TextFieldStepperImage? = nil,
        confirmImage: TextFieldStepperImage? = nil,
        disabledColor: Color? = nil,
        labelOpacity: Double? = nil,
        labelColor: Color? = nil,
        valueColor: Color? = nil,
        shouldShowAlert: Bool? = nil,
        minimumDecimalPlaces: Int? = nil,
        maximumDecimalPlaces: Int? = nil,
        config: TextFieldStepperConfig = TextFieldStepperConfig()
    ) {
        // Compose config
        var config = config
        config.unit = unit ?? config.unit
        config.label = label ?? config.label
        config.increment = increment ?? config.increment
        config.minimum = minimum ?? config.minimum
        config.maximum = maximum ?? config.maximum
        config.decrementImage = decrementImage ?? config.decrementImage
        config.incrementImage = incrementImage ?? config.incrementImage
        config.declineImage = declineImage ?? config.declineImage
        config.confirmImage = confirmImage ?? config.confirmImage
        config.disabledColor = disabledColor ?? config.disabledColor
        config.labelOpacity = labelOpacity ?? config.labelOpacity
        config.labelColor = labelColor ?? config.labelColor
        config.valueColor = valueColor ?? config.valueColor
        config.shouldShowAlert = shouldShowAlert ?? config.shouldShowAlert
        config.minimumDecimalPlaces = minimumDecimalPlaces ?? config.minimumDecimalPlaces
        config.maximumDecimalPlaces = maximumDecimalPlaces ?? config.maximumDecimalPlaces
        
        // Assign properties
        self._doubleValue = doubleValue
        self.config = config
        
        // Set text value with State
        _textValue = State(initialValue: formatTextValue(doubleValue.wrappedValue))
        _defaultValue = State(initialValue: doubleValue.wrappedValue)
    }
    
    public var body: some View {
        VStack {
            HStack(alignment: .center) {
                ZStack {
                    decrementButton.opacity(keyboardOpened ? 0 : 1)
                    
                    if keyboardOpened {
                        cancelButton
                    }
                }
                
                VStack(spacing: 0) {
                    TextField("", text: $textValue)
                        .focused($keyboardOpened)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 50, weight: .medium))
                        .keyboardType(.decimalPad)
                        .foregroundColor(config.valueColor)
                        .monospacedDigit()
                    
                    if !config.label.isEmpty {
                        Text(config.label)
                            .font(.footnote)
                            .fontWeight(.light)
                            .foregroundColor(config.labelColor)
                            .opacity(config.labelOpacity)
                    }
                }
                
                // Right button
                ZStack {
                    incrementButton.opacity(keyboardOpened ? 0 : 1)
                    
                    if keyboardOpened {
                        confirmButton
                    }
                }
            }
            .onChange(of: keyboardOpened) {
                if keyboardOpened {
                    textValue = textValue.replacingOccurrences(of: config.unit, with: "")
                } else {
                    if !confirmed {
                        validateValue()
                    } else {
                        confirmed = false
                    }
                }
            }
            .onChange(of: doubleValue) {
                textValue = formatTextValue(doubleValue)
            }
            .alert(
                alertTitle,
                isPresented: $showAlert,
                actions: {},
                message: {
                    Text(alertMessage)
                }
            )
            HStack(alignment: .center) {
                fastDecrementButton
                Spacer()
                Button(action: tapTempo) {
                    HStack {
                        Image(systemName: "hand.tap")
                            .frame(width: 30, height: 30)
                    }
                    .padding(6)
                }
                .buttonStyle(.plain)
                Spacer()
                fastIncrementButton
            }
        }
    }
    
    private func tapTempo() {
        let now = Date.now
        
        let tapInterval = now.timeIntervalSince(lastTapTempoDate)
        if tapInterval < 2.0 && tapInterval >= 0.2 {
            let newBeatsPerMinute = 60.0 / tapInterval
            doubleValue = newBeatsPerMinute.rounded()
        }
        
        lastTapTempoDate = now
    }
    
    private func formatTextValue(_ value: Double) -> String {
        var stringValue = String(format: "%g", value.decimal)
        
        let formatter = NumberFormatter()
            formatter.minimumFractionDigits = config.minimumDecimalPlaces < 0 ? 0 : config.minimumDecimalPlaces
            formatter.maximumFractionDigits = config.maximumDecimalPlaces > 8 ? 8 : config.maximumDecimalPlaces
            formatter.roundingMode = .down
        
        // Format according to config otherwise fallback to old formatting
        if let formattedValue = formatter.string(for: value.decimal) {
            stringValue = formattedValue
        }
        
        return stringValue + config.unit
    }
    
    private func validateValue() {
        // Value for non confirm button taps
        var value = defaultValue
        
        // Reset alert status
        showAlert = false
        
        var shouldShowAlert = false
        
        // Confirm doubleValue is actually a Double
        if let textToDouble = Double(textValue) {
            // 4. If doubleValue is less than config.minimum, throw Alert
            // 5. If doubleValue is greater than config.maximum, throw Alert
            if textToDouble.decimal < config.minimum {
                alertTitle = config.label
                alertMessage = "Must be at least \(formatTextValue(config.minimum))."
                shouldShowAlert = true
                value = config.minimum
            }
            
            if textToDouble.decimal > config.maximum {
                alertTitle = config.label
                alertMessage = "Must be at most \(formatTextValue(config.maximum))."
                shouldShowAlert = true
                value = config.maximum
            }
            
            // All checks passed, set the double value.
            if !shouldShowAlert {
                doubleValue = textToDouble
                keyboardOpened = false
                
                // If doubleValue is unchanged, ensure the textValue is still formatted
                textValue = formatTextValue(textToDouble)
            }
        } else {
            // 2. If more than one decimal, throw Alert
            // 3. If contains characters, throw Alert (hardware keyboard issue)
            // 6. If doubleValue is empty, throw Alert
            alertTitle = config.label
            alertMessage = "Must contain a valid number."
            shouldShowAlert = true
        }
        
        if shouldShowAlert && confirmed {
            showAlert = true
        }
        
        if shouldShowAlert && !confirmed {
            doubleValue = value
            textValue = formatTextValue(value)
            
            if config.shouldShowAlert {
                showAlert = true
            }
        }
    }
}
