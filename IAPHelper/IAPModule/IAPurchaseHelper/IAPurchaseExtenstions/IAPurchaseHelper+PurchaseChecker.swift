
extension IAPurchaseHelper {
    
    func isPurchased(productID: String) -> Bool{
        
        //ANP: Purchase Check for purchashed
        var purchashed:Bool = false
        
        if let productIdInfo = self.getProductIdInfo(productID) {
            
            //Subscription
            if productIdInfo.inAppProductType == .IAPType_Subscription {
                purchashed = self.isProductPurchashedBySession(for: productID)
            }
            else {
                
                //Non-Consumable
                purchashed = productIdInfo.isProductPurchased()
                if !purchashed {
                    self.extraCheckingForNonConsumables(for: productID)
                }
            }
        }
        else {
            purchashed = self.isProductPurchashedBySession(for: productID)
        }
        return purchashed
    }
    
    private func extraCheckingForNonConsumables(for productID: String) {
        
        let purchashed = self.isProductPurchashedBySession(for: productID)
        
        if(purchashed) {
            if let productIdentifierInfo = self.getProductIdInfo(productID) {
                productIdentifierInfo.persistProductIdAsPurchased()
            }
        }
    }
    
    private func isProductPurchashedBySession(for productID:String) -> Bool {

        guard let inAppSession = savedInAppSession else {
            return false
        }
        return inAppSession.isPurchased(for: productID)
    }
}

