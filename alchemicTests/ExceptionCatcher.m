
#import "ExceptionCatcher.h"

@implementation ExceptionCatcher

+(BOOL) catchException:(void (^)(void)) tryBlock
                 error:(__autoreleasing NSError **) error {
    @try {
        tryBlock();
        return YES;
    }
    @catch (NSException *exception) {
        *error = [NSError errorWithDomain:NSStringFromClass([exception class])
                                     code:1
                                 userInfo:@{
                                            NSLocalizedDescriptionKey:exception.reason
                                            }];
    }
    return NO;
}

@end
