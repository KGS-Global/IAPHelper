
@objc public class ProductIdInfo: NSObject {
    
    @objc public enum ProductType: Int, RawRepresentable {
        
        case IAPType_Consumable
        case IAPType_NonConsumable
        case IAPType_Subscription
        case IAPType_AutoRenewable
        
        public typealias RawValue = String
        
        public var rawValue: RawValue {
            switch self {
            case .IAPType_Consumable:
                return IAPurchaseConstants.IAP_Product_Consumable
                
            case .IAPType_NonConsumable:
                return IAPurchaseConstants.IAP_Product_NonConsumable
                
            case .IAPType_Subscription:
                return IAPurchaseConstants.IAP_Product_Subscription
                
            case .IAPType_AutoRenewable:
                return IAPurchaseConstants.IAP_Product_AutoRenewable
            }
        }
        
        public init?(rawValue: RawValue) {
            switch rawValue {
            case IAPurchaseConstants.IAP_Product_Consumable:
                self = .IAPType_Consumable

            case IAPurchaseConstants.IAP_Product_Subscription:
                self = .IAPType_Subscription
                
            case IAPurchaseConstants.IAP_Product_AutoRenewable:
                self = .IAPType_AutoRenewable
                
            default:
                self = .IAPType_NonConsumable
            }
        }
    }
    
    private var productIdentifier: String?
    @objc public var inAppProductType: ProductIdInfo.ProductType = ProductIdInfo.ProductType.IAPType_NonConsumable
    
    @objc public init(productID: String, type: ProductType) {
        
        self.productIdentifier = productID
        self.inAppProductType = type
    }
    
    @objc public func getProductID() -> String? {
        return productIdentifier
    }
    
    @objc public func isProductPurchased() -> Bool {
        return IAPersistManager.isProductPurchashed(for: productIdentifier)
    }
    
    @objc public func persistProductIdAsPurchased() {
        IAPersistManager.setPurchasedState(for: productIdentifier)
    }
}
