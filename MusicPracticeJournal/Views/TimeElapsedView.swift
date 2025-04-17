import SwiftUI

struct TimeElapsedView: View {
    let timeElapsedInSeconds: Int
    
    var body: some View {
        Text(String(format: "%01d:%02d",
                    timeElapsedInSeconds / 60,
                    timeElapsedInSeconds % 60)
        )
    }
}

#Preview {
    TimeElapsedView(timeElapsedInSeconds: 120)
}
