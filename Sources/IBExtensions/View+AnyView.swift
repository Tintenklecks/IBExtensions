import SwiftUI

public extension View {
    /// Returns self as AnyView
    func asAnyView() -> AnyView {
        AnyView(self)
    }
}
