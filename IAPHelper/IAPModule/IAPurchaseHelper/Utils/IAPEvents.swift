
import Foundation

/// Informational logging notifications issued by IAPHelper
public enum IAPEvents: Equatable {
    
    case requestSKProductStarted
    case requestSKProductsSuccess
    case skProductFetchFailed
    case requestProductsDidFinish
    
    case purchaseStarted
    case purchaseInitFailed
    case purchaseInProgress
    case purchaseAbortPurchaseInProgress
    case restoreAbortPurchaseInProgress
    case purchaseRestoreStarted
    case shouldAddStorePayment
    case purchaseDeferred
    
    case uploadReceiptForValidationStart
    case uploadInSandboxForReceiptValidationStart
    case parsingProductCategoryFromReceiptStart
    case paidNonConsumablenInReceiptExist
    case paidSubscriptionInReceiptExist
    
    case receiptValidationSucceed
    case receiptVerificationFailed
    
    case loadLastSessionStarted
    case loadLastSessionFailed
    case loadLastSessionSucceed
    case sessionArchivingFailed
    case sessionArchivingSucceed
    
    case appStoreRevokedEntitlements
    case receiptVerificationSuccessful
    case receiptNotFoundInBundle
    case receiptValidationFailedWhileRestoring
    case noRestoredIdFound
    case purchaseCancelled
    
    ///Major events Notifications
    case restoreIsSuccessful
    case restoreIsFailed
    case purchaseIsSuccessful
    case purchaseIsFailed
    case promotionPurchaseStarted
    
    case appWillEnterForeground
    case reachabilityChanged
    case appWillTerminate
    
    /// A short description of the notification.
    /// - Returns: Returns a short description of the notification.
    ///
    public func shortDescription() -> String {
        
        switch self {
            
            //MARK: Major events
        case .restoreIsSuccessful:                       return "Major: restore is successful"
        case .restoreIsFailed:                           return "Major: restore is failed"
        case .purchaseIsSuccessful:                      return "Major: purchase succeed"
        case .purchaseIsFailed:                          return "Major: purchase failed"
        case .promotionPurchaseStarted:                  return "Major: promotion Purchase Started"
   
            //MARK: Product Request
        case .requestSKProductStarted:                   return "Request products from the App Store started"
        case .requestSKProductsSuccess:                  return "Request products from the App Store success"
        case .skProductFetchFailed:                      return "SKProduct from iTune Server didn't found"
        case .requestProductsDidFinish:                  return "The request for products from the App-Store completed"
            
        case .shouldAddStorePayment:                     return "Should add store payment called"
  
            //MARK: Product Purchase
        case .purchaseStarted:                           return "Purchase started"
        case .purchaseInitFailed:                        return "Purchase initialization failed"
        case .purchaseInProgress:                        return "Purchase in progress"
        case .purchaseAbortPurchaseInProgress:           return "Purchase aborted because another purchase is already in progress"
        case .restoreAbortPurchaseInProgress:            return "Restore aborted because another purchase is already in progress"
        case .purchaseRestoreStarted:                    return "Purchase restore started"
            
            //MARK: InAppSession
        case .loadLastSessionStarted:                    return "Load last session offline started"
        case .loadLastSessionFailed:                     return "Load last session offline failed"
        case .loadLastSessionSucceed:                    return "Load last session offline succeed"
        case .sessionArchivingSucceed:                   return "Session archiving succeed"
        case .sessionArchivingFailed:                    return "Session archiving failed"
            
            //MARK: Receipt Validation
        case .uploadReceiptForValidationStart:           return "HTTP request for receipt verification started"
        case .uploadInSandboxForReceiptValidationStart:  return "Upload receipt in Sandbox for verification started"
        case .receiptVerificationSuccessful:             return "Receipt verification successful by iTune Server"
        case .receiptVerificationFailed:                 return "Receipt verification failed by iTune Server"
        case .receiptValidationSucceed:                  return "Receipt succeed by online/offline"
        case .parsingProductCategoryFromReceiptStart:    return "Product categorization from receipt data started"
        case .paidNonConsumablenInReceiptExist:          return "Paid Non Consumable Parsed from receipt Data"
        case .paidSubscriptionInReceiptExist:            return "Paid Subscription Parsed from receipt Data"
            
            //MARK: Failed or Deferred Events
        case .purchaseDeferred:                          return "Purchase in progress. Awaiting authorization"
        case .appStoreRevokedEntitlements:               return "The App Store revoked user entitlements"
            
        case .receiptNotFoundInBundle:                   return "Receipt not found in Bundle URL"
        case .receiptValidationFailedWhileRestoring:     return "Receipt Validation failed while restoring"
        case .noRestoredIdFound:                         return "No Restored ID found while in restored State."
        case .purchaseCancelled:                         return "Purchase cancelled"
            
            //MARK: Other Events
        case .appWillEnterForeground:                    return "App will Enter Foreground"
        case .appWillTerminate:                          return "App will Terminate"
        case .reachabilityChanged:                       return "Internet Reachablity Changed"
        }
    }
}

public struct IAPLog {
    
    /// Logs an IAPEvents. Note that the text (shortDescription) and the productId for the
    /// log entry will be publically available in the Console app.
    /// - Parameters:
    ///   - event:      An IAPEvents.
    ///   - productId:  A ProductId associated with the event.
    static func event(_ event: IAPEvents, productId: String? = nil) {
        
        if productId == nil {
            print("Event: \(event.shortDescription())")
        } else {
            print("Event: \(event.shortDescription()) for product \(productId!)")
        }
    }
    
    /// Logs an IAPurchaseState. Note that the text (shortDescription) and the productId for the
    /// log entry will be publically available in the Console app.
    /// - Parameters:
    ///   - event:      An IAPurchaseState.
    ///   - productId:  A ProductId associated with the event.
    static func event(_ event: IAPurchaseState, productId: String? = nil) {
        
        if productId == nil {
            print("UpdateRequiredThings: \(event.shortDescription())")
        } else {
            print("UpdateRequiredThings: \(event.shortDescription()) for product \(productId!)")
        }
    }
    
    /// Logs a message.
    /// - Parameter message: The message to log.
    public static func event(_ message: String) {
        
        print(message)
    }
}


