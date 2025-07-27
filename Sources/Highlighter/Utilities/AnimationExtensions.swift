import SwiftUI

extension View {
    func onAnimationCompleted<Value: VectorArithmetic>(for value: Value, completion: @escaping () -> Void) -> some View {
        modifier(AnimationCompletionObserver(observedValue: value, completion: completion)
    }
}

struct AnimationCompletionObserver<Value: VectorArithmetic>: AnimatableModifier {
    var animatableData: Value {
        didSet {
            completion()
        }
    }
    
    private let completion: () -> Void
    private let observedValue: Value
    
    init(observedValue: Value, completion: @escaping () -> Void) {
        self.completion = completion
        self.observedValue = observedValue
        self.animatableData = observedValue
    }
    
    func body(content: Content) -> some View {
        content
    }
}