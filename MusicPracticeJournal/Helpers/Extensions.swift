import Foundation

extension ProcessInfo {
    var isSwiftUIPreview: Bool {
        environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}

extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
    }
}

extension Array {
    public subscript(index: Int, default defaultValue: @autoclosure () -> Element) -> Element {
        guard index >= 0, index < endIndex else {
            return defaultValue()
        }

        return self[index]
    }
}

func formatSecondsToMinutesSeconds(seconds: Double) -> String {
    // Ensure the input is non-negative
    let nonNegativeSeconds = max(0, seconds)

    // Calculate minutes and remaining seconds
    let totalSecondsInt = Int(nonNegativeSeconds)
    let minutes = totalSecondsInt / 60
    let remainingSeconds = totalSecondsInt % 60

    // Use String(format:) to ensure zero padding for both minutes and seconds
    // %02d formats an integer with at least two digits, padding with leading zeros if necessary.
    let formattedString = String(format: "%02d:%02d", minutes, remainingSeconds)

    return formattedString
}


/**
 Formats a Date into a string representation that varies based on how recent the date is.

 - If today: "h:mm a" (e.g., "3:30 PM")
 - If yesterday: "Yesterday at h:mm a" (e.g., "Yesterday at 9:15 AM")
 - If within the last 7 days (but not today or yesterday): "EEEE at h:mm a" (e.g., "Monday at 10:00 AM")
 - If longer than 7 days ago: "MMM d, yyyy" (e.g., "Jan 15, 2023")

 - Parameter date: The Date object to format.
 - Returns: A formatted String representing the date and time based on its recency.
 */
func formatRelativeDate(_ date: Date) -> String {
    let calendar = Calendar.current
    let now = Date()

    // Define formatters for different styles
    let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a" // 12-hour time with AM/PM
        // Optional: Explicitly set AM/PM symbols if needed, relies on locale by default
        // formatter.amSymbol = "AM"
        // formatter.pmSymbol = "PM"
        return formatter
    }()

    let dateFormatterFull: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy" // e.g., "Jan 15, 2023"
        return formatter
    }()

    let dayOfWeekFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE" // Full weekday name, e.g., "Monday"
        return formatter
    }()

    // --- Check conditions in order ---

    // 1. Is it today?
    if calendar.isDate(date, inSameDayAs: now) {
        return timeFormatter.string(from: date)
    }

    // 2. Is it yesterday?
    // Get the date for yesterday by subtracting one day from the current date
    if let yesterday = calendar.date(byAdding: .day, value: -1, to: now) {
        if calendar.isDate(date, inSameDayAs: yesterday) {
            return "Yesterday at \(timeFormatter.string(from: date))"
        }
    }

    // 3. Is it within the last 7 days (and not today or yesterday)?
    // Compare the start of the day for precise day difference
    let startOfToday = calendar.startOfDay(for: now)
    let startOfInputDate = calendar.startOfDay(for: date)

    // Calculate the difference in days
    if let components = calendar.dateComponents([.day], from: startOfInputDate, to: startOfToday).day {
        // components > 1 means it's not today or yesterday (difference of 0 or 1)
        // components <= 7 means it's within the last 7 days total
        if components > 1 && components <= 7 {
            return "\(dayOfWeekFormatter.string(from: date)) at \(timeFormatter.string(from: date))"
        }
    }

    // 4. If none of the above, format as "MMM d, yyyy"
    return dateFormatterFull.string(from: date)
}
