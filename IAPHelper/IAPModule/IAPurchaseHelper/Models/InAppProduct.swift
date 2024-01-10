
import Foundation
import StoreKit

@objcMembers
public class InAppProduct: NSObject {
    
    let skProduct: SKProduct
    let productPrice: NSDecimalNumber
    @objc let currencyFormattedPrice: String
    let currencyCode: String
    var shouldAddStorePayment: Bool = false
    
    var priceFormatter = IACommonUtils.currencyFormatter
    
    var iAPIdentifier:String {
        return skProduct.productIdentifier
    }
    
    init(product: SKProduct) {
        
        self.skProduct = product
        if priceFormatter.locale != self.skProduct.priceLocale {
            priceFormatter.locale = self.skProduct.priceLocale
        }
        currencyFormattedPrice = priceFormatter.string(from: product.price) ?? "\(product.price)"
        currencyCode = priceFormatter.currencyCode
        productPrice = product.price
    }
    
    public override var hash: Int {
        return iAPIdentifier.hashValue
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        return self.iAPIdentifier == (object as? InAppProduct)?.skProduct.productIdentifier
    }
}
