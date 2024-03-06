
import Foundation
import StoreKit

internal typealias FetchProductCompleted = ([InAppProduct]?) -> Void

class IAPurchaseHelper: NSObject {
    
    @objc static public let shared = IAPurchaseHelper()
    
    private let simulatedStartDate: Date
    internal var savedInAppSession: InAppSession?
    private var sharedEncryptedKey: String?
    private var paymentTrnxObserver: PaymentTrnxObserver = PaymentTrnxObserver()

    internal var currentSubscription: SubscriptionProductInfo?
    private var arrayOfIAProducts: [InAppProduct]?
    private var arrIAPIdentifiers: [ProductIdInfo]?
    internal var isPurchaseRequested: Bool = false
    
    internal static let restoreSuccessfulNotification = Notification.Name("SubscriptionServiceRestoreSuccessfulNotification")
    internal static let restoreFailureNotification = Notification.Name("SubscriptionServiceRestoreFailureNotification")
    internal static let purchaseSuccessfulNotification = Notification.Name("SubscriptionServicePurchaseSuccessfulNotification")
    internal static let purchaseFailureNotification = Notification.Name("SubscriptionServicePurchaseFailureNotification")
    internal static let purchaseCancelledNotification = Notification.Name("SubscriptionServicePurchaseCancelledNotification")
    internal static let duplicatePurchasedNotification = Notification.Name("SubscriptionDuplicatePurchasedNotification")
    internal static let promotionPurchaseStartNotification = Notification.Name("PromotionPurchaseStartNotification")
    
    internal lazy var StoreQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
//    TODO:: Have to Implement
//    private var hasReceiptData: Bool {
//        return loadReceipt() != nil
//    }
    
    private var currentSessionStatus: IAReceiptStatus {
        
        guard let session = savedInAppSession else {
            return .Inactive
        }
        let sessionStatus = session.getReceiptStatus()
        return sessionStatus
    }
    
    private lazy var operationStoreQueue: OperationQueue = {
        let storeQueue = OperationQueue()
        storeQueue.maxConcurrentOperationCount = 1
        return storeQueue
    }()
    
    private override init() {
        let persistedDateKey = "SimulatedStartDate"
        if let persistedDate = UserDefaults.standard.object(forKey: persistedDateKey) as? Date {
            simulatedStartDate = persistedDate
        } else {
            let date = Date().addingTimeInterval(-30) // 30 second difference to account for server/client drift.
            UserDefaults.standard.set(date, forKey: "SimulatedStartDate")
            simulatedStartDate = date
        }
    }
    
}

extension IAPurchaseHelper {
    
    @objc public func startTransactionObserver(sharedSecrate: String) {
        
        self.sharedEncryptedKey = sharedSecrate
        paymentTrnxObserver.addPaymentObserver()
        IAPLog.event("Event: Transaction Observer started")
    }
    
    @objc public func stopTransactionObserver(){
        paymentTrnxObserver.removePaymentObserver()
        IAPLog.event("Event: Transaction Observer removed")
    }
}

//ALL Get-Set Method
extension IAPurchaseHelper {
    
    @objc public func getSharedKey() -> String {
        
        guard let sharedKey = sharedEncryptedKey else {
            IAPLog.event("Event: SharedSecret Not Found")
            return ""
        }
        return sharedKey
    }
    
    @objc public func getProductIdInfo(_ strID:String) -> ProductIdInfo? {
        
        if self.arrIAPIdentifiers != nil {
            
            for iAProductID in self.arrIAPIdentifiers! {
                
                if strID == iAProductID.getProductID() {
                    return iAProductID
                }
            }
        }
        return nil
    }
    
    @objc public func getInAppProduct(for productID: String) -> InAppProduct? {
        
        let first = self.arrayOfIAProducts?.first(where: { (item: InAppProduct) -> Bool in
            return item.skProduct.productIdentifier == productID
        })
        return first
    }
    
    @objc public func getArrayOfIAProducts() -> [InAppProduct]? {
        return self.arrayOfIAProducts
    }
    
    @objc public func setArrayOf( iAProducts: [InAppProduct]?) {
        self.arrayOfIAProducts = iAProducts
    }
    
    @objc public func setArrayOf( productIDs: [ProductIdInfo]?) {
        self.arrIAPIdentifiers = productIDs
    }
    
    @objc public func getCurrentSubscriptionStatus() -> Bool {
        return currentSubscription?.getSubscriptionStatus() ?? false
    }
    
    @objc public func getCurrentSubscriptionProductID() -> String? {
        return currentSubscription?.productIdentifier
    }
    @objc public func isSubscriptionTrialPeriodOngoing() -> Bool {
        return currentSubscription?.getTrialPeriodState() ?? false
    }
    @objc public func hasPurchasesHistory() -> Bool {
        return currentSubscription == nil ? false : true
    }
}
