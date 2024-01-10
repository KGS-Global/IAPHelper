#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@protocol CodableObjectProtocol <NSObject>
@required
- (void) updateValue:(id)value forKey:(NSString*)key;
- (id) serializeValue:(id)value forKey:(NSString*)key;
@end
