//
//  ALCValue.m
//  Alchemic
//
//  Created by Derek Clarkson on 22/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCValue.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCValue

-(void) setValue:(id) value completion:(nullable ALCSimpleBlock) completion {
    _value = value;
    _completion = completion;
}

@end

NS_ASSUME_NONNULL_END
