@objc(NonConsumableProductInfo)
@objcMembers
class NonConsumableProductInfo: NSObject {
    
    var productIdentifier: String
    var purchasedDate: Date
    private var transactionId: String
    private var originalTransactionID : String
    
    init?(json: [String: Any]) {
        guard
            let productID = json["product_id"] as? String,
            let purchaseDateString = json["purchase_date"] as? String,
            let purchaseDate = IACommonUtils.customDateFormatter.date(from: purchaseDateString),
            let transactionId = json["transaction_id"] as? String,
            let originalTransactionId = json["original_transaction_id"] as? String
            else {
                return nil
        }
        
        self.productIdentifier = productID
        self.purchasedDate = purchaseDate
        self.transactionId = transactionId
        self.originalTransactionID = originalTransactionId
    }
}
