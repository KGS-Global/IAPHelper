import Foundation
import StoreKit

extension IAPurchaseHelper: StoreQueueOperationDelegate {
  
    /// Receives a list of localized product info from StoreQueueOperation.
    /// - Parameters:
    ///   - request:    The request object.
    ///   - response:   The response from the App Store.
    internal func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse, onCompletion: FetchProductCompleted?) {
        
        DispatchQueue.main.async {
            
            var receivedItems = response.products.map { InAppProduct(product: $0) }
            if let arrayProducts = self.getArrayOfIAProducts() {
                
                for product in arrayProducts {
                    if receivedItems.contains(product) == false {
                        receivedItems.append(product)
                    }
                    IAPLog.event(.requestSKProductsSuccess, productId: product.iAPIdentifier)
                }
            }
            
            self.setArrayOf(iAProducts: receivedItems)
            if let onCompletionBlock = onCompletion {
                onCompletionBlock(receivedItems)
            }
        }
    }
    
    /// Called by the StoreQueueOperation if a request fails.
    /// This method is called for both SKProductsRequest (request product info) and
    /// SKRequest (request receipt refresh).
    /// - Parameters:
    ///   - request:    The request object.
    ///   - error:      The error returned by the App Store.
    internal func request(_ request: SKRequest, didFailWithError error: Error, onCompletion: FetchProductCompleted?) {
        
        if request is SKProductsRequest {
            IAPLog.event(.skProductFetchFailed, productId: error.localizedDescription)
        }
        DispatchQueue.main.async {
            
            if let onCompletionBlock = onCompletion {
                onCompletionBlock(self.getArrayOfIAProducts())
            }
        }
    }
}

extension IAPurchaseHelper {
    
    func addAnOperation(productIDs: [ProductIdInfo], _ onCompletion: FetchProductCompleted?) {
        let ids:[String] = productIDs.map { $0.getProductID()!}
        let storeOperation = StoreQueueOperation(ids)
        storeOperation.storeQueueDelegate = self
        storeOperation.productFetchCompletionBlock = onCompletion
        //Added to the operation Queue. It will Start Operation immediately but sequencially
        
        StoreQueue.addOperation(storeOperation)
    }
}
