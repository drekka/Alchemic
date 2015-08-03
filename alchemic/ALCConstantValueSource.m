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
	id _value;
}

-(instancetype) init {
	return nil;
}

-(instancetype) initWithValue:(id) value {
    self = [super init];
    if (self) {
		 _value = value;
    }
    return self;
}

-(NSSet<id> *) values {
	return [NSSet setWithObject:_value];
}

-(void)resolveWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> * _Nonnull)postProcessors {}
-(void)validateWithDependencyStack:(NSMutableArray<id<ALCResolvable>> *)dependencyStack {}

@end

NS_ASSUME_NONNULL_END