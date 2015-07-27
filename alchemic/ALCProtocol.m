//
//  ALCWithProtocol.m
//  Alchemic
//
//  Created by Derek Clarkson on 17/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import <StoryTeller/StoryTeller.h>
#import "ALCProtocol.h"

#import "ALCSearchableBuilder.h"


NS_ASSUME_NONNULL_BEGIN

@implementation ALCProtocol

+(instancetype) withProtocol:(Protocol *) aProtocol {
    ALCProtocol *withProtocol = [[ALCProtocol alloc] init];
    withProtocol->_aProtocol = aProtocol;
    return withProtocol;
}

-(int) priority {
    return -1;
}

-(id) cacheId {
    return _aProtocol;
}

-(BOOL) matches:(id<ALCSearchableBuilder>) builder {
    return [builder.valueClass conformsToProtocol:_aProtocol];
}

-(NSString *)description {
    return [NSString stringWithFormat:@"With <%@>", NSStringFromProtocol(_aProtocol)];
}

#pragma mark - Equality

-(NSUInteger)hash {
    return [[self description] hash];
}

-(BOOL) isEqual:(id)object {
    return self == object
    || ([object isKindOfClass:[ALCProtocol class]] && [self isEqualToProtocol:object]);
}

-(BOOL) isEqualToProtocol:(nonnull ALCProtocol *)withProtocol {
    return withProtocol != nil && withProtocol.aProtocol == _aProtocol;
}

@end

NS_ASSUME_NONNULL_END