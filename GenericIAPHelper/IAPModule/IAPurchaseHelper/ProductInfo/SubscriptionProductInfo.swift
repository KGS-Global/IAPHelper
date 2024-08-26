

class SubscriptionProductInfo: NonConsumableProductInfo {
    
    public var expirationDateString: String
    public var purchaseDateString: String
    private var expirationDate: Date
    private var cancellationDate: Date?
    public var isOnTrialPeriod: Bool
    public var autoRenewalStatus: Bool = false
    
    
    private var isActive: Bool {
        
        if isCancelled{
            return false
        }
        
        let currentDateString = IACommonUtils.customDateFormatter.string(from: Date())
        let currentDate = IACommonUtils.customDateFormatter.date(from: currentDateString)
        let active = (purchasedDate...expirationDate).contains(currentDate!)
        print("Event: productID: \(self.productIdentifier) currentDate:\(currentDate)  expirationDate: \(expirationDate) STATUS: \(active)")
        return active
    }
    
    var isCancelled: Bool{
        return (cancellationDate != nil)
    }
    
    func getSubscriptionStatus() -> Bool {
        return isActive
    }
    
    @objc func getTrialPeriodState() -> Bool {
        return isOnTrialPeriod
    }
    override init?(json: [String: Any]) {
        guard
            let _ = json["product_id"] as? String,
            let purchaseDateString = json["purchase_date"] as? String,
            let _ = json["transaction_id"] as? String,
            let expiresDateString = json["expires_date"] as? String,
            let expiresDate = IACommonUtils.customDateFormatter.date(from: expiresDateString),
            let isTrialPeriod = json["is_trial_period"] as? String
        else {
            return nil
        }
        self.expirationDate = expiresDate
        self.isOnTrialPeriod = (isTrialPeriod == "true") ? true : false;
        self.expirationDateString = expiresDateString
        self.purchaseDateString = purchaseDateString
        super.init(json: json)
        
        if let cancellationDateStr = json["cancellation-date"] as? String{
            cancellationDate = IACommonUtils.customDateFormatter.date(from: cancellationDateStr)
        }
    }
}
