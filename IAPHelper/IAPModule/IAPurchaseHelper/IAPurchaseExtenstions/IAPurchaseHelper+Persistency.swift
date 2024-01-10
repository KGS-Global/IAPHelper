
extension IAPurchaseHelper {
    
    internal func persistPurchashedProductIDs(_ arrayProductIDs:[String]) {
        
        for productID in arrayProductIDs {
            
            if let productIDInfo = self.getProductIdInfo(productID) {
                
                productIDInfo.persistProductIdAsPurchased()
            }
        }
    }
}
