#import <Foundation/Foundation.h>
#import "CodableObjectProtocol.h"


/**
 *  trims a given NSString
 *
 *  @param val the NSString to be trimmed
 *
 *  @return trimmed NSString
 */
#define TRIM_STRING(val) [val stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]

/**
 *  checks if a NSString is valid
 *
 *  @param val a NSString to be checked
 *
 *  @return `YES` or `NO` based on the validity of the NSString
 */
#define IS_VALID_STRING(val) (val != nil) && [val length] != 0 && ([TRIM_STRING(val) length] != 0) && (![val isEqualToString:@"(null)"] || ![val isEqualToString:@"<null>"])

@interface CodableObject : NSObject <NSCopying, NSCoding, CodableObjectProtocol>
- (instancetype) initWithInfo:(NSDictionary*)info;
- (instancetype) initWithJSON:(NSData*)json;
@end
