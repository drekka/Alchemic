//
//  alchemic
//
//  Created by Derek Clarkson on 17/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCDefaultValueResolver.h"
#import <StoryTeller/StoryTeller.h>
#import "ALCArrayValueStrategy.h"
#import "ALCSimpleValueStrategy.h"

@implementation ALCDefaultValueResolver {
    NSArray<id<ALCValueResolverStrategy>> *_strategies;
}

-(instancetype) init {
    self = [super init];
    if (self) {
        id<ALCValueResolverStrategy> simpleStrategy = [[ALCSimpleValueStrategy alloc] init];
        id<ALCValueResolverStrategy> arrayStrategy = [[ALCArrayValueStrategy alloc] init];
        _strategies = @[arrayStrategy, simpleStrategy];
    }
    return self;
}

-(id) resolveValueForDependency:(ALCDependency *) dependency fromValues:(NSSet<id> *) values {

    id value;
    for (id<ALCValueResolverStrategy> strategy in _strategies) {
        if ([strategy canResolveValueForDependency:dependency values:values]) {
            value = [strategy resolveValues:values];
            break;
        }
    }

    if (value == nil) {
        @throw [NSException exceptionWithName:@"AlchemicNilObject"
                                       reason:[NSString stringWithFormat:@"Dependency value resolved to a nil"]
                                     userInfo:nil];
    }
    return value;
}

@end
