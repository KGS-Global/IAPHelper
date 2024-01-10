
class IACommonUtils: NSObject {
    
    static let currencyFormatter: NumberFormatter = {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.formatterBehavior = .behavior10_4
        return numberFormatter
    }()
    
    static let customDateFormatter: DateFormatter = {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter
    }()
    
    
}
