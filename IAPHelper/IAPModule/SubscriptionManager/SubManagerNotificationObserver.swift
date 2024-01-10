import UIKit

@objc public enum IAPurchaseState:Int {
    
    case PurchaseSuccessful
    case RestoreSuccessful
    case PurchaseFailure
    case RestoreFailure
    case PromotionPurchaseStart
    case PurchaseRecieptLoad
    case SubscriptionExpire
    case ProductLoaded
    case DuplicatePurchase
    
    /// A short description of the IAPurchaseState.
    /// - Returns: Returns a short description of the notification.
    ///
    public func shortDescription() -> String {
        
        switch self {
        
        case .PurchaseSuccessful:                         return "Purchase is successful"
        case .RestoreSuccessful:                          return "Restore is successful"
        case .PurchaseFailure:                            return "Purchase failed"
        case .RestoreFailure:                             return "Restore failed"
        case .PromotionPurchaseStart:                     return "Promotion purchase started"
        case .PurchaseRecieptLoad:                        return "Purchase Reciept is loaded"
        case .SubscriptionExpire:                         return "Subscription is expired"
        case .ProductLoaded:                              return "Product is loaded"
        case .DuplicatePurchase:                           return "Duplicate Purchased"
        }
    }
}

@objc public protocol SubManagerNotificationObserver {
    
    func updateRequiredThingsFor(notificationType:IAPurchaseState,notification:Notification?)
}
