//
//  ALCClassMatcher.m
//  alchemic
//
//  Created by Derek Clarkson on 6/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCWithClass.h"

#import <Alchemic/Alchemic.h>
#import <Alchemic/ALCInternalMacros.h>
#import "ALCRuntime.h"
#import <StoryTeller/StoryTeller.h>

NS_ASSUME_NONNULL_BEGIN

@implementation ALCWithClass

+(instancetype) withClass:(Class) aClass {
    ALCWithClass *withClass = [[ALCWithClass alloc] init];
    withClass->_aClass = aClass;
    return withClass;
}

-(int) priority {
    return 0;
}

-(id) cacheId {
    return _aClass;
}

-(BOOL) matches:(id<ALCBuilder>) builder {
    return [builder.valueClass isSubclassOfClass:_aClass];
}

-(NSString *)description {
    return [NSString stringWithFormat:@"With [%s]", class_getName(_aClass)];
}

#pragma mark - Equality

-(NSUInteger)hash {
    return [_aClass hash];
}

-(BOOL) isEqual:(id)object {
    return self == object
    || ([object isKindOfClass:[ALCWithClass class]] && [self isEqualToWithClass:object]);
}

-(BOOL) isEqualToWithClass:(nonnull ALCWithClass *)withClass {
    return withClass != nil && withClass.aClass == _aClass;
}

@end

NS_ASSUME_NONNULL_END