//
//  ALCConstantValueSource.m
//  Alchemic
//
//  Created by Derek Clarkson on 16/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCConstantValueSource.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCConstantValueSource {
}

@synthesize values = _values;

-(instancetype) init {
	return nil;
}

-(instancetype) initWithValue:(id) value {
    self = [super init];
    if (self) {
        _values = [NSSet setWithObject:value];
    }
    return self;
}

-(void)resolveWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> * _Nonnull)postProcessors{}

@end

NS_ASSUME_NONNULL_END