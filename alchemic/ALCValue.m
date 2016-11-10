//
//  ALCValue.m
//  Alchemic
//
//  Created by Derek Clarkson on 22/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCValue.h"
#import "ALCType.h"
#import "ALCRuntime.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCValue {
    ALCBlockWithObject _completion;
}

+(ALCValue *) withObject:(nullable id) object
             completion:(nullable ALCBlockWithObject) completion {
    ALCValue *alcValue = [[ALCValue alloc] init];
    alcValue->_completion = completion;
    alcValue->_object = object;
    return alcValue;
}

-(void) complete {
    [ALCRuntime executeBlock:self->_completion withObject:_object];
}

@end

NS_ASSUME_NONNULL_END
