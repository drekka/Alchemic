//
//  ALCWithName.m
//  Alchemic
//
//  Created by Derek Clarkson on 17/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import <StoryTeller/StoryTeller.h>

#import "ALCName.h"
#import "ALCInternalMacros.h"
#import "ALCRuntime.h"
#import "ALCBuilder.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCName

+(instancetype) withName:(NSString *) aName {
    ALCName *withName = [[ALCName alloc] init];
    withName->_aName = aName;
    return withName;
}

-(int) priority {
    return 1;
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
    || ([object isKindOfClass:[ALCName class]] && [self isEqualToName:object]);
}

-(BOOL) isEqualToName:(nonnull ALCName *)withName {
    return withName != nil && withName.aName == _aName;
}

@end

NS_ASSUME_NONNULL_END