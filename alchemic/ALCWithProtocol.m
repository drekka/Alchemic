//
//  ALCWithProtocol.m
//  Alchemic
//
//  Created by Derek Clarkson on 17/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCWithProtocol.h"

#import <Alchemic/Alchemic.h>
#import <Alchemic/ALCInternalMacros.h>
#import "ALCRuntime.h"
#import <StoryTeller/StoryTeller.h>

NS_ASSUME_NONNULL_BEGIN

@implementation ALCWithProtocol

+(instancetype) withProtocol:(Protocol *) aProtocol {
    ALCWithProtocol *withProtocol = [[ALCWithProtocol alloc] init];
    withProtocol->_aProtocol = aProtocol;
    return withProtocol;
}

-(id) cacheId {
    return _aProtocol;
}

-(BOOL) matches:(id<ALCBuilder>) builder {
    return [builder.valueClass conformsToProtocol:_aProtocol];
}

-(NSString *)description {
    return [NSString stringWithFormat:@"With <%s>", protocol_getName(_aProtocol)];
}

#pragma mark - Equality

-(NSUInteger)hash {
    return [[self description] hash];
}

-(BOOL) isEqual:(id)object {
    return self == object
    || ([object isKindOfClass:[ALCWithProtocol class]] && [self isEqualToWithProtocol:object]);
}

-(BOOL) isEqualToWithProtocol:(nonnull ALCWithProtocol *)withProtocol {
    return withProtocol != nil && withProtocol.aProtocol == _aProtocol;
}

@end

NS_ASSUME_NONNULL_END