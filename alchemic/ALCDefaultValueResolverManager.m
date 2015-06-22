//
//  alchemic
//
//  Created by Derek Clarkson on 17/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCDefaultValueResolverManager.h"
#import <StoryTeller/StoryTeller.h>
#import "ALCArrayValueResolver.h"
#import "ALCSimpleValueResolver.h"

@implementation ALCDefaultValueResolverManager {
    NSArray<id<ALCValueResolver>> *_resolvers;
}

-(instancetype) init {
    self = [super init];
    if (self) {
        id<ALCValueResolver> simpleResolver = [[ALCSimpleValueResolver alloc] init];
        id<ALCValueResolver> arrayResolver = [[ALCArrayValueResolver alloc] init];
        _resolvers = @[arrayResolver, simpleResolver];
    }
    return self;
}

-(id) resolveValueForDependency:(ALCDependency *) dependency candidates:(NSSet<id<ALCBuilder>> *) candidates {
    
    id value;
    for (id<ALCValueResolver> resolver in _resolvers) {
        if ([resolver canResolveValueForDependency:dependency candidates:candidates]) {
            value = [resolver resolveCandidateValues:candidates];
            break;
        }
    }

    if (value == nil) {
        @throw [NSException exceptionWithName:@"AlchemicNilObject"
                                       reason:[NSString stringWithFormat:@"Dependency resolved to a nil"]
                                     userInfo:nil];
    }
    return value;
}

@end
