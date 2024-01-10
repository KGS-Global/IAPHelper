import UIKit
import Foundation

protocol CodableObjectProtocol: NSObject{
    func update(value: Any?, for key: String?)
    func serialize(value: Any?, for key: String) -> Any?
}

@objc class CodableObject: NSObject {

    private let KEY: String = "__myself__"
    @objc private var fatBoy: NSMutableDictionary = NSMutableDictionary()
    
    

    deinit{
        print("Deinit CodableObject")
    }
    
    required override init() {
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()
        let info = aDecoder.decodeObject(forKey: KEY) as? NSDictionary
        self.update(with: info)
    }
    
    init(with info: NSDictionary?){
        super.init()
        self.update(with: info)
    }
    
    init(with json: Data?){
        super.init()
        self.update(with: json)
    }
    
    private func update(with info: NSDictionary?){
        guard let info = info else {
            return
        }
        
        let allKeys = info.allKeys
        for key in allKeys{
            if let key = key as? String,
               key != "fatBoy"{
                self.update(value: info.object(forKey: key), for: key)
            }
        }
    }
    private func update(with json:Data?){
        let info = self.serializeJson(json: json)
        self.update(with: info)
    }
    
    private func property_getEncodeType(_ property: objc_property_t) -> String? {

        var encodeType:String? = NSStringFromClass(NSObject.self)
        var count: UInt32 = .min
        let attributes = property_copyAttributeList(property, &count)
        guard let attributes = attributes else {
            return encodeType
        }
        if count > 0{
            let attribute = attributes[0]
            encodeType = String(utf8String: attribute.value)
            if encodeType != nil {
                //TODO: Need to check prefix
                if encodeType!.hasPrefix("@\"") && encodeType!.hasSuffix("\"") && encodeType!.count > 2{
                    encodeType = (encodeType! as NSString).substring(from: 2)
                    encodeType = (encodeType! as NSString).substring(to: encodeType!.count - 1)
                }
            }
            
        }

        free(attributes)
        return encodeType
    }

    
    override func value(forUndefinedKey key: String) -> Any? {
        return self.fatBoy.value(forKey:key)
    }
    
    
    override func setValue(_ value: Any?, forKey key: String) {
        self.fatBoy.setValue(value, forKey: key)
    }

    private func serializeJson(json: Data?) -> NSDictionary?{
        
        guard let json = json else {
            return nil
        }
        do {
            let info = try JSONSerialization.jsonObject(with: json, options: .mutableContainers)
            if let info = info as? NSDictionary{
                return info
            }
        } catch{
            print("\(error.localizedDescription)")
        }
        
        return nil
    }
    
    private func serializeIntoJSON() -> Data?{
        let info = self.serializeIntoInfo()
        
        do{
            let data = try JSONSerialization.data(withJSONObject: info, options: .prettyPrinted)
            return Data(data)
        } catch{
            print("\(error.localizedDescription)")
        }
        return nil
    }

    
    private func propertyList() -> NSArray {

        let properties: NSMutableArray = NSMutableArray()

        var currentClass: AnyObject.Type? = type(of: self)

        repeat {
            var count: UInt32 = .min
            let propertyList = class_copyPropertyList(currentClass, &count)

            for index in 0..<Int(count) {

                if let property = propertyList?[index]{
                    let propertyName = property_getName(property)
                    let key = String(utf8String: propertyName)
                    #if DEBUG
                    print("Property Found :: \(propertyName) { \(property_getAttributes(property)) }")
                    #endif
                    properties.add(key as Any)
                }
                
            }

            free(propertyList)
            currentClass = currentClass?.superclass()
        } while currentClass?.superclass() != nil

        return properties
    }
    
    
    
    private func isIgnorantProperty(key: String) -> Bool{
        
        return key == "debugDescription" ||
                key == "description" ||
                key == "hash" ||
                key == "superclass"
    }

    private func serializeIntoInfo() -> NSDictionary {
        
        let propertyList = self.propertyList()
        
        var newInfo: NSMutableDictionary = NSMutableDictionary()
        
        if propertyList.count > 0{
            newInfo = NSMutableDictionary(capacity: propertyList.count)
        }
        
        for index in 0..<propertyList.count{
            let key = propertyList[index] as! String
            if key == "fatBoy" ||
                self.isIgnorantProperty(key: key){
                continue
            }
            let value = self.serialize(value: self.value(forKey: key), for: key)
            if value != nil{
                newInfo.setValue(value, forKey: key)
            }
        }
        //Now mutate fatboy's KV to the info.
        if (self.fatBoy.count > 0) {
            let allKeys = self.fatBoy.allKeys
            for key in allKeys{
                if let key = key as? String{
                    let value = self.serialize(value: self.fatBoy.object(forKey:key), for: key)
                    if value != nil{
                        newInfo.setValue(value, forKey: key)
                    }
                }
                
            }

        }

        return newInfo;

    }
    
    private func recursiveArraySerializer(_ value: NSArray) -> NSArray {
        let mutable: NSMutableArray = NSMutableArray()
        
        for item in value{
            if let item = item as? NSArray{
                let obj = self.recursiveArraySerializer(item)
                mutable.add(obj)
            } else if let item = item as? NSDictionary{
                let obj = self.recursiveDictionarySerializer(item)
                mutable.add(obj)
            } else if let item = item as? CodableObject{
                mutable.add(item.serializeIntoInfo())
            } else if let item = item as? Date{
                let dateStr = "\(item)"
                mutable.add(dateStr)
            } else if let item = item as? String{
                mutable.add(item)
            } else if let item = item as? NSNumber{
                mutable.add(item)
            } else {
                print("Leef Item of encode type :: \(item) has failed to parse.")
                mutable.add(NSNull())
            }
        }
        return mutable
    }


    private func recursiveDictionarySerializer(_ value: NSDictionary) -> NSDictionary {
        let mutable: NSMutableDictionary = NSMutableDictionary()
        let allKeys = value.allKeys
        for key in allKeys{
            guard let key = key as? String else {
                continue
            }
            let item = value.object(forKey: key)
            if let item = item as? NSArray{
                let obj = self.recursiveArraySerializer(item)
                mutable.setValue(obj, forKey: key)
            } else if let item = item as? NSDictionary{
                let obj = self.recursiveDictionarySerializer(item)
                mutable.setValue(obj, forKey: key)
            } else if let item = item as? CodableObject{
                mutable.setValue(item.serializeIntoInfo, forKey: key)
            } else if let item = item as? Date{
                let dateStr = "\(item)"
                mutable.setValue(dateStr, forKey: key)
            } else if let item = item as? String{
                mutable.setValue(item, forKey: key)
            } else if let item = item as? NSNumber{
                mutable.setValue(item, forKey: key)
            } else {
                print("Leef Item of encode type :: \(item) has failed to parse.")
                mutable.setValue(NSNull(), forKey: key)
            }
        }

        return mutable
    }

}


extension CodableObject: CodableObjectProtocol{

    
    @objc func update(value: Any?, for key: String?) {

        guard let key = key else {
            return
        }
        
        guard let value = value else {
            return
        }
        if ((value as? NSNull) != nil){
            return
        }

        
        if let propertyName = key.cString(using: .utf8),
           let property = class_getProperty(type(of: self), propertyName){
            
            //TODO: use if instead of force unwrap for better understanding
            let encodeType: AnyClass = NSClassFromString(self.property_getEncodeType(property)!)!
            
            #if DEBUG
                print("updateValue :: \(propertyName) { \(encodeType) }")
            #endif
            
            
            if encodeType.isSubclass(of: CodableObject.self),
               let value = value as? NSDictionary{
                if let encodeType = encodeType as? CodableObject.Type{ 
                    let dyanaVal = encodeType.init()
                    dyanaVal.update(with: value)
                    self.setValue(dyanaVal, forKey: key)
                    return
                }
            } else if encodeType.isSubclass(of: NSSet.self),
                      let value = value as? NSArray{
            
                let setVal = NSMutableSet(array: value as! [Any])
                self.setValue(setVal, forKey: key)
            
            }else if encodeType.isSubclass(of: NSDate.self),
                     let value = value as? String{
                
                let date = Date()
                self.setValue(date, forKey: key)
            }
            else{
                if (((value as? NSObject)?.isKind(of: encodeType)) != nil){
                    return;
                }
                self.setValue(value, forKey: key)
            }
                        
        } else {
        
            print("\(key) property not found. So added to the FatBoy");
            self.setValue(value, forKey: key)
        }
    }

    @objc func serialize(value: Any?, for key: String) -> Any?{
        
        var result: Any? = nil

        if let value = value as? CodableObject{
            result = value.serializeIntoInfo()
        } else if let value = value as? NSArray{
            result = self.recursiveArraySerializer(value)
        } else if let value = value as? NSSet{
            result = self.recursiveArraySerializer(NSArray(array: value.allObjects))
        } else if let value = value as? NSDictionary{
            result = self.recursiveDictionarySerializer(value)
        } else if let value = value as? Date{
            let date = Date()
            result = "\(date)"
        } else if let value = value as? String{
            result = value
        } else if let value = value as? NSNumber{
            result = value
        } else if (((value as? NSObject)?.responds(to: #selector(encode(with:)))) != nil){
            return value
        } else {
            print("Root Key : \(key) of encode type :: \(value) has failed to parse.")
            result = NSNull()
        }
        return result;
    }
    
    
}


extension CodableObject:NSCopying{
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = CodableObject()
        let info = self.serializeIntoInfo()
        copy.update(with: info)
        return copy
    }

}



extension CodableObject: NSCoding{
    func encode(with coder: NSCoder) {
        coder.encode(self.serializeIntoInfo(), forKey: KEY)
    }
}
