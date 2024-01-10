import Foundation
import StoreKit


protocol StoreQueueOperationDelegate: NSObjectProtocol {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse, onCompletion: FetchProductCompleted?) -> Void
    func request(_ request: SKRequest, didFailWithError error: Error, onCompletion: FetchProductCompleted?) -> Void
}

class StoreQueueOperation: InAppOperation {
    
    weak var storeQueueDelegate: StoreQueueOperationDelegate?
    
    var productFetchCompletionBlock: FetchProductCompleted?
    
    private var arrayProductIds: [String]!

    init(_ productIds: [String]) {
        super.init()
        self.arrayProductIds = productIds
    }
    
    override func execute() {
        
        IAPLog.event(.requestSKProductStarted)
        let productRequest = SKProductsRequest(productIdentifiers: Set(arrayProductIds))
        productRequest.delegate = self
        productRequest.start()
    }
}

extension StoreQueueOperation: SKProductsRequestDelegate {
    
    /// Receives a list of localized product info from the App Store.
    /// - Parameters:
    ///   - request:    The request object.
    ///   - response:   The response from the App Store.
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        storeQueueDelegate?.productsRequest(request, didReceive: response, onCompletion: productFetchCompletionBlock)
        super.finish()
    }
    
    /// Called by the App Store if a request fails.
    /// This method is called for both SKProductsRequest (request product info) and
    /// SKRequest (request receipt refresh).
    /// - Parameters:
    ///   - request:    The request object.
    ///   - error:      The error returned by the App Store.
    func request(_ request: SKRequest, didFailWithError error: Error) {
        
        storeQueueDelegate?.request(request, didFailWithError: error, onCompletion: productFetchCompletionBlock)
        super.finish()
    }
    
    /// This method is called for both SKProductsRequest (request product info) and
    /// SKRequest (request receipt refresh).
    /// - Parameters:
    ///   - request:    The request object.
    func requestDidFinish(_ request: SKRequest) {
        
//        if productsRequest != nil {
//            productsRequest = nil  // Destroy the product info request object
//
//            // Call the completion handler. The request for product info completed. See also productsRequest(_:didReceive:)
            IAPLog.event(.requestProductsDidFinish)
//            DispatchQueue.main.async { self.requestProductsCompletion?(.requestProductsDidFinish) }
//            return
//        }
//
//        if receiptRequest != nil {
//            receiptRequest = nil  // Destory the receipt request object
//            IAPLog.event(.requestReceiptRefreshSuccess)
//            DispatchQueue.main.async { self.requestReceiptCompletion?(.requestReceiptRefreshSuccess) }
//        }
    }
    
}
