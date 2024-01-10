//
//import UIKit
//
//
//@objc protocol SubPurchaseCheckingProtocol {
//    
//    func isSubscribedOrUnlockedAll() -> Bool
//    func isIndividuallyPurchased(for productID: String) -> Bool
//}
//
//class SubPurchaseChecker: SubPurchaseCheckingProtocol {
//    
//    private var lastSubscriptionStatus = false
//    private var notificationHandler = SubManagerNotificationHandler.shared
//    
//    func isSubscribedOrUnlockedAll() -> Bool {
//        
//        var isSubscribed = false
//        
//        //MARK: Input All Product ID which need to check for unlock features
//        let arrayProductIDsForChecking = [IAPConstants.SUBSCRIPTION_WEEKLY_TRIAL,
//                                          IAPConstants.SUBSCRIPTION_WEEKLY_NO_TRIAL,
//                                          IAPConstants.NON_CONSUMABLE_REMOVE_ADS
//        ]
//        
//        for aProductIdForCheck in arrayProductIDsForChecking {
//            isSubscribed = isSubscribed || IAPurchaseHelper.shared.isPurchased(productID: aProductIdForCheck)
//        }
//        
//        // If last SubscriptionStatus true but currently Subscription false that means the previous subscription got expired.
//        // A notification for Subscription Expire Sent from here
//        
//        if lastSubscriptionStatus == true && isSubscribed == false {
//            
//            lastSubscriptionStatus = isSubscribed
//            notificationHandler.notifyObserversForNotificationType(.SubscriptionExpire, nil)
//        }
//        
//        lastSubscriptionStatus = isSubscribed
//        return lastSubscriptionStatus
//    }
//    
//    func isIndividuallyPurchased(for productID: String) -> Bool {
//        
//        let isPurchased = IAPurchaseHelper.shared.isPurchased(productID: productID)
//        return isPurchased
//    }
//}
