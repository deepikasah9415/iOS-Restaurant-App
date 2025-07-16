import SwiftUI

struct SkeletonView: View {
    var isLoading: Bool
    var content: AnyView
    var placeholder: AnyView
    
    init<Content: View, Placeholder: View>(
        isLoading: Bool,
        @ViewBuilder content: () -> Content,
        @ViewBuilder placeholder: () -> Placeholder
    ) {
        self.isLoading = isLoading
        self.content = AnyView(content())
        self.placeholder = AnyView(placeholder())
    }
    
    var body: some View {
        if isLoading {
            placeholder
        } else {
            content
        }
    }
}

// Skeleton modifier for rectangle shapes
struct SkeletonModifier: ViewModifier {
    var isLoading: Bool
    
    func body(content: Content) -> some View {
        content
            .opacity(isLoading ? 0 : 1)
            .overlay(
                ZStack {
                    if isLoading {
                        SkeletonRectangle()
                    }
                }
            )
    }
}

// Skeleton animation
struct SkeletonRectangle: View {
    @State private var startPoint: UnitPoint = .leading
    @State private var endPoint: UnitPoint = .trailing
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.gray.opacity(0.1),
                Color.gray.opacity(0.2),
                Color.gray.opacity(0.1)
            ]),
            startPoint: startPoint,
            endPoint: endPoint
        )
        .onAppear {
            withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                startPoint = .trailing
                endPoint = .leading
            }
        }
    }
}

// Round skeleton for profile pics or circles
struct SkeletonCircle: View {
    var size: CGFloat
    
    var body: some View {
        Circle()
            .fill(Color.gray.opacity(0.2))
            .frame(width: size, height: size)
            .overlay(
                SkeletonRectangle()
                    .mask(Circle())
            )
    }
}

// Rectangle skeleton with rounded corners
struct SkeletonRoundedRectangle: View {
    var width: CGFloat
    var height: CGFloat
    var cornerRadius: CGFloat
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.gray.opacity(0.2))
            .frame(width: width, height: height)
            .overlay(
                SkeletonRectangle()
                    .mask(RoundedRectangle(cornerRadius: cornerRadius))
            )
    }
}

// Text skeleton line
struct SkeletonLine: View {
    var width: CGFloat
    var height: CGFloat = 20
    
    var body: some View {
        RoundedRectangle(cornerRadius: height / 2)
            .fill(Color.gray.opacity(0.2))
            .frame(width: width, height: height)
            .overlay(
                SkeletonRectangle()
                    .mask(RoundedRectangle(cornerRadius: height / 2))
            )
    }
}

// Extension to apply skeleton style to any view
extension View {
    func skeleton(isLoading: Bool) -> some View {
        modifier(SkeletonModifier(isLoading: isLoading))
    }
}
