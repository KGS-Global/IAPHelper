#import "CodableObject.h"

@interface CodableObject ()
@property (nonatomic, strong) NSMutableDictionary *fatBoy;
@end

@implementation CodableObject
@synthesize fatBoy = _fatBoy;

- (void)dealloc{
    NSLog(@"dealloc CodableObject");
}

- (NSMutableDictionary *)fatBoy{
    
    if (!_fatBoy) {
        _fatBoy = [[NSMutableDictionary alloc] init];
    }
    return _fatBoy;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    
    if (self = [super init]) {
        //Using Obj-C Runtime
        NSString *decodingKey = @"__myself__";
        NSDictionary *info = [aDecoder decodeObjectForKey:decodingKey];
        [self updateWithInfo:info];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    //Using Obj-C Runtime
    NSString *encodingKey = @"__myself__";
    [aCoder encodeObject:[self serializeIntoInfo] forKey:encodingKey];
}

- (id)copyWithZone:(NSZone *)zone{
    
    CodableObject *copy = [[[self class] alloc] init];
    
    if (copy) {
        @try {
            NSDictionary *info = [self serializeIntoInfo];
            [copy updateWithInfo:info];
        }
        @catch (NSException *exception) {
            NSLog(@"%@",[exception reason]);
        }
    }
    
    return copy;
}

- (instancetype)initWithInfo:(NSDictionary *)info{
    
    if (self = [super init]) {
        [self updateWithInfo:info];
    }
    return self;
}

- (void)updateWithInfo:(NSDictionary *)info{
    
    if (!info) {
        return;
    }
    //Using Obj-C Runtime
    NSArray *allKeys = nil;
    if(![info isEqual: [NSNull null]]) {
        allKeys = [info allKeys];
    }
    
    for (id key in allKeys) {
        
        if (![key isKindOfClass:[NSString class]]) {
            continue;
        }
        if ([(NSString*)key isEqualToString:@"fatBoy"]) {
            continue;
        }
        [self updateValue:[info objectForKey:key] forKey:key];
    }
}

- (void)updateValue:(id)value forKey:(NSString*)key{
    
    //check for NSNull or nil for key
    if ([key isKindOfClass:[NSNull class]] || nil == key) {
        return;
    }
    
    //check for NSNull or nil for value
    if ([value isKindOfClass:[NSNull class]] || nil == value) {
        return;
    }
    
    const char *propertyName = [(NSString*)key cStringUsingEncoding:NSUTF8StringEncoding];
    objc_property_t property = class_getProperty([self class], propertyName);
    Class encodeType = NSClassFromString([self property_getEncodeType:property]);
    
    #ifdef DEBUG
        fprintf(stdout, "updateValue :: %s { %s }\n", propertyName, [NSStringFromClass(encodeType) cStringUsingEncoding:NSUTF8StringEncoding]);//logging
    #endif
    if (property != NULL) {
        
        //@Now if property type is subclass of DyanaObject and value is kind of NSDictionary then,
        if ( [encodeType isSubclassOfClass:[CodableObject class]]
            && [value isKindOfClass:[NSDictionary class]]) {
            //it means value is a dictionary and property is a subclass of DyanaObject.
            //set create a dyanaObject instance and then set to property
            id dyanaVal = [[encodeType alloc] init];
            [(CodableObject*)dyanaVal updateWithInfo:value];
            [self setValue:dyanaVal forKey:key];
            return;
        }
        //@Now is property type is NSSet and Value type is Array, then convert array into set
        else if ([encodeType isSubclassOfClass:[NSSet class]]
            && [value isKindOfClass:[NSArray class]]) {
            
            id setVal = [[NSMutableSet alloc] initWithArray:value];
            [self setValue:setVal forKey:key];
        }
        else if ([encodeType isSubclassOfClass:[NSDate class]]
                 && [value isKindOfClass:[NSString class]]){
            
            //If property type is NSDate but value is string.
            //Then converted to NSDate
            if ([self respondsToSelector:@selector(updateDate:forKey:)]) {
                NSDate *date = [self updateDate:value forKey:key];
                [self setValue:date forKey:key];
            }else{
                NSDate *date = [self updateDate:value];
                [self setValue:date forKey:key];
            }
        }
        else{
            //@Now if property type and value type not matched then return.
            if (![value isKindOfClass:encodeType]) {
                return;
            }
            [self setValue:value forKey:key];
        }
    }else{
        NSLog(@"%@ property not found. So added to the FatBoy",key);
        [self setValue:value forKey:key];
    }
}

- (NSDate *)updateDate:(NSString *)dateStr{
    return [NSDate date];
}

- (NSDate *)updateDate:(NSString *)dateStr forKey:(NSString*)key{
    return [self updateDate:dateStr];
}

- (NSString*) property_getEncodeType:(objc_property_t)property{
    
    NSString *encodeType = NSStringFromClass([NSObject class]);
    unsigned int count;
    objc_property_attribute_t *attributes = property_copyAttributeList(property, &count);
    if (count > 0) {
        objc_property_attribute_t attribute = attributes[0];
        encodeType = [NSString stringWithUTF8String:attribute.value];
        if ([encodeType hasPrefix:@"@\""] && [encodeType hasSuffix:@"\""] && encodeType.length > 2) {
            //at this moment we have got @"@"NSString"" type of thing.
            encodeType = [encodeType substringFromIndex:2];
            encodeType = [encodeType substringToIndex:encodeType.length-1];
        }
    }
    free(attributes);
    return encodeType;
}

- (id)valueForUndefinedKey:(NSString *)key{
    return [self.fatBoy valueForKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    [self.fatBoy setValue:value forKey:key];
}

- (instancetype)initWithJSON:(NSData*)json{
    
    if (self = [super init]) {
        [self updateWithJSON:json];
    }
    return self;
}

- (void)updateWithJSON:(NSData *)json{
    
    //now update with Dictionary info.
    id info = [self serializeJson:json];
    [self updateWithInfo:info];
}

- (id) serializeJson:(NSData*)json{
    
    if (!json) {
        return nil;
    }
    
    NSError *error;
    id info = nil;
    
    @try {
        info = [NSJSONSerialization JSONObjectWithData:json options:NSJSONReadingMutableContainers error:&error];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception reason]);
    }
    
    if ( !info || ![info isKindOfClass:[NSDictionary class]] || error) {
        return nil;
    }
    
    return info;
}

- (NSData *)serializeIntoJSON{
    
    NSError *error;
    NSDictionary *info = [self serializeIntoInfo];
    NSData *data = nil;
    @try {
        data = [NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:&error];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception reason]);
    }
    return [[NSData alloc] initWithData:data];
}

- (NSArray*) propertyList{
    
    NSMutableArray *properties = [NSMutableArray new];
    
    Class currentClass = [self class];
    
    do{
        //Using Objective-C runtime
        unsigned int count;
        objc_property_t *propertyList = class_copyPropertyList(currentClass, &count);
        
        for (int index = 0; index < count; index++) {
            
            objc_property_t property = propertyList[index];
            const char *propertyName = property_getName(property);
            NSString *key = [NSString stringWithUTF8String:propertyName];
            #ifdef DEBUG
                fprintf(stdout, "Property Found :: %s { %s }\n", propertyName, property_getAttributes(property));//logging
            #endif
            [properties addObject:key];
        }
        
        free(propertyList);
        currentClass = [currentClass superclass];
        
    }while ([currentClass superclass]);
    
    return properties;
}

- (BOOL) isIgnorantPropertie:(NSString*)key{
    
    return [key isEqualToString:@"debugDescription"] || [key isEqualToString:@"description"] || [key isEqualToString:@"hash"] || [key isEqualToString:@"superclass"];
}

- (NSDictionary *)serializeIntoInfo{
    
    NSArray *propertyList = [self propertyList];
    
    NSMutableDictionary *newInfo = nil;
    if (propertyList.count > 0) {
        newInfo = [[NSMutableDictionary alloc] initWithCapacity:propertyList.count];
    }
    
    for (int index = 0; index < propertyList.count; index++) {
        
        NSString *key = propertyList[index];
        if ([key isEqualToString:@"fatBoy"]
            || [self isIgnorantPropertie:key]) {
            continue;
        }
        
        id value = [self serializeValue:[self valueForKey:key] forKey:key];
        if (value) [newInfo setValue:value forKey:key];
    }
    //Now mutate fatboy's KV to the info.
    if (self.fatBoy.count > 0) {
        
        NSArray *allKeys = nil;
        if(![self.fatBoy isEqual: [NSNull null]]) {
            allKeys = [self.fatBoy allKeys];
        }
        
        for (id key in allKeys) {
            //Concidering NSDate in fatboy, upto first level.
            id value = [self serializeValue:[self.fatBoy objectForKey:key] forKey:key];
            if (value) [newInfo setValue:value forKey:key];
        }
    }
    
    return newInfo;
}

- (id) serializeValue:(id)value forKey:(NSString*)key{
    
    id result = nil;
    
    if ([value isKindOfClass:[CodableObject class]]) {
        
        result = [(CodableObject*)value serializeIntoInfo];
    }
    else if([value isKindOfClass:[NSArray class]]
            || [value isKindOfClass:[NSSet class]]){
        
        //NSSet or NSMutableSet or NSCountedSet is not a valid JSON writable object.
        //So converted to a NSArray
        result = ([value isKindOfClass:[NSSet class]])
                    ? [self recursiveArraySerializer:[(NSSet*)value allObjects]]
                        : [self recursiveArraySerializer:value];
    }
    else if ([value isKindOfClass:[NSDictionary class]]){
        
        result = [self recursiveDictionarySerializer:value];
    }
    else if ([value isKindOfClass:[NSDate class]]){
        
        //NSDate is not a valid JSON writable object.
        //SO converted to NSString
        if ([self respondsToSelector:@selector(serializeDate:forKey:)]) {
            result = [self serializeDate:value forKey:key];
        }else{
            result = [self serializeDate:value];
        }
    }
    else if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]){
        
        result = value;
    }
    else if ([value respondsToSelector:@selector(encodeWithCoder:)]) {
        return value;
    }
    else{
        NSLog(@"Root Key : %@ of encode type :: %@ has failed to parse." ,key, NSStringFromClass([value class]));
        result = [NSNull null];
    }
    
    return result;
}

- (NSString *)serializeDate:(NSDate *)date{
    return [NSString stringWithFormat:@"%@",date];
}

- (NSString *)serializeDate:(NSDate *)date forKey :(NSString*)key{
    return [self serializeDate:date];
}

- (NSArray*) recursiveArraySerializer:(NSArray*)value{
    
    NSMutableArray *mutable = [[NSMutableArray alloc] init];
    for (id item in value) {
        
        if ([item isKindOfClass:[NSArray class]]) {
            id obj = [self recursiveArraySerializer:item];
            [mutable addObject:obj];
        }
        else if ([item isKindOfClass:[NSDictionary class]]){
            id obj = [self recursiveDictionarySerializer:item];
            [mutable addObject:obj];
        }
        else if ([item isKindOfClass:[CodableObject class]]) {
            [mutable addObject:[item serializeIntoInfo]];
        }
        else if ([item isKindOfClass:[NSDate class]]){
            NSString *dateStr = [self serializeDate:item];
            [mutable addObject:dateStr];
        }
        else if ([item isKindOfClass:[NSString class]] || [item isKindOfClass:[NSNumber class]]){
            [mutable addObject:item];
        }
        else{
            NSLog(@"Leef Item of encode type :: %@ has failed to parse.",NSStringFromClass([item class]));
            [mutable addObject:[NSNull null]];
        }
    }
    return mutable;
}

- (NSDictionary*) recursiveDictionarySerializer:(NSDictionary*)value{
    
    NSMutableDictionary *mutable = [[NSMutableDictionary alloc] init];
    
    NSArray *allKeys = nil;
    if(![value isEqual: [NSNull null]]) {
        allKeys = [value allKeys];
    }
    
    for (id key in allKeys) {
        
        id item = [value objectForKey:key];
        
        if ([item isKindOfClass:[NSArray class]]) {
            id obj = [self recursiveArraySerializer:item];
            [mutable setObject:obj forKey:key];
        }
        else if ([item isKindOfClass:[NSDictionary class]]){
            id obj = [self recursiveDictionarySerializer:item];
            [mutable setObject:obj forKey:key];
        }
        else if ([item isKindOfClass:[CodableObject class]]) {
            [mutable setObject:[item serializeIntoInfo] forKey:key];
        }
        else if ([item isKindOfClass:[NSDate class]]){
            NSString *dateStr = [self serializeDate:item forKey:key];
            [mutable setObject:dateStr forKey:key];
        }
        else if ([item isKindOfClass:[NSString class]] || [item isKindOfClass:[NSNumber class]]){
            [mutable setObject:item forKey:key];
        }
        else{
            NSLog(@"Leef Key : %@ of encode type :: %@ has failed to parse.", key, NSStringFromClass([item class]));
            [mutable setObject:[NSNull null] forKey:key];
        }
    }
    return mutable;
}

@end
