
class IAPersistManager: NSObject {
    
    /// Save the purchased state for a ProductId. A Bool is created in UserDefaults where the key is the ProductId.
    /// - Parameters:
    ///   - productIdentifier: ProductId for an in-app purchase that this app supports.
    ///   - purchased: True if the product has been purchased, false otherwise.
    ///
    static public func setPurchasedState(for productIdentifier: String?, purchased: Bool = true) {
        
        guard let key = productIdentifier else {
            return
        }
        
        UserDefaults.standard.set(purchased, forKey: key)
    }
    
    /// Returns a Bool indicating if the ProductId has been purchased.
    /// - Parameter productIdentifier:  ProductId for an in-app purchase that this app supports.
    /// - Returns:              A Bool indicating if the ProductId has been purchased.
    ///
    static public func isProductPurchashed(for productIdentifier: String?) -> Bool {
        
        guard let key = productIdentifier else {
            return false
        }
        let isPurchashed = UserDefaults.standard.bool(forKey: key)
        return isPurchashed
    }
    
    /// Save the purchased state for a set of ProductIds. For each ProductId a Bool is created in
    /// UserDefaults where the key is the ProductId.
    /// - Parameters:
    ///   - productIdentifiers: Set of ProductIds for all in-app purchases that this app supports.
    ///   - purchased:  True if the products have been purchased, false otherwise.
    ///
    static public func setPurchasedState(for productIdentifiers: Set<String>, purchased: Bool = true) {
        
        for productId in productIdentifiers {
            
            self.setPurchasedState(for: productId, purchased: purchased)
        }
    }
    
    static public func getUserDefaultData(for stringKey: String) -> Data? {
        return UserDefaults.standard.data(forKey: stringKey)
    }
    
    static public func setUserDefaultData(keyValue stringKey: String, data: Data) {
        UserDefaults.standard.set(data, forKey: stringKey)
        
    }
    
    static public func shouldSynchronize() {
        UserDefaults.standard.synchronize()
    }
}
