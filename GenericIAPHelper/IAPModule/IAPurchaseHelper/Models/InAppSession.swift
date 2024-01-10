
import Foundation

public enum IAReceiptStatus: Int{
    
    case Active = 0
    case BadJson = 21000
    case ServiceUnavailable = 21005
    case Inactive = 21006
    
    public func toString() -> String {
        
        switch self {
        case .Active:
            return "Active"
            
        case .BadJson:
            return "BadJson"
            
        case .ServiceUnavailable:
            return "ServiceUnavailable"
            
        case .Inactive:
            return "Inactive"
        }
    }
}

@objc class InAppSession: CodableObject {
    
    @objc var receiptData: Data?
    var parsedReceipt: [String: Any]?
    
    private var sessionID: String?
    private var allPaidSubscriptions: [SubscriptionProductInfo]?
    private var allPaidSubscriptionsByGroup: [String:[SubscriptionProductInfo]]?
    private var allPaidNonConsumables: [NonConsumableProductInfo]?
    
    var currentSubscription: SubscriptionProductInfo? {
        let sortedByMostRecentPurchase = allPaidSubscriptions?.sorted { $0.purchasedDate > $1.purchasedDate }
        return sortedByMostRecentPurchase?.first
    }
    
    private var subscriptionsByGroup: [String:[SubscriptionProductInfo]]? {
        
        guard let paidSubscriptions = allPaidSubscriptions else {
            return nil
        }
        
        let container = paidSubscriptions.reduce(into: [String: [SubscriptionProductInfo]]()) { (results, item: SubscriptionProductInfo) in
            
            if(results.keys.contains(item.productIdentifier)) {
                var items = results[item.productIdentifier]
                items?.append(item)
                
            } else {
                results[item.productIdentifier] = Array<SubscriptionProductInfo>(arrayLiteral: item)
            }
        }
        return container
    }
    
    init(decryptedData: Data) {
        super.init()
        loadAllProductsInfo(using: decryptedData)
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func loadAllProductsInfo(using decryptedData: Data){
        
        let json = try! JSONSerialization.jsonObject(with: decryptedData, options: []) as! Dictionary<String, Any>
        sessionID = UUID().uuidString
        
        self.receiptData = decryptedData
        self.parsedReceipt = json
        
        allPaidSubscriptions = [SubscriptionProductInfo]()
        allPaidNonConsumables = [NonConsumableProductInfo]()
        
        //get non-consumable products
        IAPLog.event(.parsingProductCategoryFromReceiptStart)
        if let receipt = parsedReceipt!["receipt"] as? [String : Any], let in_app_purchases = receipt["in_app"] as? Array<[String : Any]>{
            IAPLog.event(.paidNonConsumablenInReceiptExist)
            for purchase in in_app_purchases{
                
                if (purchase["expires_date"] == nil){
                    if let nonConsumable = NonConsumableProductInfo(json: purchase){
                        allPaidNonConsumables?.append(nonConsumable)
                    }
                }
            }
        }
        
        if let latestPurchases = parsedReceipt!["latest_receipt_info"] as? Array<[String: Any]>{
            IAPLog.event(.paidSubscriptionInReceiptExist)
            for purchase in latestPurchases {
                
                if (purchase["expires_date"] != nil){
                    if let paidSubscription = SubscriptionProductInfo(json: purchase) {
                        allPaidSubscriptions?.append(paidSubscription)
                    }
                }
            }
        }
    }
    
}

//Helper Methods
extension InAppSession {
    
    func isPurchased(for productID: String) -> Bool {
        
        guard let productInfo = getProductInfo(for: productID) else {
            return false
        }
        
        if let subscribedProduct = productInfo as? SubscriptionProductInfo {
            return subscribedProduct.getSubscriptionStatus()
        }
        else {
            return true
        }
    }
    
    func getProductInfo(for iapID: String) -> NonConsumableProductInfo?{
        
        if let currentSubscription = currentSubscription, currentSubscription.productIdentifier == iapID {
            return currentSubscription
        }
        
        if allPaidSubscriptionsByGroup == nil {
            allPaidSubscriptionsByGroup = subscriptionsByGroup
        }
        
        if let paidSubs = allPaidSubscriptionsByGroup?[iapID]{
            let sortedByMostRecentPurchase = paidSubs.sorted { $0.purchasedDate > $1.purchasedDate }
            guard let subscription = sortedByMostRecentPurchase.first else{
                return nil
            }
            return subscription
        }
        
        guard let nonConsumableItems = allPaidNonConsumables else {
            return nil
        }
        
        let filteredItems = nonConsumableItems.filter { (item: NonConsumableProductInfo) -> Bool in
            return item.productIdentifier == iapID
        }
        
        return filteredItems.first
    }
    
    func getReceiptStatus() -> IAReceiptStatus {
        
        if let status = parsedReceipt!["status"] as? Int, let receiptStatus = IAReceiptStatus(rawValue: status){
            return receiptStatus
        }
        return .Inactive
    }
    
}

extension InAppSession {
    
    override func update(value: Any?, for key: String?) {
        if key == "receiptData" {
            
            receiptData = Data(base64Encoded: value as! String)
            
            if let data = receiptData {
                loadAllProductsInfo(using: data)
            }
        }
    }
    
    override func serialize(value: Any?, for key: String) -> Any? {
        if key == "receiptData" {
            let str = (value as! Data).base64EncodedString()
            return str
            
        } else {
            return super.serialize(value: value, for: key)
            
        }
    }
}
