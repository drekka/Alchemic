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

-(instancetype) initWithType:(Class) argumentType NS_UNAVAILABLE {
    return nil;
}

-(instancetype) initWithType:(Class) argumentType value:(id) value {
    self = [super initWithType:argumentType];
    if (self) {
        _value = value;
    }
    return self;
}

-(NSSet<id> *) values {
    return [NSSet setWithObject:_value];
}

-(void)resolveWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> * _Nonnull)postProcessors {
    [super resolveWithPostProcessors:postProcessors];
}

-(void)validateWithDependencyStack:(NSMutableArray<id<ALCResolvable>> *)dependencyStack {}

-(NSString *)description {
    return [NSString stringWithFormat:@"Constant: %@", [_value description]];
}

@end

NS_ASSUME_NONNULL_END