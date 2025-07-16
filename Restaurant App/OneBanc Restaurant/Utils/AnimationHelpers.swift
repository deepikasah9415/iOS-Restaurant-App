import SwiftUI

// Custom transitions for views
struct SlideTransition: ViewModifier {
    let direction: SlideDirection
    let animation: Animation
    
    enum SlideDirection {
        case left, right, up, down
        
        var offset: (CGFloat, CGFloat) {
            switch self {
            case .left: return (-200, 0)
            case .right: return (200, 0)
            case .up: return (0, -200)
            case .down: return (0, 200)
            }
        }
    }
    
    func body(content: Content) -> some View {
        content
            .transition(
                .asymmetric(
                    insertion: .offset(x: direction.offset.0, y: direction.offset.1),
                    removal: .offset(x: -direction.offset.0, y: -direction.offset.1)
                )
                .combined(with: .opacity)
            )
            .animation(animation, value: true)
    }
}

// Animations for user interactions
struct PressActions: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in onPress() }
                    .onEnded { _ in onRelease() }
            )
    }
}

// Add convenience extensions
extension View {
    func slideTransition(direction: SlideTransition.SlideDirection, animation: Animation = .spring()) -> some View {
        modifier(SlideTransition(direction: direction, animation: animation))
    }
    
    func pressAction(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        modifier(PressActions(onPress: onPress, onRelease: onRelease))
    }
    
    func onTapWithAnimation(action: @escaping () -> Void) -> some View {
        self.modifier(TapAnimationModifier(action: action))
    }
}

// Tap animation for buttons
struct TapAnimationModifier: ViewModifier {
    let action: () -> Void
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            .pressAction(
                onPress: { self.isPressed = true },
                onRelease: {
                    self.isPressed = false
                    action()
                }
            )
    }
}