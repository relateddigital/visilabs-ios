#import <Foundation/Foundation.h>

@interface VisilabsExceptionWrapper : NSObject

+ (void)try:(void(^)(void))try catch:(void(^)(NSException *exception))catch finally:(void(^)(void))finally;

@end
