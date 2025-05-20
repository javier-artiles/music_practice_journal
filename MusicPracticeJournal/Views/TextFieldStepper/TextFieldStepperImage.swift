import SwiftUI

public struct TextFieldStepperImage: View {
    let image: Image
    let color: Color
    let size: CGFloat

    public init(image: Image, color: Color = Color.accentColor, size: CGFloat = 35) {
        self.image = image
        self.color = color
        self.size = size
    }
    
    public init(systemName: String, color: Color = Color.accentColor, size: CGFloat = 35) {
        self.init(image: Image(systemName: systemName), color: color, size: size)
    }
    
    public var body: some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
    }
}
