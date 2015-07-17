//
//  ALCWithName.m
//  Alchemic
//
//  Created by Derek Clarkson on 17/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCWithName.h"

#import <Alchemic/Alchemic.h>
#import <Alchemic/ALCInternalMacros.h>
#import "ALCRuntime.h"
#import <StoryTeller/StoryTeller.h>

NS_ASSUME_NONNULL_BEGIN

@implementation ALCWithName

+(instancetype) withName:(NSString *) aName {
    ALCWithName *withName = [[ALCWithName alloc] init];
    withName->_aName = aName;
    return withName;
}

-(id) cacheId {
    return _aName;
}

-(BOOL) matches:(id<ALCBuilder>) builder {
    return [builder.name isEqualToString:_aName];
}

-(NSString *)description {
    return [NSString stringWithFormat:@"With '%@'", _aName];
}

#pragma mark - Equality

-(NSUInteger)hash {
    return [_aName hash];
}

-(BOOL) isEqual:(id)object {
    return self == object
    || ([object isKindOfClass:[ALCWithName class]] && [self isEqualToWithName:object]);
}

-(BOOL) isEqualToWithName:(nonnull ALCWithName *)withName {
    return withName != nil && withName.aName == _aName;
}

@end

NS_ASSUME_NONNULL_END