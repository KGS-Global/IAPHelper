
import Foundation
import StoreKit

class PaymentTrnxObserver: NSObject {
    private static let duplicateErrorCode = 3532
    
    
    func addPaymentObserver() {
        SKPaymentQueue.default().add(self)
    }
    
    func removePaymentObserver(){
        SKPaymentQueue.default().remove(self)
    }
    
}

//MARK: SKPaymentTransactionObserver Major Delegates from System
extension PaymentTrnxObserver: SKPaymentTransactionObserver {
    
    /// This delegate allows us to receive notifications from the App Store when payments are successful, fail, are restored, etc.
    /// - Parameters:
    ///   - queue:          The payment queue object.
    ///   - transactions:   Transaction information.
    func paymentQueue(_ queue: SKPaymentQueue,
                      updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            switch transaction.transactionState {
                
            case .purchasing:
                purchaseInProgressAction(for: transaction, in: queue)
                
            case .purchased:
                purchaseSuccessfulAction(for: transaction, in: queue)
                
            case .restored:
                restoreSuccessfulAction(for: transaction, in: queue)
                
            case .failed:
                handleFailedState(for: transaction, in: queue)
                
            case .deferred:
                handleDeferredState(for: transaction, in: queue)
                
            @unknown default:
                print("Fatal Error: Unknown Error Happened.")
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        
        let restoredProductIDs: [String] = queue.transactions.compactMap({ (transaction) -> String? in
            
            let currentTrnxState = transaction.transactionState
            
            if currentTrnxState == .failed || currentTrnxState == .purchasing || currentTrnxState == .deferred {
                return nil
            } else {
                return transaction.payment.productIdentifier
            }
        })
        
        let noRestoredIdFound = restoredProductIDs.count <= 0
        
        guard noRestoredIdFound == false else {
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: IAPurchaseHelper.restoreFailureNotification, object: nil)
                IAPLog.event(.noRestoredIdFound)
            }
            return
        }
        
        IAPurchaseHelper.shared.uploadReceiptForValidation { receiptValidated in
            
            let setOfRestoredIDs = NSOrderedSet(array: restoredProductIDs).array as! [String]
            
            guard receiptValidated else {
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: IAPurchaseHelper.restoreFailureNotification, object: nil)
                    IAPLog.event(.receiptValidationFailedWhileRestoring)
                }
                return
            }
            
            IAPurchaseHelper.shared.persistPurchashedProductIDs(setOfRestoredIDs)
            
            DispatchQueue.main.async {
                
                NotificationCenter.default.post(name: IAPurchaseHelper.restoreSuccessfulNotification, object: nil, userInfo: ["productIDs":setOfRestoredIDs])
                
                for prodID in setOfRestoredIDs {
                    IAPLog.event(.restoreIsSuccessful, productId: prodID)
                }
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        
        let ids: [String] = queue.transactions.compactMap({ (transaction) -> String? in
            
            return (transaction.transactionState == SKPaymentTransactionState.failed)
            ? transaction.payment.productIdentifier
            : nil
        })
        
        DispatchQueue.main.async {
            
            if let failedRestoredIDs = NSOrderedSet(array: ids).array as? [String] {
                
                NotificationCenter.default.post(name: IAPurchaseHelper.restoreFailureNotification, object: nil)
                for aFailedID in failedRestoredIDs {
                    IAPLog.event(.restoreIsFailed, productId: aFailedID)
                }
            }
        }
        
    }
    
    /// Sent when entitlements for a user have changed and access to the specified IAPs has been revoked.
    /// - Parameters:
    ///   - queue:              Payment queue.
    ///   - productIdentifiers: ProductId which should have user access revoked.
    @available(iOS 14.0, *)
    func paymentQueue(_ queue: SKPaymentQueue, didRevokeEntitlementsForProductIdentifiers productIdentifiers: [String]) {
        
        productIdentifiers.forEach { productId in
            IAPLog.event(.appStoreRevokedEntitlements, productId: productId)
        }
    }
}

extension PaymentTrnxObserver {
    
    private func purchaseInProgressAction(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        
        let productIdentifier = transaction.payment.productIdentifier
        IAPLog.event(.purchaseInProgress, productId: productIdentifier)
    }
    
    private func purchaseSuccessfulAction(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        
        defer {
            // The use of the defer block guarantees that no matter when or how the method exits,
            // the code inside the defer block will be executed when the method goes out of scope.
            // It's important we remove the completed transaction from the queue. If this isn't done
            // then when the app restarts the payment queue will attempt to process the same transaction
            
            //CHECK: May Create Problem
            SKPaymentQueue.default().finishTransaction(transaction)
        }
        
        let purchasedProductID = transaction.payment.productIdentifier
        IAPLog.event(.purchaseIsSuccessful, productId: purchasedProductID)
        
        IAPurchaseHelper.shared.persistPurchashedProductIDs([purchasedProductID])
        IAPurchaseHelper.shared.uploadReceiptForValidation { receiptValidated in
            
            guard receiptValidated else {
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                
                //TODO: Send Purchase Successful Notification
                
                IAPLog.event(.receiptVerificationSuccessful, productId: purchasedProductID)
                
                NotificationCenter.default.post(name: IAPurchaseHelper.purchaseSuccessfulNotification, object: nil, userInfo:
                                                    ["productID": purchasedProductID,
                                                     "status": NSNumber(value: receiptValidated),
                                                     "transaction": transaction])
            })
        }
    }
    
    private func restoreSuccessfulAction(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func handleFailedState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        
        defer {
            // The use of the defer block guarantees that no matter when or how the method exits,
            // the code inside the defer block will be executed when the method goes out of scope
            // Always call SKPaymentQueue.default().finishTransaction() for a failure
            SKPaymentQueue.default().finishTransaction(transaction)
        }
        
        
        let aFailedProductID = transaction.payment.productIdentifier
        
        if let aTransactionError = transaction.error as NSError? {
            
            if aTransactionError.code == SKError.paymentCancelled.rawValue {
                
                IAPLog.event(.purchaseCancelled, productId: aFailedProductID)
                ProgressHUD.dismiss()
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: IAPurchaseHelper.purchaseCancelledNotification, object: nil)
                }
                
            } else {
                
                
                IAPLog.event(.purchaseIsFailed, productId: aFailedProductID)
                
                if let underlyingError = aTransactionError.userInfo["NSUnderlyingError"] as? Error {
                    let errorCode = (underlyingError as NSError).code
                    if errorCode == PaymentTrnxObserver.duplicateErrorCode{
                        NotificationCenter.default.post(name: IAPurchaseHelper.duplicatePurchasedNotification, object: nil)
                        return;
                    }

                }
                
                let defaultBackgroundColor: UIColor = UIColor(red: 236.0 / 255.0, green: 247.0/255.0, blue: 255.0/255.0, alpha: 1)
                let defaultAletTextColor: UIColor = UIColor(red: 11.0 / 255.0, green: 13.0/255.0, blue: 15.0/255.0, alpha: 1)

                TopAlertManager.showCustomTopAlert(withBackgroundColor: defaultBackgroundColor, withTextColor: defaultAletTextColor, withImageName: "Net_Error", withText: "Please try again!") {
                    ProgressHUD.dismiss()
                }

                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: IAPurchaseHelper.purchaseFailureNotification, object: nil)
                }
            }
            
        } else {
            
            IAPLog.event(.purchaseCancelled, productId: aFailedProductID)
            ProgressHUD.dismiss()
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: IAPurchaseHelper.purchaseCancelledNotification, object: nil)
            }
        }
        
    }
    
    private func handleDeferredState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        
        // The purchase is in the deferred state. This happens when a device has parental restrictions enabled such
        // that in-app purchases require authorization from a parent. Do not allow access to the product at this point
        // Apple recommeds that there be no spinners or blocking while in this state as it could be hours or days
        // before the purchase is approved or declined.
        //
        // Starting December 31, 2020, legislation from the European Union introduces Strong Customer Authentication
        // (SCA) requirements for users in the European Economic Area (EEA) that may impact how they complete online
        // purchases. While the App Store and Apple Pay will support Strong Customer Authentication, you’ll need to verify
        // your app’s implementation of StoreKit and Apple Pay to ensure purchases are handled correctly.
        //
        // For in-app purchases that require SCA, the user is prompted to authenticate their credit or debit card.
        // They’re taken out of the purchase flow to the bank or payment service provider’s website or app for authentication,
        // then redirected to the App Store where they’ll see a message letting them know that their purchase is complete.
        // Handling this interrupted transaction is similar to Ask to Buy purchases that need approval from a family approver
        // or when users need to agree to updated App Store terms and conditions before completing a purchase.
        //
        // Make sure your app can properly handle interrupted transactions by initializing a transaction observer to respond
        // to new transactions and synchronize pending transactions with Apple. This observer helps your app handle SCA
        // transactions, which can update your payment queue with a state of “failed” or “deferred” as the user exits the app.
        // When the user is redirected to the App Store after authentication, a new transaction with a state of “purchased”
        // is immediately delivered to the observer and may include a new value for the transactionIdentifier property.
        //
        // Ref: https://developer.apple.com/support/psd2/
        
        IAPLog.event(.purchaseDeferred, productId: transaction.payment.productIdentifier)

        // Do NOT call SKPaymentQueue.default().finishTransaction() for .deferred status
        
    }
}

//MARK: SKPaymentTransactionObserver Non Major Delegates from System
extension PaymentTrnxObserver {
    
    /// Send this URL to yourself in an email or iMessage and open it from your device. You will know the test is
    /// running when your app opens automatically. You can then test your promoted in-app purchase.
    /// - Parameters:
    ///   - queue:      Payment queue object.
    ///   - payment:    Payment info.
    ///   - product:    The product purchased.
    /// - Returns:      Return true to continue the transaction (will result in normal processing via paymentQueue(_:updatedTransactions:).
    ///                 Return false to indicate that the store not to proceed with purchase (i.e. it's already been purchased).
    @available(iOS 11.0, *)
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        
        NotificationCenter.default.post(name: IAPurchaseHelper.promotionPurchaseStartNotification, object: nil, userInfo: ["product" : product,"payment" : payment])
        
        IAPLog.event(.shouldAddStorePayment, productId: product.productIdentifier)
        
        // Return False as currently promotional purchase is not supported. Have to implement following line if support in future.
        // return !try! SubscriptionManager.shared().isIndividuallyPurchased(for: product.productIdentifier)
        return false

    }
    
    
}
