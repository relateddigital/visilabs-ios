#import "VisilabsExceptionWrapper.h"

@implementation VisilabsExceptionWrapper

+ (void)try:(void(^)(void))try catch:(void(^)(NSException *exception))catch finally:(void(^)(void))finally {
    @try {
        try ? try() : nil;
    }
    @catch (NSException *exception) {
        catch ? catch(exception) : nil;
    }
    @finally {
        finally ? finally() : nil;
    }
}

@end
