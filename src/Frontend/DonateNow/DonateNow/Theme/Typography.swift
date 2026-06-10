import SwiftUI

extension View {
    func pageTitleStyle() -> some View {
        self.font(.largeTitle).bold()
    }
    
    func sectionHeaderStyle() -> some View {
        self.font(.title2).fontWeight(.semibold)
    }
    
    func bodyTextStyle() -> some View {
        self.font(.body)
    }
    
    func formLabelStyle() -> some View {
        self.font(.subheadline).fontWeight(.medium)
    }
    
    func captionTextStyle() -> some View {
        self.font(.caption)
    }
    
    func buttonTextStyle() -> some View {
        self.font(.headline).fontWeight(.semibold)
    }
}

// Custom Semibold extension since it is not built-in on Font before iOS 16
extension Font {
    static func semibold(_ size: CGFloat) -> Font {
        .system(size: size, weight: .semibold)
    }
}
