import UIKit

protocol SubProductLoaderProtocol {
    
    func getProductIDsInfo() -> [ProductIdInfo]
}

class SubProductLoader: NSObject {
    
    @objc var arrayProductIDInfo = [ProductIdInfo]()
    
    private var allSubscriptionProductIDs = [String]()
    private var allNonConsumableProductIDs = [String]()
    private var allConsumableProductIDs = [String]()
    private var dictionaryIsAlreadyAdded = [String:Bool]()
    
    func loadProductIDsInfo(subscriptionProductIDs: [String] = [],
                            nonConsumableProductIDs: [String] = [],
                            consumableProductIDs: [String] = []) {
        
        //MARK: Input All SUBSCRIPTION ID here
        self.allSubscriptionProductIDs = subscriptionProductIDs
        
        
        //MARK: Input All NON-CONSUMABLE ID here
        self.allNonConsumableProductIDs = nonConsumableProductIDs
        
        //MARK: Input All CONSUMABLE ID here
        self.allConsumableProductIDs = consumableProductIDs
        
        buildProductIDInfoArray()
    }
    
    func getAllProductIds() -> [String]{
        var allProducts: [String] = []
        allProducts.append(contentsOf: self.allSubscriptionProductIDs)
        allProducts.append(contentsOf: self.allNonConsumableProductIDs)
        allProducts.append(contentsOf: self.allConsumableProductIDs)
        return allProducts
    }
    
    func getSubscriptionTypeIDs() -> [String] {
        return self.allSubscriptionProductIDs
    }
    
    
    func getNonConsumableTypeIDs() -> [String] {
        return self.allNonConsumableProductIDs
    }
    
    
    func getConsumableTypeIDs() -> [String] {
        return self.allConsumableProductIDs
    }
    private func buildProductIDInfoArray() {
        
        arrayProductIDInfo.removeAll()
        
        for subscriptionID in allSubscriptionProductIDs {
            
            let isAlreadyAdded = dictionaryIsAlreadyAdded[subscriptionID]
            if isAlreadyAdded == nil || isAlreadyAdded == false {
                
                let subscriptionIdInfo = ProductIdInfo(productID: subscriptionID, type: .IAPType_Subscription)
                arrayProductIDInfo.append(subscriptionIdInfo)
                dictionaryIsAlreadyAdded[subscriptionID] = true
            }
        }
        
        for nonConsumableID in allNonConsumableProductIDs {
            
            let isAlreadyAdded = dictionaryIsAlreadyAdded[nonConsumableID]
            if isAlreadyAdded == nil || isAlreadyAdded == false {
                
                let nonConsumableIdInfo = ProductIdInfo(productID: nonConsumableID, type: .IAPType_NonConsumable)
                arrayProductIDInfo.append(nonConsumableIdInfo)
                dictionaryIsAlreadyAdded[nonConsumableID] = true
            }
        }
        
        for consumableID in allConsumableProductIDs {
            
            let isAlreadyAdded = dictionaryIsAlreadyAdded[consumableID]
            if isAlreadyAdded == nil || isAlreadyAdded == false {
                
                let consumableIdInfo = ProductIdInfo(productID: consumableID, type: .IAPType_Consumable)
                arrayProductIDInfo.append(consumableIdInfo)
                dictionaryIsAlreadyAdded[consumableID] = true
            }
        }
    }
}

extension SubProductLoader: SubProductLoaderProtocol {
    
    func getProductIDsInfo() -> [ProductIdInfo] {
        return arrayProductIDInfo
    }
    
}
