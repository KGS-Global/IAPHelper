import Foundation
import StoreKit
extension IAPurchaseHelper {
    
    /**
     Fetch application's in app purchase product from the store.
     - Parameter productIDs : product identifier's for associated products.
     - Parameter onCompletion : completion after fetch succes / fail.
     */
    internal func requestProductsFromAppStore(productIDs:[ProductIdInfo], onCompletion:FetchProductCompleted? = nil) {
        
        self.setArrayOf(productIDs: productIDs)
        if productIDs.count == 0 && onCompletion != nil {
            onCompletion!(self.getArrayOfIAProducts())
            return
        }
        if productIDs.count > 0 {
            self.addAnOperation(productIDs: productIDs, onCompletion)
        }
    }
}

//Purchase Pressed
extension IAPurchaseHelper {
    
    /// Start the process to purchase a product. When we add the payment to the default payment queue
    /// StoreKit will present the required UI to the user and start processing the payment. When that
    /// transaction is complete or if a failure occurs, the payment queue sends the SKPaymentTransaction
    /// object that encapsulates the request to all transaction observers. See the
    /// paymentQueue(_:updatedTransactions) for how these events get handled.
    /// - Parameter productID:            The Product Identifier for the product which user want to purchase
    /// - Parameter onPurchaseInitiation: Completion block that will be called when the purchase is successfully initiated.
    func purchaseRequest(for productID: String, onPurchaseInitiation: ((_ isPurchaseInitiated: Bool)->Void)? = nil) {
        
        isPurchaseRequested = false
        
        if !InternetChecker.shared.isInternetConnected() {
            return
        }
        
        DispatchQueue.main.async {
            
            if self.getInAppProduct(for: productID) != nil {
                self.requestPurchaseFinally(for: productID, on: onPurchaseInitiation)
                
            } else {
                
                let startTime = NSDate.timeIntervalSinceReferenceDate
                Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                    
                    let timerDuration = NSDate.timeIntervalSinceReferenceDate - startTime
                    print("Event:: Try to Purchase \(timerDuration)")
                    
                    if !InternetChecker.shared.isInternetConnected() {
                        TopAlertManager.showNoInternetAlert()
                        ProgressHUD.dismiss()
                        timer.invalidate()
                        return
                    }
                    if timerDuration >= PURCHASE_TRY_OUT_TIME || self.getInAppProduct(for: productID) != nil {
                        timer.invalidate()
                        self.requestPurchaseFinally(for: productID, on: onPurchaseInitiation)
                    }
                }
            }
        }
    }
    
    private func requestPurchaseFinally(for productID: String, on onPurchaseInitiation: ((_ isPurchaseInitiated: Bool)->Void)? = nil) {
        
        if isPurchaseRequested == true {
            return
        }
        isPurchaseRequested = true
        guard let inAppProduct = self.getInAppProduct(for: productID) else {
            
            if let onCompletion = onPurchaseInitiation {
                IAPLog.event(.purchaseInitFailed, productId: productID)
                onCompletion(false)
            }
            return
        }
        
        self.addInPaymentQueue(for: inAppProduct)
        
        if let onCompletion = onPurchaseInitiation {
            
            IAPLog.event(.purchaseStarted, productId: productID)
            onCompletion(true)
        }
    }
    
    @objc public func addInPaymentQueue(for iAProduct: InAppProduct) {
        
        let skPayment = SKPayment(product: iAProduct.skProduct)
        SKPaymentQueue.default().add(skPayment)
    }
}

//Restore Action
extension IAPurchaseHelper {
    
    /// Ask StoreKit to restore any previous purchases that are missing from this device.
    /// The user may be asked to authenticate. Will result in zero (if the user hasn't
    /// actually purchased anything) or more transactions to be received from the payment queue.
    /// See the SKPaymentTransactionObserver delegate.
    @objc public func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
        IAPLog.event(.purchaseRestoreStarted)
    }
}

//MARK: Get necessary info from App Store
extension IAPurchaseHelper {
    /// The Apple ID of some users (e.g. children) may not have permission to make purchases from the app store.
    /// - Returns: Returns true if the user is allowed to authorize payment, false if they do not have permission.
    @objc public class func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
}
