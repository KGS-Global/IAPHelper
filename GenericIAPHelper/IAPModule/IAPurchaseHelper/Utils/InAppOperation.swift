import Foundation


/// Subclass of `Operation` that adds support of synchronous operations.
/// 1. Call `super.main()` when override `main` method.
/// 2. When operation is finished or cancelled set `state = .finished` or `finish()`
///
/// Don't need to call super.main() if you're directly subclassing Operation. But if you subclass InAppOperation you have to call super

class InAppOperation: Operation {
    
    public override var isAsynchronous: Bool {
        return true
    }
    
    public override var isExecuting: Bool {
        return state == .executing
    }
    
    public override var isFinished: Bool {
        return state == .finished
    }
    
    public override func start() {
        if self.isCancelled {
            state = .finished
            return
        } else {
            state = .executing
            self.execute()
        }
    }
    
    func execute() {
        //override this method
        self.finish()
    }
    // override this main() method in subclass for operation implementation
//    open override func main() {
//        if self.isCancelled {
//            state = .finished
//        } else {
//            state = .executing
//        }
//    }
    
    public func finish() {
        state = .finished
    }

    public enum State: String {
        case ready = "Ready"
        case executing = "Executing"
        case finished = "Finished"
        fileprivate var keyPath: String { return "is" + self.rawValue }
    }
    
    public var state: State {
        get {
            stateQueue.sync {
                return stateStore
            }
        }
        set {
            let oldValue = state
            willChangeValue(forKey: state.keyPath)
            willChangeValue(forKey: newValue.keyPath)
            stateQueue.sync(flags: .barrier){
                stateStore = newValue
            }
            didChangeValue(forKey: state.keyPath)
            didChangeValue(forKey: oldValue.keyPath)
        }
    }
    private let stateQueue = DispatchQueue(label: "In App SyncOperation ")
    private var stateStore: State = .ready
}
