

let DEFAULT_SUBSCRIPTION_PRICE: String   = "$$"
let DEFAULT_TRIAL_DAYS: String           = "n-days"
let NO_TRIAL_DAYS: String                = "0-days"
let PURCHASE_TRY_OUT_TIME: Double        = 10.0




class IAPurchaseConstants: NSObject {
    
    static let IAP_Product_Consumable: String     = "Consumable"
    static let IAP_Product_NonConsumable: String  = "NonConsumable"
    static let IAP_Product_Subscription: String   = "Subscription"
    static let IAP_Product_AutoRenewable: String  = "AutoRenewableSubscription"
    
    static let urlAppStore       = URL(string: "https://buy.itunes.apple.com/verifyReceipt")!
    static let urlSandbox        = URL(string: "https://sandbox.itunes.apple.com/verifyReceipt")!
}

extension IAPurchaseConstants {
    static let IAP_SAVED_SESSION_KEY: String     = "savedSession_key"
}
