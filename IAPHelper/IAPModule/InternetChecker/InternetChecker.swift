
import UIKit

class InternetChecker: NSObject {
    
    static let shared = InternetChecker()
    private var boolNetConnection: Bool = false
    let reachability = try! Reachability()
    
    private override init() {
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    func isInternetConnected() -> Bool {
        
        if reachability.connection == .unavailable {
            return false
        }
        return true
    }
}
